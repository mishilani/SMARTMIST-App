import 'dart:ui';
import 'package:flutter/material.dart';
import 'forecast_pg.dart';
import 'activity_log_pg.dart';
import 'settings_pg.dart';
import 'profile_pg.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatefulWidget {
  final bool isAdmin;

  const Dashboard({super.key, required this.isAdmin});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      ForecastPage(),
      ActivitylogsPage(isAdmin: widget.isAdmin),
      SettingsPage(isAdmin: widget.isAdmin),
      if (widget.isAdmin) ProfilePage(isAdmin: widget.isAdmin),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
        child: pages[currentIndex],
      ),
      bottomNavigationBar: buildNavigation(),
    );
  }

  Widget buildNavigation() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

        child: Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.35),

            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),

          child: NavigationBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,

            indicatorColor: Colors.white.withValues(alpha: 0.35),

            labelTextStyle: WidgetStateProperty.all(
              GoogleFonts.poppins(fontSize: 12, color: Colors.white),
            ),
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                currentIndex = index;
              });
            },

            destinations: [
              const NavigationDestination(
                icon: Icon(CupertinoIcons.cloud_sun),
                label: "Forecast",
              ),

              const NavigationDestination(
                icon: Icon(CupertinoIcons.clock),
                label: "Logs",
              ),

              const NavigationDestination(
                icon: Icon(CupertinoIcons.gear),
                label: "Settings",
              ),

              if (widget.isAdmin)
                const NavigationDestination(
                  icon: Icon(CupertinoIcons.person),
                  label: "Profile",
                ),
            ],
          ),
        ),
      ),
    );
  }
}
