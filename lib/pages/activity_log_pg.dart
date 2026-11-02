import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';

class ActivitylogsPage extends StatelessWidget {
  const ActivitylogsPage({super.key});

  int? _toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');

  double? _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('$v');

  double? _num(Map log, List<String> path) {
    dynamic cur = log;
    for (final k in path) {
      if (cur is Map && cur[k] != null) {
        cur = cur[k];
      } else {
        return null;
      }
    }
    return _toDouble(cur);
  }

  String formatTimestamp(int? ms) {
    if (ms == null || ms == 0) return "Time unavailable";
    final date = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat("MMM dd, yyyy • hh:mm a").format(date);
  }

  String formatDuration(int? sec) {
    if (sec == null) return "—";
    final m = sec ~/ 60;
    final s = sec % 60;
    return m > 0 ? "${m}m ${s}s" : "${s}s";
  }

  String reasonLabel(String? reason) {
    switch (reason) {
      case "TARGET_REACHED":
        return "Target heat index reached";
      case "MANUAL_STOP":
        return "Stopped manually";
      case "TANK_LOW":
        return "Stopped: tank low";
      case "SENSOR_FAIL":
        return "Stopped: sensor failure";
      case "MODE_CHANGE":
        return "Stopped: mode changed";
      case "COMMS_LOST":
        return "Stopped: connection lost";
      default:
        return reason ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final DatabaseReference logsRef = FirebaseDatabase.instance.ref("logs");

    return DashboardScaffold(
      title: "Mist Logs",
      child: Column(
        children: [
          SizedBox(height: height * 0.025),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: logsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final raw = snapshot.data?.snapshot.value;

                if (raw == null || raw is! Map) {
                  return Center(
                    child: Text(
                      "No mist logs yet",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: width * 0.04,
                      ),
                    ),
                  );
                }

                final logs = Map<dynamic, dynamic>.from(raw).entries
                    .where(
                      (e) =>
                          e.key.toString().startsWith('m_') && e.value is Map,
                    )
                    .map((e) => Map<dynamic, dynamic>.from(e.value as Map))
                    .toList();

                if (logs.isEmpty) {
                  return Center(
                    child: Text(
                      "No mist logs yet",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: width * 0.04,
                      ),
                    ),
                  );
                }

                // newest first
                logs.sort((a, b) {
                  final ta = _toInt(a["startedAt"]) ?? 0;
                  final tb = _toInt(b["startedAt"]) ?? 0;
                  return tb.compareTo(ta);
                });

                final shown = logs.take(100).toList();

                return ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(scrollbars: false),
                  child: ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (context, index) =>
                        _buildLogCard(shown[index], width, height),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(Map<dynamic, dynamic> log, double width, double height) {
    final running = log["status"] == "RUNNING";
    final durationSec = _toInt(log["durationSec"]);

    // zone 1 (misted)
    final before = _num(log, ["before", "mist", "heatIndex"]);
    final after = _num(log, ["after", "mist", "heatIndex"]);
    final cooledBy = (before != null && after != null) ? before - after : null;

    // zone 2 (control, no mist) - only present if the sensor is installed
    final ctrlBefore = _num(log, ["before", "control", "heatIndex"]);
    final ctrlAfter = _num(log, ["after", "control", "heatIndex"]);
    final extra = _num(log, ["comparison", "extraCoolingFromMist"]);

    final subtitle = running
        ? "In progress"
        : reasonLabel(log["stopReason"]?.toString());

    return ClipRRect(
      borderRadius: BorderRadius.circular(width * 0.07),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: width * 0.04, sigmaY: width * 0.04),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: height * 0.015),
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: const Color(0xFF0288D1).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(width * 0.07),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: width * 0.04,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: width * 0.14,
                    height: width * 0.14,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(width * 0.045),
                    ),
                    child: Icon(
                      CupertinoIcons.drop_fill,
                      color: Colors.white,
                      size: width * 0.07,
                    ),
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Zone 1 Misting",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: width * 0.043,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: width * 0.033,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (running)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: width * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(width * 0.05),
                      ),
                      child: Text(
                        "LIVE",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: width * 0.028,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: height * 0.02),

              // ---------- Zone 1 (misted) ----------
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.038),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(width * 0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _stat(
                            "Heat Index Before",
                            before != null
                                ? "${before.toStringAsFixed(1)}°C"
                                : "—",
                            width,
                          ),
                        ),
                        Expanded(
                          child: _stat(
                            "Heat Index After",
                            after != null
                                ? "${after.toStringAsFixed(1)}°C"
                                : "—",
                            width,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.012),
                    Row(
                      children: [
                        Expanded(
                          child: _stat(
                            "Duration",
                            running ? "Running…" : formatDuration(durationSec),
                            width,
                          ),
                        ),
                        Expanded(
                          child: _stat(
                            "Cooled By",
                            cooledBy != null
                                ? "${cooledBy.toStringAsFixed(1)}°C"
                                : "—",
                            width,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---------- Zone 2 (control) comparison ----------
              // shown only when the zone 2 DHT22 recorded this session
              if (ctrlBefore != null && ctrlAfter != null) ...[
                SizedBox(height: height * 0.012),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(width * 0.038),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(width * 0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Comparison • Zone 2 (no mist)",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Row(
                        children: [
                          Expanded(
                            child: _stat(
                              "Zone 2 Before",
                              "${ctrlBefore.toStringAsFixed(1)}°C",
                              width,
                            ),
                          ),
                          Expanded(
                            child: _stat(
                              "Zone 2 After",
                              "${ctrlAfter.toStringAsFixed(1)}°C",
                              width,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.012),
                      Row(
                        children: [
                          Expanded(
                            child: _stat(
                              "Zone 2 Cooled By",
                              "${(ctrlBefore - ctrlAfter).toStringAsFixed(1)}°C",
                              width,
                            ),
                          ),
                          Expanded(
                            child: _stat(
                              "Extra Cooling (Mist)",
                              extra != null
                                  ? "${extra.toStringAsFixed(1)}°C"
                                  : "—",
                              width,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: height * 0.02),
              Divider(color: Colors.white.withValues(alpha: 0.20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mode: ${log["mode"] ?? "—"}",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: width * 0.03,
                    ),
                  ),
                  Text(
                    formatTimestamp(_toInt(log["startedAt"])),
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: width * 0.03,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, double width) {
    return Column(
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
    );
  }
}
