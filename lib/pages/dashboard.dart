import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activity_log_pg.dart';
import 'controls_pg.dart';
import 'forecast_pg.dart';
import 'settings_pg.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const ForecastPage(),
    const ActivitylogsPage(),
    const SettingsPage(),
  ];

  static const List<Map<String, Object>> navItems = [
    {"icon": CupertinoIcons.cloud_sun, "label": "Forecast"},
    {"icon": CupertinoIcons.clock, "label": "Logs"},
    {"icon": CupertinoIcons.gear, "label": "Settings"},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81D4FA), Color(0xFF0288D1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: IndexedStack(index: currentIndex, children: pages),
      ),
      bottomNavigationBar: buildNavigation(size.width, size.height),
    );
  }

  Widget buildNavigation(double width, double height) {
    final navHeight = height * 0.075;
    final navMargin = height * 0.035;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: navHeight,
          margin: EdgeInsets.symmetric(
            horizontal: width * 0.06,
            vertical: navMargin,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final selected = currentIndex == index;

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    currentIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: selected ? 38 : 28,
                        height: selected ? 38 : 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? const Color(0xFF0288D1)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          navItems[index]["icon"] as IconData,
                          size: 20,
                          color: selected ? Colors.white : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        navItems[index]["label"] as String,
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.027,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
