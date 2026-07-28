import 'package:flutter/material.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

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
    if (timestamp == null) {
      return "";
    }

    if (timestamp is! int && timestamp.toString().isEmpty) {
      return "";
    }

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
    final DatabaseReference logsRef = FirebaseDatabase.instance.ref("Logs");
    return DashboardScaffold(
      title: "Activity Logs",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

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
                      style: GoogleFonts.poppins(color: Colors.white),
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
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 13),
                            padding: const EdgeInsets.all(20),

                            decoration: BoxDecoration(
                              color: Color(0xFF0288D1).withValues(alpha: 0.35),

                              borderRadius: BorderRadius.circular(30),

                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                                width: 1,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 15,
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
                                      width: 55,
                                      height: 55,

                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.20,
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                      ),

                                      child: Icon(
                                        getLogIcon(log["category"]),
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),

                                    const SizedBox(width: 15),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            log["action"] ?? "",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          Text(
                                            log["category"] ?? "",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                Text(
                                  log["description"] ?? "",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),

                                if ((log["oldValue"] ?? "") != "" &&
                                    (log["newValue"] ?? "") != "") ...[
                                  const SizedBox(height: 15),

                                  Container(
                                    width: double.infinity,

                                    padding: const EdgeInsets.all(15),

                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          "Previous Value",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),

                                        Text(
                                          log["oldValue"],
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        Text(
                                          "New Value",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),

                                        Text(
                                          log["newValue"],
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 15),

                                Divider(
                                  color: const Color.fromARGB(
                                    255,
                                    238,
                                    234,
                                    234,
                                  ).withValues(alpha: 0.20),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    Text(
                                      "👤 ${log["userName"] ?? "System"}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),

                                    Text(
                                      formatTimestamp(log["timestamp"]),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 12,
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
