import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';


class ControlsPage extends StatelessWidget {
  const ControlsPage({super.key});

  static DatabaseReference get _controlsRef =>
      FirebaseDatabase.instance.ref('controls');

  static DatabaseReference get _sensorRef =>
      FirebaseDatabase.instance.ref('sensor');

  static DatabaseReference get _statusRef =>
      FirebaseDatabase.instance.ref('status');

  Map<dynamic, dynamic> _map(dynamic v) =>
      v is Map ? Map<dynamic, dynamic>.from(v) : <dynamic, dynamic>{};

  String _fmt(dynamic v, [String suffix = '']) =>
      v is num ? '${v.toStringAsFixed(1)}$suffix' : '—';


  Future<void> _setMode(String mode) {
    return _controlsRef.update({
      'mode': mode,
      'zone1Command': 'OFF',
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> _setMist(String command) {
    return _controlsRef.update({
      'zone1Command': command,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> _send(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not send command: $e')));
    }
  }



  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: "Controls",
      subtitle: "Mode, misting and system status",
      showBackButton: true,
      child: StreamBuilder<DatabaseEvent>(
        stream: _controlsRef.onValue,
        builder: (context, cSnap) {
          return StreamBuilder<DatabaseEvent>(
            stream: _sensorRef.onValue,
            builder: (context, sSnap) {
              return StreamBuilder<DatabaseEvent>(
                stream: _statusRef.onValue,
                builder: (context, stSnap) {
                  if (!cSnap.hasData || !sSnap.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  return _body(
                    context,
                    _map(cSnap.data!.snapshot.value),
                    _map(sSnap.data!.snapshot.value),
                    _map(stSnap.data?.snapshot.value),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    Map<dynamic, dynamic> controls,
    Map<dynamic, dynamic> sensor,
    Map<dynamic, dynamic> status,
  ) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final mode = (controls['mode'] ?? 'AUTO').toString().toUpperCase();
    final isManual = mode == 'MANUAL';

    final lastUpdate = sensor['lastUpdate'];
    final online =
        lastUpdate is num &&
        DateTime.now().millisecondsSinceEpoch - lastUpdate.toInt() < 20000;

    final tankOk = sensor['waterAvailable'] == true;
    final thresholds = _map(status['thresholds']);


    final devices = _map(sensor['devices']);
    final pumpOn = devices['pump'] == true;
    final peltiersOn =
        devices['peltier1'] == true || devices['peltier2'] == true;
    final fansOn = devices['fan1'] == true || devices['fan2'] == true;

    // zone 2 (control) is optional
    final zone2 = _map(sensor['zone2']);
    final hasZone2 = zone2.isNotEmpty;

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: ListView(
        padding: EdgeInsets.only(top: height * 0.02, bottom: height * 0.14),
        children: [
          if (!online) _offlineBanner(width),


          _card(
            width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mode",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: width * 0.043,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.012),
                _modeToggle(context, width, mode),
                SizedBox(height: height * 0.012),
                Text(
                  isManual
                      ? "Manual: you start and stop misting in Zone 1. The "
                            "tank-low safety still stops everything."
                      : "Auto: Zone 1 mists by itself based on its own heat "
                            "index. The tank-low safety still stops "
                            "everything.",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: width * 0.03,
                  ),
                ),
              ],
            ),
          ),


          _card(
            width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Misting Trigger",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: width * 0.043,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Fixed by the system, cannot be changed",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: width * 0.028,
                  ),
                ),
                SizedBox(height: height * 0.01),
                _infoRow(
                  width,
                  CupertinoIcons.drop_fill,
                  "Starts misting at",
                  thresholds['start'] is num
                      ? "≥ ${_fmt(thresholds['start'], '°C')} heat index"
                      : "—",
                ),
                _infoRow(
                  width,
                  CupertinoIcons.stop_fill,
                  "Stops misting at",
                  thresholds['stop'] is num
                      ? "≤ ${_fmt(thresholds['stop'], '°C')} heat index"
                      : "—",
                ),
              ],
            ),
          ),


          _card(
            width,
            Column(
              children: [
                _infoRow(
                  width,
                  CupertinoIcons.drop_fill,
                  "Tank",
                  tankOk ? "OK" : "LOW",
                  warn: !tankOk,
                ),
                _infoRow(
                  width,
                  CupertinoIcons.thermometer,
                  "Water Temp",
                  (sensor['waterTemperature'] is num &&
                          (sensor['waterTemperature'] as num) > -100)
                      ? "${_fmt(sensor['waterTemperature'], '°C')} "
                            "(${sensor['waterTemperatureCondition'] ?? ''})"
                      : "NO SENSOR",
                  warn: sensor['waterTemperatureCondition'] == "NO SENSOR",
                ),
                _infoRow(
                  width,
                  CupertinoIcons.arrow_2_circlepath,
                  "Pump",
                  pumpOn ? "ON" : "OFF",
                ),
                _infoRow(
                  width,
                  CupertinoIcons.snow,
                  "Peltiers (2)",
                  peltiersOn ? "ON" : "OFF",
                ),
                _infoRow(
                  width,
                  CupertinoIcons.wind,
                  "Fans (2)",
                  fansOn ? "ON" : "OFF",
                ),
              ],
            ),
          ),


          _zoneCard(
            context,
            width,
            height,
            title: "Zone 1 • Misted",
            data: _map(sensor['zone1']),
            controllable: true,
            command: (controls['zone1Command'] ?? 'OFF').toString(),
            isManual: isManual,
            online: online,
            tankOk: tankOk,
          ),


          if (hasZone2)
            _zoneCard(
              context,
              width,
              height,
              title: "Zone 2 • No mist (comparison)",
              data: zone2,
              controllable: false,
              command: 'OFF',
              isManual: isManual,
              online: online,
              tankOk: tankOk,
              diff: sensor['heatIndexDiff'],
            ),
        ],
      ),
    );
  }



  Widget _card(double width, Widget child) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: width * 0.035),
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        color: const Color(0xFF0288D1).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(width * 0.06),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _offlineBanner(double width) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: width * 0.035),
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
              "reach the system. The ESP32 keeps misting in Auto and logs "
              "sessions until it reconnects.",
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

  Widget _modeToggle(BuildContext context, double width, String mode) {
    Widget segment(String label, String value) {
      final selected = mode == value;

      return Expanded(
        child: GestureDetector(
          onTap: selected ? null : () => _send(context, () => _setMode(value)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: width * 0.03),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(width * 0.04),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: selected ? const Color(0xFF0288D1) : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: width * 0.036,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(width * 0.01),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Row(
        children: [segment("Auto", "AUTO"), segment("Manual", "MANUAL")],
      ),
    );
  }

  Widget _infoRow(
    double width,
    IconData icon,
    String label,
    String value, {
    bool warn = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.012),
      child: Row(
        children: [
          Container(
            width: width * 0.08,
            height: width * 0.08,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(width * 0.03),
            ),
            child: Icon(icon, color: Colors.blue, size: width * 0.05),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: width * 0.034,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: width * 0.036,
              color: warn ? const Color(0xFFFFCDD2) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(double width, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: width * 0.028,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mistToggle(
    BuildContext context,
    double width, {
    required bool isOn,
    required bool canControl,
    required bool tankOk,
  }) {
    Widget segment(
      String label,
      IconData icon,
      bool selected,
      Color activeColor,
      bool enabled,
      VoidCallback onTap,
    ) {
      final inactiveColor = Colors.white.withValues(alpha: enabled ? 0.9 : 0.4);

      return Expanded(
        child: GestureDetector(
          onTap: (enabled && !selected) ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: width * 0.03),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(width * 0.04),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: width * 0.04,
                  color: selected ? activeColor : inactiveColor,
                ),
                SizedBox(width: width * 0.015),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: width * 0.034,
                    color: selected ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(width * 0.01),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Row(
        children: [
          segment(
            "Off",
            CupertinoIcons.stop_fill,
            !isOn,
            const Color(0xFFC62828),
            canControl,
            () => _send(context, () => _setMist('OFF')),
          ),
          segment(
            "On",
            CupertinoIcons.play_fill,
            isOn,
            const Color(0xFF2E7D32),
            canControl && tankOk,
            () => _send(context, () => _setMist('ON')),
          ),
        ],
      ),
    );
  }


    BuildContext context,
    double width,
    double height, {
    required String title,
    required Map<dynamic, dynamic> data,
    required bool controllable,
    required String command,
    required bool isManual,
    required bool online,
    required bool tankOk,
    dynamic diff,
  }) {
    final sensorOk = data['sensorOk'] == true;
    final misting = data['mistingStatus'] == 'ON';

    final String chipText;
    final Color chipColor;

    if (!sensorOk) {
      chipText = "SENSOR ERROR";
      chipColor = const Color(0xFFC62828);
    } else if (!controllable) {
      chipText = "MONITORING";
      chipColor = Colors.white.withValues(alpha: 0.30);
    } else if (misting) {
      chipText = "MISTING";
      chipColor = const Color(0xFF2E7D32);
    } else {
      chipText = "IDLE";
      chipColor = Colors.white.withValues(alpha: 0.30);
    }

    final canControl = isManual && online;
    final isOn = isManual ? command.toUpperCase() == 'ON' : misting;

    return _card(
      width,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: width * 0.043,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: width * 0.012,
                ),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(width * 0.05),
                ),
                child: Text(
                  chipText,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: width * 0.028,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.015),
          Row(
            children: [
              _stat(
                width,
                "Heat Index",
                sensorOk ? _fmt(data['heatIndex'], '°C') : '—',
              ),
              _stat(
                width,
                "Temperature",
                sensorOk ? _fmt(data['temperature'], '°C') : '—',
              ),
              _stat(
                width,
                "Humidity",
                sensorOk ? _fmt(data['humidity'], '%') : '—',
              ),
            ],
          ),


          if (!controllable && diff is num)
            Padding(
              padding: EdgeInsets.only(top: height * 0.012),
              child: Text(
                "Zone 2 is ${diff.toStringAsFixed(1)}°C "
                "${diff >= 0 ? 'hotter' : 'cooler'} than Zone 1 (heat index)",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: width * 0.03,
                ),
              ),
            ),


          if (controllable) ...[
            SizedBox(height: height * 0.018),
            _mistToggle(
              context,
              width,
              isOn: isOn,
              canControl: canControl,
              tankOk: tankOk,
            ),
            if (!isManual)
              Padding(
                padding: EdgeInsets.only(top: height * 0.01),
                child: Text(
                  "Switch to Manual to control misting.",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: width * 0.028,
                  ),
                ),
              )
            else if (!tankOk)
              Padding(
                padding: EdgeInsets.only(top: height * 0.01),
                child: Text(
                  "Tank is low: misting is disabled.",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFCDD2),
                    fontSize: width * 0.028,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
