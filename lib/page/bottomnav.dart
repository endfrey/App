import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:wstore/page/Order.dart';
import 'package:wstore/page/homepage.dart';
import 'package:wstore/page/profile.dart';
import 'package:wstore/services/shared_pref.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    userId = await SharedPreferenceHelper().getUserID();

    _pages = [
      const Home(),
      const Order(),
      const Profile(),
    ];

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF0F9FF),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF38BDF8), Color(0xFFA5D8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: CurvedNavigationBar(
          height: 65,
          color: Colors.transparent,
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.white,
          animationDuration: const Duration(milliseconds: 350),
          index: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            Icon(Icons.home_outlined,
                color: _currentIndex == 0
                    ? const Color(0xFF0EA5E9)
                    : Colors.white,
                size: 30),
            Icon(Icons.shopping_cart_outlined,
                color: _currentIndex == 1
                    ? const Color(0xFF0EA5E9)
                    : Colors.white,
                size: 30),
            Icon(Icons.person_outline,
                color: _currentIndex == 2
                    ? const Color(0xFF0EA5E9)
                    : Colors.white,
                size: 30),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutCubic,
        child: _pages[_currentIndex],
      ),
    );
  }
}
