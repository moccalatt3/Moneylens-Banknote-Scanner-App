import os
from PIL import Image
import numpy as np
import cv2
import imagehash
from skimage.metrics import structural_similarity as ssim
import shutil


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ASSETS_DIR = os.path.join(BASE_DIR, "..", "assets")
FACE_PROFILES_DIR = os.path.join(ASSETS_DIR, "face_profiles")
CURRENCIES_DIR = os.path.join(ASSETS_DIR, "currencies")
TESTING_FACE_DIR = os.path.join(ASSETS_DIR, "testing", "face_results")
CURRENCIES_RESULTS_DIR = os.path.join(ASSETS_DIR, "testing", "currencies_results")
CROPPING_CURRENCIES_DIR = os.path.join(ASSETS_DIR, "testing", "cropping_currencies")
HAAR_CASCADE_PATH = os.path.join(ASSETS_DIR, "haarcascades", "haarcascade_frontalface_default.xml")

os.makedirs(CROPPING_CURRENCIES_DIR, exist_ok=True)
os.makedirs(TESTING_FACE_DIR, exist_ok=True)
os.makedirs(CURRENCIES_RESULTS_DIR, exist_ok=True)

face_cascade = cv2.CascadeClassifier(HAAR_CASCADE_PATH)

# === UTIL FUNCTIONS ===
def normalize_lighting(image_pil):
    image_cv = cv2.cvtColor(np.array(image_pil), cv2.COLOR_RGB2BGR)
    lab = cv2.cvtColor(image_cv, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)
    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
    cl = clahe.apply(l)
    limg = cv2.merge((cl, a, b))
    result_cv = cv2.cvtColor(limg, cv2.COLOR_LAB2RGB)
    return Image.fromarray(result_cv)

def preprocess_image(image, size=(100, 100)):
    return np.array(image.resize(size).convert("L"))

def preprocess_face_color(image, size=(100, 100)):
    img = image.resize(size).convert("RGB")
    return np.asarray(img) / 255.0

def compute_hash_similarity(img1, img2):
    hash1 = imagehash.phash(img1)
    hash2 = imagehash.phash(img2)
    return max(0.0, 1.0 - (hash1 - hash2) / 64.0)

def compute_orb_similarity(img1, img2):
    orb = cv2.ORB_create()
    kp1, des1 = orb.detectAndCompute(img1, None)
    kp2, des2 = orb.detectAndCompute(img2, None)
    if des1 is None or des2 is None:
        return 0.0
    bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
    matches = bf.match(des1, des2)
    if not matches:
        return 0.0
    matches = sorted(matches, key=lambda x: x.distance)
    score = sum([1 - (m.distance / 256) for m in matches]) / len(matches)
    return min(max(score, 0.0), 1.0)

def cosine_similarity(a, b):
    a_flat = a.flatten()
    b_flat = b.flatten()
    dot = np.dot(a_flat, b_flat)
    norm_a = np.linalg.norm(a_flat)
    norm_b = np.linalg.norm(b_flat)
    if norm_a == 0 or norm_b == 0:
        return 0.0
    return dot / (norm_a * norm_b)

def crop_and_resize_center(image, size=(100, 100)):
    width, height = image.size
    crop_size = int(min(width, height) * 0.5)
    left = (width - crop_size) // 2
    top = (height - crop_size) // 2
    right = left + crop_size
    bottom = top + crop_size
    cropped = image.crop((left, top, right, bottom))
    return cropped.resize(size)

