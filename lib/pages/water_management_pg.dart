import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/widgets/app_notifications.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';
import 'package:smartmist_app/widgets/section_card.dart';
import 'package:smartmist_app/widgets/animated_water_tank.dart';
import 'dart:async';
import 'package:smartmist_app/services/notification_service.dart';

class WaterManagementPage extends StatefulWidget {
  const WaterManagementPage({super.key});

  @override
  State<WaterManagementPage> createState() => _WaterManagementPageState();
}

class _WaterManagementPageState extends State<WaterManagementPage> {
  static const double coolStartTemp = 28;

  final DatabaseReference db = FirebaseDatabase.instance.ref("sensor");

  bool waterAvailable = false;
  double? waterTemp;
  bool coolingRunning = false;

  bool? _previousWaterAvailable;
  StreamSubscription<DatabaseEvent>? _waterSubscription;

  @override
  void initState() {
    super.initState();
    listenWaterData();
  }

  @override
  void dispose() {
    _waterSubscription?.cancel();
    super.dispose();
  }

  void listenWaterData() {
    _waterSubscription = db.onValue.listen((event) {
      final value = event.snapshot.value;

      if (value != null && value is Map) {
        final sensor = Map<Object?, Object?>.from(value);

        if (!mounted) return;

        setState(() {
          waterAvailable = sensor["waterAvailable"] == true;

          final rawWaterTemp = double.tryParse(
            sensor["waterTemperature"]?.toString() ?? "",
          );
          waterTemp = (rawWaterTemp == null || rawWaterTemp <= -50)
              ? null
              : rawWaterTemp;

          final devices = sensor["devices"];
          coolingRunning =
              devices is Map &&
              (devices["peltier1"] == true || devices["peltier2"] == true);
        });

        _checkLowWaterAlert();
      }
    });
  }

  void _checkLowWaterAlert() {
    final wasAvailable = _previousWaterAvailable;
    final isAvailable = waterAvailable;

    if (wasAvailable == true && isAvailable == false) {
      _showLowWaterAlert();
    }

    _previousWaterAvailable = isAvailable;
  }

  Future<void> _showLowWaterAlert() async {
    if (!mounted) return;

    AppNotification.show(
      context,
      "Low water! Please refill the tank.",
      color: Colors.redAccent,
      icon: CupertinoIcons.exclamationmark_triangle_fill,
    );

    await NotificationService.show(
      title: "SMARTMIST",
      body:
          "Water level is low. Please refill the tank to keep misting active.",
    );
  }

  String getWaterStatus() {
    return waterAvailable ? "Water Level Normal" : "Low / No Water Detected";
  }

  Color getWaterColor() {
    return waterAvailable ? Colors.cyanAccent : Colors.redAccent;
  }

  String getTemperatureStatus() {
    if (waterTemp == null) {
      return "No Sensor";
    }
    if (waterTemp! >= coolStartTemp) {
      return "Cooling Required";
    }
    return "Normal Temperature";
  }

  Color getTemperatureColor() {
    if (waterTemp == null) {
      return Colors.white70;
    }
    if (waterTemp! >= coolStartTemp) {
      return Colors.orangeAccent;
    }
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return DashboardScaffold(
      title: "Water Management",
      subtitle: "Monitor water storage and cooling system",
      showBackButton: true,
      child: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: height * 0.008),
              child: Column(
                children: [
                  SectionCard(
                    color: const Color(0xFF01579B).withValues(alpha: 0.35),
                    icon: CupertinoIcons.drop_fill,
                    title: "Water Tank",
                    subtitle:
                        "Float switch status (no fill-level sensor installed)",
                    child: SizedBox(
                      height: height * 0.18,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  waterAvailable
                                      ? CupertinoIcons.checkmark_seal_fill
                                      : CupertinoIcons.xmark_seal_fill,
                                  color: getWaterColor(),
                                  size: width * 0.11,
                                ),
                                SizedBox(height: height * 0.008),
                                Text(
                                  getWaterStatus(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: getWaterColor(),
                                    fontSize: width * 0.032,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: AnimatedWaterTank(
                                isFilled: waterAvailable,
                                width: width * 0.20,
                                height: height * 0.17,
                                color: getWaterColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.012),
                  SizedBox(
                    height: height * 0.20,
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    waterTemp == null
                                        ? "--°C"
                                        : "${waterTemp!.toStringAsFixed(1)}°C",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: width * 0.065,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    getTemperatureStatus(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: getTemperatureColor(),
                                      fontSize: width * 0.030,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Expanded(
                          child: SectionCard(
                            color: const Color(
                              0xFF01579B,
                            ).withValues(alpha: 0.35),
                            icon: CupertinoIcons.snow,
                            title: "Cooling",
                            subtitle: "Peltier system",
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    coolingRunning ? "ON" : "OFF",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: width * 0.065,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Starts at ${coolStartTemp.toInt()}°C",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: width * 0.03,
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
                  SizedBox(height: height * 0.01),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
