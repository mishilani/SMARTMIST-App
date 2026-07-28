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

class WaterManagementPage extends StatefulWidget {
  final bool isAdmin;

  const WaterManagementPage({super.key, required this.isAdmin});

  @override
  State<WaterManagementPage> createState() => _WaterManagementPageState();
}

class _WaterManagementPageState extends State<WaterManagementPage> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  double waterLevel = 0;
  double waterTemp = 0;
  double peltierThreshold = 30;

  String pumpStatus = "OFF";
  String peltierStatus = "OFF";

  bool manualPump = false;
  bool manualPeltier = false;

  bool savedPump = false;
  bool savedPeltier = false;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    listenWaterData();
  }

  void listenWaterData() {
    db.onValue.listen((event) {
      final value = event.snapshot.value;

      if (value != null && value is Map) {
        final data = Map<Object?, Object?>.from(value);

        final sensors = Map<Object?, Object?>.from(
          (data["Sensors"] as Map?) ?? {},
        );

        final status = Map<Object?, Object?>.from(
          (data["Status"] as Map?) ?? {},
        );

        final controls = Map<Object?, Object?>.from(
          (data["Controls"] as Map?) ?? {},
        );

        setState(() {
          waterLevel =
              double.tryParse(sensors["waterLevel"]?.toString() ?? "0") ?? 0;

          waterTemp =
              double.tryParse(sensors["waterTemp"]?.toString() ?? "0") ?? 0;

          pumpStatus = status["pump"]?.toString().toUpperCase() ?? "OFF";

          peltierStatus = status["peltier"]?.toString().toUpperCase() ?? "OFF";

          peltierThreshold =
              double.tryParse(
                controls["peltierThreshold"]?.toString() ?? "30",
              ) ??
              30;

          manualPump = controls["manualPump"] == true;

          manualPeltier = controls["manualPeltier"] == true;

          savedPump = manualPump;
          savedPeltier = manualPeltier;
        });
      }
    });
  }

  String getWaterStatus() {
    if (waterLevel <= 20) {
      return "Low Water Level";
    } else if (waterLevel <= 50) {
      return "Medium Level";
    }

    return "Water Level Normal";
  }

  Color getWaterColor() {
    if (waterLevel <= 20) {
      return Colors.redAccent;
    } else if (waterLevel <= 50) {
      return Colors.orangeAccent;
    }

    return Colors.cyanAccent;
  }

  String getTemperatureStatus() {
    if (waterTemp >= peltierThreshold) {
      return "Cooling Required";
    }

    return "Normal Temperature";
  }

  Color getTemperatureColor() {
    if (waterTemp >= peltierThreshold) {
      return Colors.orangeAccent;
    }

    return Colors.greenAccent;
  }

  Future<void> updateWaterSettings() async {
    setState(() {
      isSaving = true;
    });

    try {
      await db.child("Controls").update({
        "manualPump": manualPump,
        "manualPeltier": manualPeltier,
        "updatedAt": ServerValue.timestamp,
      });

      await LogService.addLog(
        action: "Update",
        category: "Water Management",
        description: "Updated water system controls",
        oldValue:
            "Pump ${savedPump ? "ON" : "OFF"}, "
            "Peltier ${savedPeltier ? "ON" : "OFF"}",
        newValue:
            "Pump ${manualPump ? "ON" : "OFF"}, "
            "Peltier ${manualPeltier ? "ON" : "OFF"}",
      );

      setState(() {
        savedPump = manualPump;
        savedPeltier = manualPeltier;
      });

      AppNotification.show(
        context,
        "Water settings updated",
        color: Colors.green,
        icon: CupertinoIcons.checkmark_circle_fill,
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: "Water Management",
      subtitle: "Monitor water storage and cooling system",
      showBackButton: true,
      child: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  StatusCard(
                    title: widget.isAdmin
                        ? "Administrator Access"
                        : "Viewer Mode",
                    icon: widget.isAdmin
                        ? CupertinoIcons.person_crop_circle_badge_checkmark
                        : CupertinoIcons.lock_fill,
                    value: widget.isAdmin ? "CONTROL ENABLED" : "READ ONLY",
                    label: widget.isAdmin
                        ? "Can manage water system"
                        : "Monitoring only",
                    color: widget.isAdmin
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                  ),

                  const SizedBox(height: 8),

                  SectionCard(
                    color: const Color(0xFF01579B).withValues(alpha: 0.35),
                    icon: CupertinoIcons.drop_fill,
                    title: "Water Tank Level",
                    subtitle: "Current available water capacity",
                    child: SizedBox(
                      height: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${waterLevel.isFinite ? waterLevel.toInt() : 0}%",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  getWaterStatus(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: getWaterColor(),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child: SizedBox(
                                height: 180,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      height:
                                          (waterLevel.clamp(0, 100) / 100) *
                                          105,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: getWaterColor().withValues(
                                          alpha: 0.75,
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              bottom: Radius.circular(15),
                                            ),
                                      ),
                                    ),

                                    Container(
                                      height: 140,
                                      width: 95,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    Positioned(
                                      top: 2,
                                      child: Container(
                                        height: 12,
                                        width: 45,
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 160,
                    child: Row(
                      children: [
                        Expanded(
                          child: SectionCard(
                            color: const Color(
                              0xFF01579B,
                            ).withValues(alpha: 0.35),
                            icon: CupertinoIcons.thermometer,
                            title: "Water Temp",
                            subtitle: "Tank temperature",
                            child: Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${waterTemp.isFinite ? waterTemp.toInt() : 0}°C",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      getTemperatureStatus(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: getTemperatureColor(),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: SectionCard(
                            color: const Color(
                              0xFF01579B,
                            ).withValues(alpha: 0.35),
                            icon: CupertinoIcons.snow,
                            title: "Cooling",
                            subtitle: "Peltier system",
                            child: Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      peltierStatus,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      "Threshold "
                                      "${peltierThreshold.toInt()}°C",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  SectionCard(
                    color: const Color(0xFF01579B).withValues(alpha: 0.35),
                    icon: CupertinoIcons.speedometer,
                    title: "Pump Status",
                    subtitle: "Water circulation system",
                    child: GlassContainer(
                      color: Colors.white.withValues(alpha: 0.20),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.drop_fill,
                            color: pumpStatus == "ON"
                                ? Colors.cyanAccent
                                : Colors.white70,
                            size: 28,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "Pump: $pumpStatus",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (widget.isAdmin)
                    SectionCard(
                      color: const Color(0xFF01579B).withValues(alpha: 0.35),
                      icon: CupertinoIcons.slider_horizontal_3,
                      title: "Manual Controls",
                      subtitle: "Override system operation",
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: Text(
                              "Manual Pump",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            value: manualPump,
                            activeColor: Colors.cyanAccent,
                            onChanged: (value) {
                              setState(() {
                                manualPump = value;
                              });
                            },
                          ),

                          SwitchListTile(
                            title: Text(
                              "Manual Peltier",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            value: manualPeltier,
                            activeColor: Colors.cyanAccent,
                            onChanged: (value) {
                              setState(() {
                                manualPeltier = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : updateWaterSettings,

                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              CupertinoIcons.checkmark_alt_circle_fill,
                              color: Colors.white,
                            ),

                      label: Text(
                        isSaving ? "SAVING..." : "SAVE CHANGES",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),

                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.disabled)) {
                              return const Color(
                                0xFF4FC3F7,
                              ).withValues(alpha: 0.20);
                            }

                            if (states.contains(WidgetState.hovered)) {
                              return const Color(0xFF81D4FA);
                            }

                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF0288D1);
                            }

                            return const Color(0xFF4FC3F7);
                          },
                        ),
                        elevation: WidgetStateProperty.resolveWith<double>((
                          states,
                        ) {
                          if (states.contains(WidgetState.hovered)) {
                            return 12;
                          }

                          return 6;
                        }),

                        shadowColor: WidgetStateProperty.all(
                          Colors.black.withValues(alpha: 0.25),
                        ),

                        overlayColor: WidgetStateProperty.all(
                          const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
