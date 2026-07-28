import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/pages/misting_threshold_pg.dart';
import 'package:smartmist_app/pages/heat_threshold_pg.dart';
import 'package:smartmist_app/pages/water_management_pg.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';
import 'package:flutter/cupertino.dart';

class SettingsPage extends StatelessWidget {
  final bool isAdmin;

  const SettingsPage({super.key, required this.isAdmin});

  Widget settingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Color(0xFF4FC3F7).withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(25),

        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Material(
          color: Colors.transparent,

          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            splashColor: Colors.white.withValues(alpha: 0.10),
            onTap: onTap,

            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),

              leading: Container(
                width: 50,
                height: 50,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Icon(icon, color: Colors.white, size: 26),
              ),

              title: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              subtitle: Text(
                subtitle,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),

              trailing: const Icon(
                CupertinoIcons.chevron_right,
                color: Colors.white70,
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
    return DashboardScaffold(
      title: "System Settings",
      subtitle: "Configure SMARTMIST parameters",

      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          settingsCard(
            icon: CupertinoIcons.drop_fill,
            title: "Misting Threshold",
            subtitle: isAdmin
                ? 'Adjust mist activation mode'
                : "View mist activaton settings",

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
            icon: CupertinoIcons.thermometer,
            title: "Heat Index Threshold",
            subtitle: isAdmin
                ? 'Adjust heat index levels'
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
            icon: CupertinoIcons.thermometer,
            title: "Water Cooling System",
            subtitle: isAdmin
                ? 'Manage water temperature and Peltier'
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
              icon: CupertinoIcons.arrow_right_square,
              title: "Go to Welcome Page",
              subtitle: "",

              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
        ],
      ),
    );
  }
}