def detect_and_crop_face(image_pil, size=(100, 100), save_filename="cropped_face.jpg"):
    image_rgb = np.array(image_pil.convert("RGB"))
    image_gray = cv2.cvtColor(image_rgb, cv2.COLOR_RGB2GRAY)
    faces = face_cascade.detectMultiScale(image_gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    if len(faces) == 0:
        cropped = crop_and_resize_center(image_pil, size)
        cropped.save(os.path.join(TESTING_FACE_DIR, save_filename))
        return cropped

    largest_face = max(faces, key=lambda r: r[2] * r[3])
    x, y, w, h = largest_face
    face_img = image_rgb[y:y+h, x:x+w]
    face_pil = Image.fromarray(face_img).resize(size)

    save_path = os.path.join(TESTING_FACE_DIR, save_filename)
    face_pil.save(save_path)
    return face_pil

def match_face_region(input_image):
    normalized_image = normalize_lighting(input_image)
    face_image = detect_and_crop_face(normalized_image, save_filename="match_face_region.jpg")
    input_gray = preprocess_image(face_image)
    input_rgb = face_image.convert("RGB")

    best_match = None
    best_score = 0

    for currency in os.listdir(FACE_PROFILES_DIR):
        for denom in os.listdir(os.path.join(FACE_PROFILES_DIR, currency)):
            for year in os.listdir(os.path.join(FACE_PROFILES_DIR, currency, denom)):
                for side in ["front", "back"]:
                    for i in range(1, 11):
                        path = os.path.join(FACE_PROFILES_DIR, currency, denom, year, f"{side}_{i}.jpg")
                        if not os.path.exists(path):
                            continue
                        try:
                            template_img = Image.open(path).convert("RGB")
                            template_gray = preprocess_image(template_img)
                            face_conf = ssim(input_gray, template_gray)
                            hash_conf = compute_hash_similarity(input_rgb, template_img)
                            orb_conf = compute_orb_similarity(input_gray, template_gray)
                            combined = 0.4 * face_conf + 0.3 * hash_conf + 0.3 * orb_conf
                            if combined > best_score:
                                best_score = combined
                                best_match = {
                                    "type": "face_match",
                                    "currency": currency,
                                    "denomination": denom,
                                    "year": year,
                                    "side": side,
                                    "variant": f"{side}_{i}",
                                    "face_confidence": round(face_conf, 3),
                                    "hash_confidence": round(hash_conf, 3),
                                    "orb_confidence": round(orb_conf, 3),
                                    "confidence": round(combined, 3),
                                    "template_path": path
                                }
                        except:
                            continue
    return best_match or {"confidence": 0.0}

def match_face_color_similarity(input_image):
    normalized_image = normalize_lighting(input_image)
    face_image = detect_and_crop_face(normalized_image, save_filename="match_face_color.jpg")
    input_rgb = preprocess_face_color(face_image)

    best_match = None
    best_score = 0

    for currency in os.listdir(FACE_PROFILES_DIR):
        for denom in os.listdir(os.path.join(FACE_PROFILES_DIR, currency)):
            for year in os.listdir(os.path.join(FACE_PROFILES_DIR, currency, denom)):
                for side in ["front", "back"]:
                    for i in range(1, 11):
                        path = os.path.join(FACE_PROFILES_DIR, currency, denom, year, f"{side}_{i}.jpg")
                        if not os.path.exists(path):
                            continue
                        try:
                            template_img = Image.open(path).convert("RGB")
                            template_rgb = preprocess_face_color(template_img)
                            color_conf = cosine_similarity(input_rgb, template_rgb)
                            if color_conf > best_score:
                                best_score = color_conf
                                best_match = {
                                    "type": "face_color_match",
                                    "currency": currency,
                                    "denomination": denom,
                                    "year": year,
                                    "side": side,
                                    "variant": f"{side}_{i}",
                                    "color_confidence": round(color_conf, 3),
                                    "confidence": round(color_conf, 3),
                                    "template_path": path
                                }
                        except:
                            continue
    return best_match or {"confidence": 0.0}

def match_currency_dataset(input_image):
    # Create a square image (1:1 ratio) with white padding
    width, height = input_image.size
    target_size = 150
    
    # Calculate the new size maintaining aspect ratio
    if width > height:
        new_width = target_size
        new_height = int(height * (target_size / width))
    else:
        new_height = target_size
        new_width = int(width * (target_size / height))
    
    # Resize the image maintaining aspect ratio
    resized_img = input_image.resize((new_width, new_height))
    
    # Create a new white square image
    square_img = Image.new("RGB", (target_size, target_size), (255, 255, 255))
    
    # Calculate position to paste the resized image (centered)
    paste_x = (target_size - new_width) // 2
    paste_y = (target_size - new_height) // 2
    
    # Paste the resized image onto the white square
    square_img.paste(resized_img, (paste_x, paste_y))
    
    # Save the processed image
    save_path = os.path.join(CROPPING_CURRENCIES_DIR, "input_resized.jpg")
    square_img.save(save_path)
    
    input_resized_rgb = square_img.convert("RGB")
    input_gray = np.array(square_img.convert("L"))

    best_match = None
    best_score = 0
    best_template_path = None

    for currency in os.listdir(CURRENCIES_DIR):
        for denom in os.listdir(os.path.join(CURRENCIES_DIR, currency)):
            for year in os.listdir(os.path.join(CURRENCIES_DIR, currency, denom)):
                for side in ["front", "back"]:
                    side_path = os.path.join(CURRENCIES_DIR, currency, denom, year, side)
                    if not os.path.exists(side_path):
                        continue
                    for filename in os.listdir(side_path):
                        if not filename.lower().endswith((".jpg", ".jpeg", ".png")):
                            continue
                        try:
                            filepath = os.path.join(side_path, filename)
                            template_img = Image.open(filepath).resize((150, 150)).convert("RGB")
                            template_gray = np.array(template_img.convert("L"))

                            ssim_conf = ssim(input_gray, template_gray)
                            hash_conf = compute_hash_similarity(input_resized_rgb, template_img)
                            orb_conf = compute_orb_similarity(input_gray, template_gray)
                            combined = 0.4 * ssim_conf + 0.3 * hash_conf + 0.3 * orb_conf

                            if combined > best_score:
                                best_score = combined
                                best_template_path = filepath
                                best_match = {
                                    "type": "currency_dataset_match",
                                    "currency": currency,
                                    "denomination": denom,
                                    "year": year,
                                    "side": side,
                                    "filename": filename,
                                    "ssim_confidence": round(ssim_conf, 3),
                                    "hash_confidence": round(hash_conf, 3),
                                    "orb_confidence": round(orb_conf, 3),
                                    "confidence": round(combined, 3),
                                    "template_path": filepath
                                }
                        except:
                            continue

    # Save the best matching template image to currencies_results
    if best_template_path:
        result_filename = f"best_match_{os.path.basename(best_template_path)}"
        result_path = os.path.join(CURRENCIES_RESULTS_DIR, result_filename)
        shutil.copy2(best_template_path, result_path)
        if best_match:
            best_match["result_path"] = result_path

    return best_match or {"confidence": 0.0}

def process_currency_image(input_image):
    face_match = match_face_region(input_image)
    color_match = match_face_color_similarity(input_image)
    dataset_match = match_currency_dataset(input_image)

    candidates = [face_match, color_match, dataset_match]
    best = max(candidates, key=lambda x: x.get("confidence", 0.0))

    if best.get("template_path"):
        result_filename = f"overall_best_match_{os.path.basename(best['template_path'])}"
        result_path = os.path.join(CURRENCIES_RESULTS_DIR, result_filename)
        shutil.copy2(best['template_path'], result_path)
        best["result_path"] = result_path

    return best if best else {"confidence": 0.0}