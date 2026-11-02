import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';
import 'package:smartmist_app/widgets/section_card.dart';
import 'package:smartmist_app/widgets/glass_container.dart';
import 'package:smartmist_app/widgets/app_notifications.dart';

class MistingControlPage extends StatefulWidget {
  const MistingControlPage({super.key});

  @override
  State<MistingControlPage> createState() => _MistingControlPageState();
}

class _MistingControlPageState extends State<MistingControlPage> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  StreamSubscription<DatabaseEvent>? _controlsSub;
  StreamSubscription<DatabaseEvent>? _sensorSub;
  StreamSubscription<DatabaseEvent>? _statusSub;
  StreamSubscription<DatabaseEvent>? _offsetSub;
  Timer? _ticker;
  int _serverOffsetMs = 0;

  String mode = "AUTO";
  String command = "OFF";
  Map<dynamic, dynamic> sensor = {};
  num? startThreshold;
  num? stopThreshold;
  bool busy = false;

  @override
  void initState() {
    super.initState();

    _controlsSub = db.child("controls").onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is! Map || !mounted) return;

      setState(() {
        mode = (v["mode"] ?? "AUTO").toString().toUpperCase();
        command = (v["zone1Command"] ?? "OFF").toString().toUpperCase();
      });
    }, onError: (e) => debugPrint("controls stream error: $e"));

    _sensorSub = db.child("sensor").onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is! Map || !mounted) return;

      setState(() {
        sensor = Map<dynamic, dynamic>.from(v);
      });
    }, onError: (e) => debugPrint("sensor stream error: $e"));

    _statusSub = db.child("status/thresholds").onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is! Map || !mounted) return;

      setState(() {
        startThreshold = v["start"] is num ? v["start"] as num : null;
        stopThreshold = v["stop"] is num ? v["stop"] as num : null;
      });
    }, onError: (e) => debugPrint("status stream error: $e"));

    _offsetSub = FirebaseDatabase.instance
        .ref(".info/serverTimeOffset")
        .onValue
        .listen((event) {
          final v = event.snapshot.value;
          if (v is num && mounted) {
            setState(() => _serverOffsetMs = v.toInt());
          }
        });

    _ticker = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controlsSub?.cancel();
    _sensorSub?.cancel();
    _statusSub?.cancel();
    _offsetSub?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  bool get online {
    final last = sensor["lastUpdate"];
    final now = DateTime.now().millisecondsSinceEpoch + _serverOffsetMs;
    return last is num && now - last.toInt() < 20000;
  }

  bool get tankOk => sensor["waterAvailable"] == true;

  bool get isManual => mode == "MANUAL";

  Map<dynamic, dynamic> zoneData(int zone) {
    final z = sensor["zone$zone"];
    return z is Map ? Map<dynamic, dynamic>.from(z) : <dynamic, dynamic>{};
  }

  // zone 2 (control) only exists when its DHT22 is installed
  bool get hasZone2 => zoneData(2).isNotEmpty;

  String _fmt(dynamic v, [String suffix = ""]) =>
      v is num ? "${v.toStringAsFixed(1)}$suffix" : "—";

  // ---------------- commands ----------------

  void _notify(String message, {bool error = false}) {
    if (!mounted) return;
    AppNotification.show(
      context,
      message,
      color: error ? Colors.red : Colors.green,
      icon: error
          ? CupertinoIcons.exclamationmark_circle_fill
          : CupertinoIcons.checkmark_circle_fill,
    );
  }

  Future<void> _setMode(String newMode) async {
    if (newMode == mode || busy) return;

    final oldMode = mode;
    final oldCommand = command;

    setState(() {
      busy = true;
      mode = newMode;
      command = "OFF";
    });

    try {
      await db.child("controls").update({
        "mode": newMode,
        "zone1Command": "OFF",
        "updatedAt": ServerValue.timestamp,
      });
      _notify("Mode set to $newMode");
    } catch (e) {
      debugPrint("Mode change failed: $e");
      if (mounted) {
        setState(() {
          mode = oldMode;
          command = oldCommand;
        });
      }
      _notify("Could not change mode: $e", error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _confirmModeChange(String newMode) async {
    if (newMode == mode) return;

    final toManual = newMode == "MANUAL";

    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => _ModeConfirmDialog(
        icon: toManual
            ? CupertinoIcons.hand_raised_fill
            : CupertinoIcons.gear_alt_fill,
        title: toManual ? "Switch to Manual?" : "Switch to Auto?",
        message: toManual
            ? "Automatic misting will stop and misting will turn off. "
                  "You will need to start it yourself."
            : "Misting you started manually will stop. Zone 1 will then "
                  "mist by itself based on its own heat index.",
        confirmLabel: toManual ? "Switch to Manual" : "Switch to Auto",
      ),
    );

    debugPrint("Mode change to $newMode confirmed: $confirmed");
    if (confirmed != true || !mounted) return;
    await _setMode(newMode);
  }

  Future<void> _sendMist(String cmd) async {
    final old = command;
    setState(() => command = cmd);

    try {
      await db.child("controls").update({
        "zone1Command": cmd,
        "updatedAt": ServerValue.timestamp,
      });
      _notify(cmd == "ON" ? "Misting started" : "Misting stopped");
    } catch (e) {
      debugPrint("Mist command failed: $e");
      if (mounted) setState(() => command = old);
      _notify("Could not send command to Zone 1", error: true);
    }
  }

  Widget modeCard(
    String title,
    String description,
    IconData icon,
    double width,
  ) {
    final selected = mode == title;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: selected ? 1.05 : 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => _confirmModeChange(title),
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
        );
      },
    );
  }

  Widget infoTile(
    IconData icon,
    Color iconColor,
    String label,
    String value,
    double width, {
    bool warn = false,
  }) {
    return GlassContainer(
      color: Colors.white.withValues(alpha: 0.20),
      padding: EdgeInsets.all(width * 0.025),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          SizedBox(width: width * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: width * 0.025,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: warn ? const Color(0xFFFFCDD2) : Colors.white,
                    fontSize: width * 0.038,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget offlineBanner(double width) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: width * 0.03),
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.wifi_slash,
            color: Colors.white,
            size: width * 0.055,
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              "Device offline. Showing last known data; commands will not "
              "reach the system. In Auto, the ESP32 keeps misting on its own "
              "and logs sessions until it reconnects.",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: width * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget zoneTile(int zone, double width, double height) {
    final controllable = zone == 1;
    final data = zoneData(zone);
    final sensorOk = data["sensorOk"] == true;
    final misting = controllable && data["mistingStatus"] == "ON";

    final requested = controllable && command == "ON";
    final running = misting || requested;

    final canStart = isManual && online && tankOk && !running;
    final canStop = isManual && online && running;

    final String? blockedReason = !online
        ? "Device is offline"
        : !tankOk
        ? "Tank is low"
        : null;

    final statusColor = !online
        ? Colors.orangeAccent
        : !sensorOk
        ? Colors.redAccent
        : misting
        ? Colors.greenAccent
        : Colors.white70;
    final statusText = !online
        ? "OFFLINE"
        : !sensorOk
        ? "SENSOR ERROR"
        : misting
        ? "MISTING"
        : (controllable ? "IDLE" : "MONITORING");

    return GlassContainer(
      color: Colors.white.withValues(alpha: 0.18),
      padding: EdgeInsets.all(width * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  controllable ? "Zone 1 • Misted" : "Zone 2 • No mist",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.04,
                  ),
                ),
              ),
              Text(
                statusText,
                style: GoogleFonts.poppins(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.028,
                ),
              ),
            ],
          ),
          Text(
            sensorOk
                ? "${online ? "" : "Last known: "}"
                      "Heat index ${_fmt(data["heatIndex"], "°C")}  •  "
                      "${_fmt(data["temperature"], "°C")}  •  "
                      "${_fmt(data["humidity"], "%")}"
                : "No sensor reading",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: width * 0.027,
            ),
          ),
          if (isManual && controllable) ...[
            SizedBox(height: height * 0.014),
            Row(
              children: [
                Expanded(
                  child: _CommandButton(
                    label: misting
                        ? "MISTING"
                        : requested
                        ? "STARTING…"
                        : "START",
                    icon: CupertinoIcons.drop_fill,
                    color: const Color(0xFF00C853),
                    width: width,
                    active: running,
                    enabled: canStart,
                    onTap: () => _sendMist("ON"),
                    onBlockedTap: () {
                      if (blockedReason != null) {
                        _notify(blockedReason, error: true);
                      }
                    },
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: _CommandButton(
                    label: "STOP",
                    icon: CupertinoIcons.stop_fill,
                    color: const Color(0xFFE53935),
                    width: width,
                    active: !running,
                    enabled: canStop,
                    onTap: () => _sendMist("OFF"),
                    onBlockedTap: () {},
                  ),
                ),
              ],
            ),
            if (blockedReason != null)
              Padding(
                padding: EdgeInsets.only(top: height * 0.008),
                child: Text(
                  "START disabled: $blockedReason",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFCDD2),
                    fontSize: width * 0.027,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _autoView(double width, double height) {
    return Column(
      key: const ValueKey("auto-view"),
      children: [
        SectionCard(
          color: const Color(0xFF01579B).withValues(alpha: 0.35),
          icon: CupertinoIcons.thermometer_sun,
          title: "Misting Trigger",
          subtitle: "Fixed by the system, cannot be changed",
          child: Column(
            children: [
              infoTile(
                CupertinoIcons.drop_fill,
                Colors.cyanAccent,
                "Zone 1 starts misting at",
                startThreshold != null
                    ? "≥ ${startThreshold!.toStringAsFixed(0)}°C heat index"
                    : "—",
                width,
              ),
              SizedBox(height: height * 0.01),
              infoTile(
                CupertinoIcons.stop_fill,
                Colors.orangeAccent,
                "Zone 1 stops misting at",
                stopThreshold != null
                    ? "≤ ${stopThreshold!.toStringAsFixed(0)}°C heat index"
                    : "—",
                width,
              ),
            ],
          ),
        ),
        SizedBox(height: height * 0.012),
        SectionCard(
          color: const Color(0xFF01579B).withValues(alpha: 0.35),
          icon: CupertinoIcons.square_grid_2x2_fill,
          title: "Zones",
          subtitle: hasZone2
              ? "Misted zone and comparison zone"
              : "Live readings for the misted zone",
          child: Column(
            children: [
              zoneTile(1, width, height),
              SizedBox(height: height * 0.01),
              if (hasZone2) ...[
                zoneTile(2, width, height),
                SizedBox(height: height * 0.01),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _manualView(double width, double height) {
    return Column(
      key: const ValueKey("manual-view"),
      children: [
        SectionCard(
          color: const Color(0xFF01579B).withValues(alpha: 0.35),
          icon: CupertinoIcons.hand_raised_fill,
          title: "Manual Misting Control",
          subtitle: "Start or stop misting in Zone 1",
          child: Column(
            children: [
              zoneTile(1, width, height),
              SizedBox(height: height * 0.01),
              if (hasZone2) ...[
                zoneTile(2, width, height),
                SizedBox(height: height * 0.01),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return DashboardScaffold(
      title: "Controls",
      subtitle: "Mode, misting and system status",
      showBackButton: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (!online) offlineBanner(width),

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
                            "Zone 1 mists by its own heat index",
                            CupertinoIcons.gear_alt_fill,
                            width,
                          ),
                        ),
                        SizedBox(width: width * 0.05),
                        Expanded(
                          child: modeCard(
                            "MANUAL",
                            "You start and stop misting",
                            CupertinoIcons.hand_raised_fill,
                            width,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.012),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: isManual
                        ? _manualView(width, height)
                        : _autoView(width, height),
                  ),

                  SizedBox(height: height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double width;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onBlockedTap;

  const _CommandButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.width,
    required this.active,
    required this.enabled,
    required this.onTap,
    required this.onBlockedTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;

    if (active) {
      bg = color;
      fg = Colors.white;
    } else if (enabled) {
      bg = Colors.white.withValues(alpha: 0.12);
      fg = Colors.white;
    } else {
      bg = Colors.white.withValues(alpha: 0.08);
      fg = Colors.white38;
    }

    return GestureDetector(
      onTap: enabled ? onTap : onBlockedTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: width * 0.14,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(width * 0.07),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: width * 0.05),
            SizedBox(width: width * 0.02),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: width * 0.036,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;

  const _ModeConfirmDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: width * 0.08),
      child: Container(
        padding: EdgeInsets.all(width * 0.055),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0288D1), Color(0xFF01579B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(width * 0.07),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width * 0.14,
              height: width * 0.14,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(width * 0.045),
              ),
              child: Icon(icon, color: Colors.white, size: width * 0.07),
            ),
            SizedBox(height: width * 0.04),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: width * 0.047,
              ),
            ),
            SizedBox(height: width * 0.02),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: width * 0.032,
              ),
            ),
            SizedBox(height: width * 0.05),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: width * 0.035),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.04),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: width * 0.034,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0288D1),
                      padding: EdgeInsets.symmetric(vertical: width * 0.035),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.07),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: width * 0.032,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
