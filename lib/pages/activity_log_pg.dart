import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';

class ActivitylogsPage extends StatelessWidget {
  final bool isAdmin;

  const ActivitylogsPage({super.key, required this.isAdmin});

  IconData getLogIcon(String? category) {
    switch (category) {
      case "Authentication":
        return CupertinoIcons.person;
      case "Misting":
        return CupertinoIcons.drop_fill;
      case "Settings":
        return CupertinoIcons.gear_alt_fill;
      case "Water Management":
        return CupertinoIcons.drop_fill;
      default:
        return CupertinoIcons.clock_fill;
    }
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "";
    try {
      final int time = int.parse(timestamp.toString());
      final date = DateTime.fromMillisecondsSinceEpoch(time);
      return DateFormat("MMM dd, yyyy • hh:mm a").format(date);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final width = size.width;
    final height = size.height;
    final DatabaseReference logsRef = FirebaseDatabase.instance.ref("Logs");

    return DashboardScaffold(
      title: "Activity Logs",
      child: Column(
        children: [
          SizedBox(height: height * 0.025),
          Expanded(
            child: StreamBuilder(
              stream: logsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(
                    child: Text(
                      "No activity logs",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: width * 0.04,
                      ),
                    ),
                  );
                }

                final allLogs = Map<dynamic, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );

                var logs = allLogs.entries.where((entry) {
                  final log = Map<dynamic, dynamic>.from(entry.value);
                  if (!isAdmin) {
                    return log["category"] != "Authentication" &&
                        log["category"] != "Profile";
                  }
                  return true;
                }).toList();

                logs.sort((a, b) {
                  final logA = Map<dynamic, dynamic>.from(a.value);
                  final logB = Map<dynamic, dynamic>.from(b.value);
                  final timeA = int.tryParse(logA["timestamp"].toString()) ?? 0;
                  final timeB = int.tryParse(logB["timestamp"].toString()) ?? 0;
                  return timeB.compareTo(timeA);
                });

                return ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(scrollbars: false),
                  child: ListView(
                    children: logs.map((entry) {
                      final log = Map<dynamic, dynamic>.from(entry.value);

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(width * 0.07),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: width * 0.04,
                            sigmaY: width * 0.04,
                          ),
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: height * 0.015),
                            padding: EdgeInsets.all(width * 0.05),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0288D1,
                              ).withValues(alpha: 0.35),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.20,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          width * 0.045,
                                        ),
                                      ),
                                      child: Icon(
                                        getLogIcon(log["category"]),
                                        color: Colors.white,
                                        size: width * 0.07,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.04),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            log["action"] ?? "",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: width * 0.043,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            log["category"] ?? "",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white70,
                                              fontSize: width * 0.033,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height * 0.02),
                                Text(
                                  log["description"] ?? "",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: width * 0.036,
                                  ),
                                ),
                                if ((log["oldValue"] ?? "") != "" &&
                                    (log["newValue"] ?? "") != "") ...[
                                  SizedBox(height: height * 0.02),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(width * 0.038),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        width * 0.05,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Previous Value",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: width * 0.03,
                                          ),
                                        ),
                                        Text(
                                          log["oldValue"],
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: width * 0.04,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: height * 0.01),
                                        Text(
                                          "New Value",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: width * 0.03,
                                          ),
                                        ),
                                        Text(
                                          log["newValue"],
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: width * 0.04,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                SizedBox(height: height * 0.02),
                                Divider(
                                  color: Colors.white.withValues(alpha: 0.20),
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "👤 ${log["userName"] ?? "System"}",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: width * 0.03,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formatTimestamp(log["timestamp"]),
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
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
