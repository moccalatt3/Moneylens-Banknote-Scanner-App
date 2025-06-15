from flask import Flask, request, jsonify
from PIL import Image
import traceback
from recognizer import process_currency_image

app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "Tidak ada file gambar yang dikirim"}), 400

    file = request.files['image']
    try:
        file.stream.seek(0)
        img = Image.open(file.stream).convert('RGB')  

        result = process_currency_image(img)

        if result.get("confidence", 0) >= 0.7:
            return jsonify(result)

        return jsonify({
            "error": "Tidak ditemukan hasil yang akurat",
            "confidence": result.get("confidence", 0.0),
            "currency": result.get("currency", None),
            "denomination": result.get("denomination", None),
            "year": result.get("year", None),
            "side": result.get("side", None)
        })

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": f"Gagal memproses gambar: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
