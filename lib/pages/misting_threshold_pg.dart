import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/services/notification_service.dart';
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
  String pumpCommand = "OFF";
  bool _pumpCommandInitialized = false;

  @override
  void initState() {
    super.initState();
    listenMistingSettings();
  }

  void listenMistingSettings() {
    db.child("controls").onValue.listen((event) {
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
          mistThreshold = firebaseThreshold;
          savedMode = firebaseMode;
          mode = firebaseMode;
          pumpStatus = firebasePump;
          if (!_pumpCommandInitialized) {
            pumpCommand = firebasePump;
            _pumpCommandInitialized = true;
          }
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

  Color getPumpColor(String status) {
    return status == "ON" ? const Color(0xFF1976D2) : const Color(0xFFC62828);
  }

  IconData getPumpIcon(String status) {
    return status == "ON" ? CupertinoIcons.drop_fill : CupertinoIcons.stop_fill;
  }

  bool get hasUnsavedPumpChange => pumpCommand != pumpStatus;

  Future<void> updateSettings() async {
    setState(() {
      isSaving = true;
    });

    try {
      final controlsRef = db.child("controls");
      final oldThreshold = "${savedMistThreshold.round()}°C";
      final oldMode = savedMode;
      final oldPump = pumpStatus;

      await controlsRef.update({
        "mistThreshold": mistThreshold.toInt(),
        "mode": mode,
        "pumpCommand": pumpCommand,
        "updatedAt": ServerValue.timestamp,
      });

      AppNotification.show(
        context,
        "Misting settings updated",
        color: Colors.green,
        icon: CupertinoIcons.checkmark_circle_fill,
      );
      await Future.wait([
        LogService.addLog(
          action: "Update",
          category: "Misting Control",
          description: "Updated misting threshold settings",
          oldValue: "$oldThreshold ($oldMode, Pump: $oldPump)",
          newValue: "${mistThreshold.toInt()}°C ($mode, Pump: $pumpCommand)",
        ),
        NotificationService.show(
          title: "SMARTMIST",
          body:
              "Misting settings updated.\nThreshold: ${mistThreshold.toInt()}°C\nMode: $mode\nPump: $pumpCommand",
        ),
      ]);
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  void selectPumpCommand(String command) {
    setState(() {
      pumpCommand = command;
    });
  }

  Widget modeCard(
    String title,
    String description,
    IconData icon,
    double width,
  ) {
    final selected = widget.isAdmin ? mode == title : savedMode == title;

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
                            size: selected ? width * 0.07 : width * 0.055,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.03,
                          ),
                        ),

                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: GoogleFonts.poppins(
                            color: selected ? Colors.white : Colors.white70,
                            fontSize: selected ? width * 0.023 : width * 0.020,
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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

                  SizedBox(height: height * 0.012),

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
                            fontSize: width * 0.10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Activation Temperature",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: width * 0.028,
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
                                fontSize: width * 0.025,
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.025,
                                vertical: height * 0.007,
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
                                    size: width * 0.038,
                                  ),
                                  const SizedBox(width: 5),
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
                              "🔥 Critical\n45°C",
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
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
                            width,
                          ),
                        ),

                        SizedBox(width: width * 0.05),

                        Expanded(
                          child: modeCard(
                            "MANUAL",
                            "User control + heat trigger",
                            CupertinoIcons.hand_raised_fill,
                            width,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.012),

                  SectionCard(
                    color: const Color(0xFF01579B).withValues(alpha: 0.35),
                    icon: CupertinoIcons.chart_bar_alt_fill,
                    title: "Current Configuration",
                    subtitle: "Current Firebase system values",
                    child: Column(
                      children: [
                        GlassContainer(
                          color: Colors.white.withValues(alpha: 0.20),
                          padding: EdgeInsets.all(width * 0.025),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.gear_alt_fill,
                                color: Color(0xFF4FC3F7),
                              ),

                              SizedBox(width: width * 0.025),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Misting Mode",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: width * 0.025,
                                    ),
                                  ),

                                  Text(
                                    savedMode,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: width * 0.038,
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
                          color: Colors.white.withValues(alpha: 0.20),
                          padding: EdgeInsets.all(width * 0.025),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.thermometer,
                                color: Colors.orangeAccent,
                              ),

                              SizedBox(width: width * 0.025),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Trigger Temperature",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: width * 0.025,
                                    ),
                                  ),

                                  Text(
                                    "${savedMistThreshold.round()}°C",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: width * 0.038,
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
                          color: Colors.white.withValues(alpha: 0.20),
                          padding: EdgeInsets.all(width * 0.025),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.drop_fill,
                                color: Colors.cyanAccent,
                              ),

                              SizedBox(width: width * 0.025),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cooling Action",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: width * 0.025,
                                    ),
                                  ),

                                  Text(
                                    (widget.isAdmin ? mode : savedMode) ==
                                            "AUTO"
                                        ? "Starts when heat index reaches threshold"
                                        : "Manual control + threshold activation",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: width * 0.028,
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

                  if ((widget.isAdmin ? mode : savedMode) == "MANUAL") ...[
                    SizedBox(height: height * 0.012),

                    SectionCard(
                      color: const Color(0xFF01579B).withValues(alpha: 0.35),
                      icon: CupertinoIcons.hand_raised_fill,
                      title: "Manual Misting Control",
                      subtitle: "Direct pump operation",
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.035,
                              vertical: height * 0.012,
                            ),
                            decoration: BoxDecoration(
                              color: getPumpColor(
                                pumpStatus,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: getPumpColor(
                                  pumpStatus,
                                ).withValues(alpha: 0.55),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  getPumpIcon(pumpStatus),
                                  color: getPumpColor(pumpStatus),
                                  size: width * 0.06,
                                ),
                                SizedBox(width: width * 0.03),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Current Status",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: width * 0.026,
                                        ),
                                      ),
                                      Text(
                                        pumpStatus == "ON"
                                            ? "Pump Running"
                                            : "Pump Stopped",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.034,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: height * 0.016),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Send Command",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: width * 0.028,
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.008),

                          Row(
                            children: [
                              Expanded(
                                child: _PumpCommandButton(
                                  command: "ON",
                                  label: "START",
                                  icon: CupertinoIcons.drop_fill,
                                  color: const Color(0xFF1976D2),
                                  width: width,
                                  isSelected: pumpCommand == "ON",
                                  enabled: widget.isAdmin,
                                  onSelect: selectPumpCommand,
                                ),
                              ),

                              SizedBox(width: width * 0.025),

                              Expanded(
                                child: _PumpCommandButton(
                                  command: "OFF",
                                  label: "STOP",
                                  icon: CupertinoIcons.stop_fill,
                                  color: const Color(0xFFC62828),
                                  width: width,
                                  isSelected: pumpCommand == "OFF",
                                  enabled: widget.isAdmin,
                                  onSelect: selectPumpCommand,
                                ),
                              ),
                            ],
                          ),

                          if (hasUnsavedPumpChange) ...[
                            SizedBox(height: height * 0.014),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.03,
                                vertical: height * 0.009,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amberAccent.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.amberAccent.withValues(
                                    alpha: 0.6,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.exclamationmark_circle_fill,
                                    color: Colors.amberAccent,
                                    size: width * 0.038,
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Expanded(
                                    child: Text(
                                      "Unsaved: pump will turn ${pumpCommand == "ON" ? "ON" : "OFF"} after you tap SAVE CHANGES",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: width * 0.026,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: height * 0.018),

                  if (widget.isAdmin)
                    SizedBox(
                      width: width * 0.55,
                      height: height * 0.065,

                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : updateSettings,

                        icon: isSaving
                            ? SizedBox(
                                width: width * 0.055,
                                height: width * 0.055,
                                child: const CircularProgressIndicator(
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
                            fontSize: width * 0.032,
                          ),
                        ),

                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            const Color(0xFF4FC3F7),
                          ),

                          elevation: WidgetStateProperty.all(6),

                          shadowColor: WidgetStateProperty.all(
                            Colors.black.withValues(alpha: 0.25),
                          ),

                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: height * 0.012),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PumpCommandButton extends StatefulWidget {
  final String command;
  final String label;
  final IconData icon;
  final Color color;
  final double width;
  final bool isSelected;
  final bool enabled;
  final ValueChanged<String> onSelect;

  const _PumpCommandButton({
    required this.command,
    required this.label,
    required this.icon,
    required this.color,
    required this.width,
    required this.isSelected,
    required this.enabled,
    required this.onSelect,
  });

  @override
  State<_PumpCommandButton> createState() => _PumpCommandButtonState();
}

class _PumpCommandButtonState extends State<_PumpCommandButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final scale = _pressed ? 0.94 : (isSelected ? 1.03 : 1.0);

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.enabled ? () => widget.onSelect(widget.command) : null,
      child: AnimatedScale(
        scale: scale,
        duration: Duration(milliseconds: _pressed ? 80 : 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.width * 0.06),
            border: Border.all(
              color: isSelected ? widget.color : Colors.transparent,
              width: isSelected ? 3 : 0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: widget.color.withValues(
                        alpha: _pressed ? 0.85 : 0.65,
                      ),
                      blurRadius: _pressed ? 16 : 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),

          padding: const EdgeInsets.all(2),

          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _pressed ? 0.75 : (isSelected ? 1.0 : 0.60),

            child: ControlButton(
              text: widget.label,
              icon: widget.icon,
              color: widget.color,
              enabled: widget.enabled,
              onPressed: () => widget.onSelect(widget.command),
            ),
          ),
        ),
      ),
    );
  }
}
