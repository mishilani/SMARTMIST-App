import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';
import 'package:smartmist_app/widgets/section_card.dart';
import 'package:smartmist_app/widgets/status_card.dart';
import 'package:smartmist_app/widgets/glass_container.dart';
import 'package:smartmist_app/services/log_service.dart';
import 'package:smartmist_app/widgets/app_notifications.dart';
import 'package:smartmist_app/services/notification_service.dart';

class HeatThresholdPage extends StatefulWidget {
  final bool isAdmin;

  const HeatThresholdPage({super.key, required this.isAdmin});

  @override
  State<HeatThresholdPage> createState() => _HeatThresholdPageState();
}

class _HeatThresholdPageState extends State<HeatThresholdPage> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  bool isSaving = false;
  double heatIndexThreshold = 41;
  double savedHeatThreshold = 41;

  @override
  void initState() {
    super.initState();
    listenHeatSettings();
  }

  void listenHeatSettings() {
    db.child("controls").onValue.listen((event) {
      final value = event.snapshot.value;

      if (value != null && value is Map) {
        final data = Map<Object?, Object?>.from(value);

        final firebaseThreshold =
            double.tryParse(data["heatIndexThreshold"]?.toString() ?? "") ?? 41;

        setState(() {
          savedHeatThreshold = firebaseThreshold;
          heatIndexThreshold = firebaseThreshold;
        });
      }
    });
  }

  String getHeatStatus() {
    if (heatIndexThreshold >= 52) {
      return "Extreme Danger";
    } else if (heatIndexThreshold >= 42) {
      return "Danger";
    } else if (heatIndexThreshold >= 33) {
      return "Caution";
    }

    return "Normal";
  }

  String getSavedHeatStatus() {
    if (savedHeatThreshold >= 52) {
      return "Extreme Danger";
    } else if (savedHeatThreshold >= 42) {
      return "Danger";
    } else if (savedHeatThreshold >= 33) {
      return "Caution";
    }

    return "Normal";
  }

  Color getSavedHeatColor() {
    if (savedHeatThreshold >= 52) {
      return Colors.redAccent;
    } else if (savedHeatThreshold >= 42) {
      return Colors.deepOrangeAccent;
    } else if (savedHeatThreshold >= 33) {
      return Colors.orangeAccent;
    }

    return Colors.greenAccent;
  }

  IconData getSavedHeatIcon() {
    if (savedHeatThreshold >= 52) {
      return CupertinoIcons.exclamationmark_triangle_fill;
    } else if (savedHeatThreshold >= 42) {
      return CupertinoIcons.flame_fill;
    } else if (savedHeatThreshold >= 33) {
      return CupertinoIcons.thermometer;
    }

    return CupertinoIcons.snow;
  }

  IconData getHeatIcon() {
    if (heatIndexThreshold >= 52) {
      return CupertinoIcons.exclamationmark_triangle_fill;
    } else if (heatIndexThreshold >= 42) {
      return CupertinoIcons.flame_fill;
    } else if (heatIndexThreshold >= 33) {
      return CupertinoIcons.thermometer;
    }

    return CupertinoIcons.snow;
  }

  IconData getCurrentStatusIcon() {
    if (savedHeatThreshold >= 52) {
      return CupertinoIcons.exclamationmark_octagon_fill;
    } else if (savedHeatThreshold >= 42) {
      return CupertinoIcons.sun_max_fill;
    } else if (savedHeatThreshold >= 33) {
      return CupertinoIcons.thermometer_sun;
    }

    return CupertinoIcons.cloud_snow_fill;
  }

  Color getHeatColor() {
    if (heatIndexThreshold >= 52) {
      return Colors.redAccent;
    } else if (heatIndexThreshold >= 42) {
      return Colors.deepOrangeAccent;
    } else if (heatIndexThreshold >= 33) {
      return Colors.orangeAccent;
    }

    return Colors.greenAccent;
  }

  Future<void> updateSettings() async {
    setState(() {
      isSaving = true;
    });

    try {
      final oldValue = savedHeatThreshold;

      await db.child("controls").update({
        "heatIndexThreshold": heatIndexThreshold.toInt(),
        "updatedAt": ServerValue.timestamp,
      });

      setState(() {
        savedHeatThreshold = heatIndexThreshold;
      });

      await LogService.addLog(
        action: "Update",
        category: "Heat Control",
        description: "Updated heat index threshold",
        oldValue: "${oldValue.toInt()}°C",
        newValue: "${heatIndexThreshold.toInt()}°C",
      );

      AppNotification.show(
        context,
        "Heat settings updated",
        color: Colors.green,
        icon: CupertinoIcons.checkmark_circle_fill,
      );

      await NotificationService.show(
        title: "SMARTMIST",
        body:
            "Heat Index Threshold updated to ${heatIndexThreshold.toInt()}°C.",
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return DashboardScaffold(
      title: "Heat Index Threshold Settings",

      subtitle: "Configure heat warning activation",

      showBackButton: true,

      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),

          child: Column(
            children: [
              StatusCard(
                title: widget.isAdmin ? "Administrator Access" : "Viewer Mode",

                icon: widget.isAdmin
                    ? CupertinoIcons.person_crop_circle_badge_checkmark
                    : CupertinoIcons.lock_fill,

                value: widget.isAdmin ? "CONTROL ENABLED" : "READ ONLY",

                label: widget.isAdmin
                    ? "Can modify system settings"
                    : "Monitoring only",

                color: widget.isAdmin
                    ? Colors.greenAccent
                    : Colors.orangeAccent,
              ),

              SizedBox(height: height * 0.012),

              SectionCard(
                color: const Color(0xFF01579B).withValues(alpha: 0.35),
                icon: CupertinoIcons.thermometer_sun,
                title: "Activation Temperature",
                subtitle: "Set heat level before warning activation",

                child: Column(
                  children: [
                    Text(
                      "${heatIndexThreshold.toInt()}°C",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: width * 0.085,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "Activation Heat Index",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: width * 0.028,
                      ),
                    ),

                    SizedBox(height: height * 0.012),

                    Slider(
                      value: heatIndexThreshold,
                      min: 27,
                      max: 54,
                      divisions: 27,
                      activeColor: Colors.white,
                      onChanged: widget.isAdmin
                          ? (value) {
                              setState(() {
                                heatIndexThreshold = value;
                              });
                            }
                          : null,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text(
                          "❄ Normal\n27°C",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: width * 0.025,
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03,
                            vertical: height * 0.008,
                          ),

                          decoration: BoxDecoration(
                            color: getHeatColor().withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: getHeatColor().withValues(alpha: 0.45),
                            ),
                          ),

                          child: Row(
                            children: [
                              Icon(
                                getHeatIcon(),
                                color: getHeatColor(),
                                size: width * 0.045,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                getHeatStatus(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.025,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          "🔥 Extreme\n54°C",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: width * 0.025,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.012),

              SectionCard(
                color: const Color(0xFF01579B).withValues(alpha: 0.35),
                icon: CupertinoIcons.chart_bar_alt_fill,
                title: "Current Configuration",
                subtitle: "Current Firebase heat settings",
                child: Column(
                  children: [
                    GlassContainer(
                      color: Colors.white.withValues(alpha: 0.18),
                      padding: EdgeInsets.all(width * 0.03),

                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(15),
                            ),

                            child: Icon(
                              getSavedHeatIcon(),
                              color: getSavedHeatColor(),
                              size: width * 0.06,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Heat Index Threshold",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: width * 0.025,
                                ),
                              ),

                              Text(
                                "${savedHeatThreshold.toInt()}°C",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.01),

                    GlassContainer(
                      color: Colors.white.withValues(alpha: 0.18),
                      padding: const EdgeInsets.all(12),

                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: getSavedHeatColor().withValues(
                                alpha: 0.20,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),

                            child: Icon(
                              getCurrentStatusIcon(),
                              color: getSavedHeatColor(),
                              size: width * 0.06,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Current Heat Status",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: width * 0.025,
                                ),
                              ),

                              Text(
                                getSavedHeatStatus(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.018),

              if (widget.isAdmin)
                SizedBox(
                  width: width * 0.55,
                  height: height * 0.065,

                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : updateSettings,

                    icon: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            CupertinoIcons.checkmark_alt_circle_fill,
                            color: Colors.white,
                            size: 22,
                          ),

                    label: Text(
                      isSaving ? "SAVING..." : "SAVE CHANGES",

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.032,
                      ),
                    ),

                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        const Color(0xFF4FC3F7),
                      ),

                      elevation: WidgetStateProperty.all(8),

                      shadowColor: WidgetStateProperty.all(
                        Colors.black.withValues(alpha: 0.25),
                      ),

                      overlayColor: WidgetStateProperty.all(
                        Colors.white.withValues(alpha: 0.15),
                      ),

                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
