import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/pages/heat_threshold_pg.dart';
import 'package:smartmist_app/pages/misting_threshold_pg.dart';
import 'package:smartmist_app/pages/water_management_pg.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';

class SettingsPage extends StatelessWidget {
  final bool isAdmin;

  const SettingsPage({super.key, required this.isAdmin});

  Widget settingsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Container(
      margin: EdgeInsets.only(bottom: width * 0.035),
      decoration: BoxDecoration(
        color: const Color(0xFF4FC3F7).withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(width * 0.06),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: width * 0.04,
            offset: Offset(0, width * 0.02),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.06),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(width * 0.06),
            splashColor: Colors.white.withValues(alpha: 0.10),
            onTap: onTap,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: width * 0.02,
              ),
              leading: Container(
                width: width * 0.13,
                height: width * 0.13,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(width * 0.045),
                ),
                child: Icon(icon, color: Colors.white, size: width * 0.065),
              ),
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.04,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: width * 0.03,
                ),
              ),
              trailing: Icon(
                CupertinoIcons.chevron_right,
                color: Colors.white70,
                size: width * 0.055,
              ),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return DashboardScaffold(
      title: "System Settings",
      subtitle: "Configure SMARTMIST parameters",
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.045,
          vertical: height * 0.025,
        ),
        children: [
          SizedBox(height: height * 0.015),
          settingsCard(
            context: context,
            icon: CupertinoIcons.drop_fill,
            title: "Misting Threshold",
            subtitle: isAdmin
                ? "Adjust mist activation mode"
                : "View mist activation settings",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MistingThresholdPage(isAdmin: isAdmin),
                ),
              );
            },
          ),
          settingsCard(
            context: context,
            icon: CupertinoIcons.thermometer,
            title: "Heat Index Threshold",
            subtitle: isAdmin
                ? "Adjust heat index levels"
                : "View heat index settings",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HeatThresholdPage(isAdmin: isAdmin),
                ),
              );
            },
          ),
          settingsCard(
            context: context,
            icon: CupertinoIcons.drop_fill,
            title: "Water Cooling System",
            subtitle: isAdmin
                ? "Manage water temperature and Peltier"
                : "View water level, temperature, and cooling status",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WaterManagementPage(isAdmin: isAdmin),
                ),
              );
            },
          ),
          if (!isAdmin)
            settingsCard(
              context: context,
              icon: CupertinoIcons.arrow_right_square,
              title: "Go to Welcome Page",
              subtitle: "Return to main page",
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
        ],
      ),
    );
  }
}
