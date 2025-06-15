import 'package:flutter/material.dart';
import '../styles/fonts.dart';
import 'home_screen.dart';
import 'scan_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> scanHistory = [
      {
        'image': 'assets/images/screens/rupiah.jpg',
        'amount': 'Rp 53.000',
        'country': 'Indonesia',
        'date': 'Apr 14, 2024',
        'status': 'Accuracy',
      },
      {
        'image': 'assets/images/screens/rupiah2.jpg',
        'amount': 'Rp 20.000',
        'country': 'Indonesia',
        'date': 'Apr 14, 2024',
        'status': 'Accuracy',
      },
      {
        'image': 'assets/images/screens/rupiah3.jpg',
        'amount': 'Rp 100.000',
        'country': 'Indonesia',
        'date': 'Apr 14, 2024',
        'status': 'Accuracy',
      },
      {
        'image': 'assets/images/screens/rupiah4.jpg',
        'amount': 'Rp 10.000',
        'country': 'Indonesia',
        'date': 'Apr 14, 2024',
        'status': 'Accuracy',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History",
          style: AppFonts.headingStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1D201E),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            const SizedBox(height: 35),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Recently Scanned",
                style: AppFonts.subheadingStyle.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: ListView.separated(
                itemCount: scanHistory.length,
                separatorBuilder: (context, index) => const SizedBox(height: 3),
                itemBuilder: (context, index) {
                  final item = scanHistory[index];
                  final cleanAmount = item['amount']
                      .toString()
                      .replaceAll(RegExp(r'[^\d]'), '');
                  final amountInDouble = double.tryParse(cleanAmount) ?? 0;
                  final convertedUSD = amountInDouble / 15800;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            item['image'],
                            width: 105,
                            height: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Color(0xFF2763AF),
                                    Color(0xFF3390CE)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  item['amount'],
                                  style: AppFonts.bodyStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '~ USD ${convertedUSD.toStringAsFixed(2)}',
                                style: AppFonts.captionStyle.copyWith(
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item['country'],
                                            style: AppFonts.bodyStyle),
                                        Text(item['date'],
                                            style: AppFonts.captionStyle),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item['status'],
                                      style: AppFonts.bodyStyle.copyWith(
                                        color: const Color(0xFF1D201E),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const ScanScreen(),
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
        notchMargin: 8,
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
                    icon: Image.asset(
                      'assets/images/icons/scan3.png',
                      width: 32,
                      color: const Color(0xFFB7B7B7),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const ScanScreen(),
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
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF2763AF), Color(0xFF3390CE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: Image.asset(
                        'assets/images/icons/history2.png',
                        width: 32,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      // Stay di History Screen
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
