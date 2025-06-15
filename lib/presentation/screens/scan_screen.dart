import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../config/env.dart';
import '../styles/fonts.dart';
import 'home_screen.dart';
import 'history_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _image;
  Map<String, dynamic>? _scanResult;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _scanResult = null;
      });
    }
  }

  Future<void> _scanImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Env.backendUrl}/predict'),
      );
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse.containsKey('error')) {
          _showErrorDialog(jsonResponse['error']);
        } else {
          setState(() {
            _scanResult = jsonResponse;
          });
        }
      } else {
        _showErrorDialog(
            'Gagal memproses gambar. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            Text('Error', style: AppFonts.headingStyle.copyWith(fontSize: 20)),
        content: Text(message, style: AppFonts.bodyStyle),
        actions: [
          TextButton(
            child: Text('OK', style: AppFonts.subheadingStyle),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAndResultSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildImagePreview(),
          const SizedBox(height: 25),
          _buildScanResultDisplay(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _image != null
            ? Image.file(
                _image!,
                fit: BoxFit.contain,
              )
            : Center(
                child: Text(
                  'Upload Here...',
                  style: AppFonts.subheadingStyle.copyWith(
                    color: const Color(0xFFB7B7B7),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildScanResultDisplay() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildResultItem(
            value: _scanResult?['currency'] ?? '00',
            label: 'Currency',
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          flex: 2,
          child: _buildResultItem(
            value: _scanResult?['denomination']?.toString() ?? '00',
            label: 'Amount',
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          flex: 3,
          child: _buildResultItem(
            value: _scanResult?['confidence']?.toStringAsFixed(2) ?? '00',
            label: 'Confidence',
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem({
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF2763AF), Color(0xFF3390CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            value,
            style: AppFonts.headingStyle.copyWith(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppFonts.captionStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSingleButton(
          label: "Pilih Gambar",
          imagePath: 'assets/images/icons/image.png',
          onPressed: _pickImage,
        ),
        _buildSingleButton(
          label: _isLoading ? "Memindai..." : "Scanning",
          imagePath: 'assets/images/icons/scanning.png',
          onPressed: _isLoading ? () {} : _scanImage,
        ),
        _buildSingleButton(
          label: "Identifikasi",
          imagePath: 'assets/images/icons/identifikasi.png',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Fitur pemindaian langsung belum tersedia."),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSingleButton({
    required String label,
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppFonts.captionStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          "Scan Currency",
          style: AppFonts.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF1D201E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              _buildImageAndResultSection(),
              const SizedBox(height: 25),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2763AF), Color(0xFF3390CE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const HomeScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Image.asset(
              'assets/images/icons/phone.png',
              width: 32,
              height: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/icons/home2.png',
                      width: 28,
                      color: const Color(0xFFB7B7B7),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const HomeScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF2763AF), Color(0xFF3390CE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      child: Image.asset(
                        'assets/images/icons/scan3.png',
                        width: 32,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      // Stay on Scan screen
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/icons/history2.png',
                      width: 32,
                      color: const Color(0xFFB7B7B7),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const HistoryScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: Image.asset(
                      'assets/images/icons/profil.png',
                      width: 28,
                      color: const Color(0xFFB7B7B7),
                    ),
                    onPressed: () {
                      print('Profile clicked');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
