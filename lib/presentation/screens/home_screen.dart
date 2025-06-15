import 'package:flutter/material.dart';
import '../styles/fonts.dart';
import 'history_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D201E),
                    image: DecorationImage(
                      image: AssetImage('assets/images/screens/background.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundImage:
                                AssetImage('assets/images/screens/warga.jpeg'),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Welcome back,",
                                  style: AppFonts.bodyStyle
                                      .copyWith(color: Colors.white)),
                              Text("Elip Ganteng",
                                  style: AppFonts.headingStyle
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                          const Spacer(),
                          Image.asset(
                            'assets/images/icons/lang.png',
                            width: 26,
                            height: 26,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                style: AppFonts.bodyStyle.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF1D201E),
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Search something here...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
                const SizedBox(height: 90),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recent Scans",
                          style: AppFonts.subheadingStyle
                              .copyWith(color: const Color(0xFF1D201E))),
                      Text("Show all",
                          style:
                              AppFonts.bodyStyle.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.asset(
                            'assets/images/screens/rupiah2.jpg',
                            fit: BoxFit.cover,
                            height: 150,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Rp 50.000",
                                      style: AppFonts.bodyStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: const Color(0xFF1D201E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "~ USD 3.12",
                                      style: AppFonts.bodyStyle.copyWith(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Indonesia",
                                      style: AppFonts.bodyStyle.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F0FE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: Color(0xFF3592CF),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 210,
              left: 24,
              right: 24,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _quickAction(
                        context, 'assets/images/icons/scan.png', "Scan", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanScreen(),
                        ),
                      );
                    }),
                    _quickAction(
                        context, 'assets/images/icons/history.png', "History",
                        () {
                      if (_isNavigating) return;
                      setState(() => _isNavigating = true);
                      Navigator.of(context).push(_createFadeRoute()).then((_) {
                        setState(() => _isNavigating =
                            false); 
                      });
                    }),
                    _quickAction(
                        context, 'assets/images/icons/dark.png', "Dark Mode",
                        () {
                      // Aksi untuk dark mode
                      _showAlert(context);
                    }),
                    _quickAction(
                        context, 'assets/images/icons/more.png', "More", () {
                      // Aksi untuk more
                      _showAlert(context);
                    }),
                  ],
                ),
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
                    icon: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF2763AF), Color(0xFF3390CE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      child: Image.asset(
                        'assets/images/icons/home2.png',
                        width: 28,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
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
                      Navigator.of(context).push(
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
                    icon: Image.asset(
                      'assets/images/icons/history2.png',
                      width: 32,
                      color: const Color(0xFFB7B7B7),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
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

  void _showAlert(BuildContext context) {
    final overlay =
        Overlay.of(context); // Mengakses Overlay untuk menambahkan alert
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 80, // Mengatur posisi alert di atas layar
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent, // Transparan agar tidak mengganggu UI
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1D201E),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              // Menggunakan Center untuk memusatkan teks
              child: Text(
                "Fitur belum ada",
                style: AppFonts.subheadingStyle.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    // Menambahkan alert ke Overlay
    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Widget _quickAction(BuildContext context, String iconPath, String label,
      VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(
              iconPath,
              width: 36,
              height: 36,
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: AppFonts.bodyStyle),
        ],
      ),
    );
  }

  Route _createFadeRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const HistoryScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
          child: child,
        );
      },
    );
  }
}
