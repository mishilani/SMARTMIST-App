import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smartmist_app/widgets/dashboard_scaffold.dart';
import 'package:smartmist_app/widgets/section_card.dart';
import 'package:smartmist_app/widgets/status_card.dart';
import 'package:smartmist_app/widgets/control_button.dart';
import 'package:smartmist_app/widgets/glass_container.dart';
import 'package:smartmist_app/services/log_service.dart';
import 'package:smartmist_app/widgets/app_notifications.dart';

class MistingThresholdPage extends StatefulWidget {
  final bool isAdmin;

  const MistingThresholdPage({super.key, required this.isAdmin});

  @override
  State<MistingThresholdPage> createState() => _MistingThresholdPageState();
}

class _MistingThresholdPageState extends State<MistingThresholdPage> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  bool isSaving = false;

  double mistThreshold = 33;
  String mode = "AUTO";
  double savedMistThreshold = 33.0;
  String savedMode = "AUTO";
  String pumpStatus = "OFF";

  @override
  void initState() {
    super.initState();
    listenMistingSettings();
  }

  void listenMistingSettings() {
    db.child("Controls").onValue.listen((event) {
      final value = event.snapshot.value;

      if (value != null && value is Map) {
        final data = Map<Object?, Object?>.from(value);

        final firebaseThreshold =
            double.tryParse(data["mistThreshold"]?.toString() ?? "") ?? 33.0;

        final firebaseMode = data["mode"]?.toString().toUpperCase() ?? "AUTO";

        final firebasePump =
            data["pumpCommand"]?.toString().toUpperCase() ?? "OFF";

        setState(() {
          savedMistThreshold = firebaseThreshold;
          savedMode = firebaseMode;
          pumpStatus = firebasePump;
        });
      }
    });
  }

  String getHeatStatus() {
    if (mistThreshold >= 41) {
      return "Critical Heat";
    } else if (mistThreshold >= 33) {
      return "Misting Active";
    }
    return "Normal Temperature";
  }

  IconData getHeatIcon() {
    if (mistThreshold >= 41) {
      return CupertinoIcons.exclamationmark_triangle_fill;
    } else if (mistThreshold >= 33) {
      return CupertinoIcons.drop_fill;
    }
    return CupertinoIcons.snow;
  }

  Color getHeatColor() {
    if (mistThreshold >= 41) {
      return Colors.redAccent;
    } else if (mistThreshold >= 33) {
      return Colors.orangeAccent;
    }
    return Colors.white;
  }

  Future<void> updateSettings() async {
    setState(() {
      isSaving = true;
    });

    try {
      final controlsRef = db.child("Controls");

      final oldSnapshot = await controlsRef.get();

      String oldThreshold = "N/A";
      String oldMode = "N/A";

      if (oldSnapshot.exists) {
        final oldData = Map<Object?, Object?>.from(oldSnapshot.value as Map);

        oldThreshold = "${oldData["mistThreshold"]}°C";
        oldMode = oldData["mode"].toString();
      }

      await controlsRef.update({
        "mistThreshold": mistThreshold.toInt(),
        "mode": mode,
        "updatedAt": ServerValue.timestamp,
      });

      await LogService.addLog(
        action: "Update",
        category: "Misting Control",
        description: "Updated misting threshold settings",
        oldValue: "$oldThreshold ($oldMode)",
        newValue: "${mistThreshold.toInt()}°C ($mode)",
      );

      AppNotification.show(
        context,
        "Misting settings updated",
        color: Colors.green,
        icon: CupertinoIcons.checkmark_circle_fill,
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> updatePump(String command) async {
    await db.child("Controls").update({
      "pumpCommand": command,
      "updatedAt": ServerValue.timestamp,
    });

    await LogService.addLog(
      action: "Manual Control",
      category: "Misting Control",
      description: "Pump manually turned $command",
      oldValue: pumpStatus,
      newValue: command,
    );

    setState(() {
      pumpStatus = command;
    });

    AppNotification.show(
      context,
      "Pump $command",
      color: Colors.green,
      icon: CupertinoIcons.drop_fill,
    );
  }

  Widget modeCard(String title, String description, IconData icon) {
    final selected = mode == title;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: selected ? 1.05 : 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,

          child: MouseRegion(
            cursor: widget.isAdmin
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,

            child: GestureDetector(
              onTap: widget.isAdmin
                  ? () {
                      setState(() {
                        mode = title;
                      });
                    }
                  : null,

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF01579B,
                            ).withValues(alpha: 0.90),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),

                child: GlassContainer(
                  color: selected
                      ? const Color(0xFF0288D1).withValues(alpha: 0.55)
                      : Colors.white.withValues(alpha: 0.20),

                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 250),

                    scale: selected ? 1.05 : 1.0,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),

                          child: Icon(
                            icon,
                            key: ValueKey(selected),
                            color: selected ? Colors.white : Colors.white70,
                            size: selected ? 28 : 22,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),

                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: GoogleFonts.poppins(
                            color: selected ? Colors.white : Colors.white70,
                            fontSize: selected ? 9 : 8,
                          ),

                          child: Text(description, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: "Misting Threshold Settings",
      subtitle: "Configure cooling activation",
      showBackButton: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StatusCard(
                    title: widget.isAdmin
                        ? "Administrator Access"
                        : "Viewer Mode",

                    icon: widget.isAdmin
                        ? CupertinoIcons.person_crop_circle_badge_checkmark
                        : CupertinoIcons.lock_fill,

                    iconColor: Colors.white,

                    value: widget.isAdmin ? "CONTROL ENABLED" : "READ ONLY",
                    label: widget.isAdmin
                        ? "Can modify system settings"
                        : "Monitoring only",

                    color: widget.isAdmin
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                  ),

                  const SizedBox(height: 10),

                  SectionCard(
                    color: const Color(0xFF01579B).withValues(alpha: 0.35),
                    icon: CupertinoIcons.drop_fill,
                    title: "Misting Trigger",
                    subtitle: "Set temperature level before misting starts",
                    child: Column(
                      children: [
                        Text(
                          "${mistThreshold.toInt()}°C",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Activation Temperature",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 1),

                        Slider(
                          value: mistThreshold,
                          min: 25,
                          max: 45,
                          divisions: 20,
                          activeColor: Colors.white,
                          onChanged: widget.isAdmin
                              ? (value) {
                                  setState(() {
                                    mistThreshold = value;
                                  });
                                }
                              : null,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "❄ Normal\n25°C",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: getHeatColor().withValues(alpha: 0.40),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    getHeatIcon(),
                                    color: getHeatColor(),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    getHeatStatus(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              "🔥 Critical\n45°C",
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  SectionCard(
                    color: const Color(0xFF01579B).withValues(alpha: 0.35),
                    icon: CupertinoIcons.gear_alt_fill,
                    title: "Misting Mode",
                    subtitle: "Choose automatic or manual operation",
                    child: Row(
                      children: [
                        Expanded(
                          child: modeCard(
                            "AUTO",
                            "Automatic heat based",
                            CupertinoIcons.gear_alt_fill,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: modeCard(
                            "MANUAL",
                            "User controlled operation",
                            CupertinoIcons.hand_raised_fill,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  SectionCard(
                    color: const Color(0xFF01579B).withValues(alpha: 0.35),
                    icon: CupertinoIcons.chart_bar_alt_fill,
                    title: "Current Configuration",
                    subtitle: "Current Firebase system values",
                    child: Column(
                      children: [
                        GlassContainer(
                          color: Colors.white.withValues(alpha: 0.20),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.gear_alt_fill,
                                color: Color(0xFF4FC3F7),
                              ),

                              const SizedBox(width: 10),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Misting Mode",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),

                                  Text(
                                    savedMode,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        GlassContainer(
                          color: Colors.white.withValues(alpha: 0.20),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.thermometer,
                                color: Colors.orangeAccent,
                              ),

                              const SizedBox(width: 10),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Trigger Temperature",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),

                                  Text(
                                    "${(savedMistThreshold ?? 33).round()}°C",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        GlassContainer(
                          color: Colors.white.withValues(alpha: 0.20),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.drop_fill,
                                color: Colors.cyanAccent,
                              ),

                              const SizedBox(width: 10),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cooling Action",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),

                                  Text(
                                    savedMistThreshold >= 41
                                        ? "Continuous Misting"
                                        : "Intermittent Misting",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
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

                  if (mode == "MANUAL") ...[
                    const SizedBox(height: 10),

                    SectionCard(
                      color: const Color(0xFF01579B).withValues(alpha: 0.35),
                      icon: CupertinoIcons.hand_raised_fill,
                      title: "Manual Misting Control",
                      subtitle: "Direct pump operation",
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ControlButton(
                                  text: "START PUMP",
                                  icon: CupertinoIcons.drop_fill,
                                  enabled: widget.isAdmin,
                                  onPressed: () {
                                    updatePump("ON");
                                  },
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: ControlButton(
                                  text: "STOP PUMP",
                                  icon: CupertinoIcons.stop_fill,
                                  color: Colors.redAccent,
                                  enabled: widget.isAdmin,
                                  onPressed: () {
                                    updatePump("OFF");
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Pump Status: $pumpStatus",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 15),

                  SizedBox(
                    width: 200,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : updateSettings,

                      icon: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              CupertinoIcons.checkmark_alt_circle_fill,
                              color: Colors.white,
                              size: 21,
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

                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
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
        ),
      ),
    );
  }
}
