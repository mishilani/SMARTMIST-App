import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmist_app/services/notification_service.dart';

class HeatWarningService {
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  static double _start = 42.0;
  static double _stop = 39.0;

  static const int _staleAfterMs = 60 * 1000;

  static final Map<int, String> _activeLevel = {1: "", 2: "", 3: ""};

  static bool _started = false;

  static String _levelFor(double hi) {
    if (hi >= 52) return "Extreme Danger";
    if (hi >= 42) return "Danger";
    if (hi >= 33) return "Extreme Caution";
    if (hi >= 27) return "Caution";
    return "Normal";
  }

  static int _rank(String level) =>
      const {
        "Normal": 0,
        "Caution": 1,
        "Extreme Caution": 2,
        "Danger": 3,
        "Extreme Danger": 4,
      }[level] ??
      0;

  static void start() {
    if (_started) return;
    _started = true;

    _db.child("status/thresholds").onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is! Map) return;
      final s = v["start"];
      final p = v["stop"];
      if (s is num) _start = s.toDouble();
      if (p is num) _stop = p.toDouble();
    }, onError: (e) => debugPrint("HeatWarning thresholds error: $e"));

    _db
        .child("sensor")
        .onValue
        .listen(
          _onSensor,
          onError: (e) => debugPrint("HeatWarning sensor error: $e"),
        );
  }

  static void _onSensor(DatabaseEvent event) {
    final raw = event.snapshot.value;
    if (raw is! Map) return;

    // Skip stale data
    final lastUpdate = raw["lastUpdate"];
    if (lastUpdate is! num) return;
    final age = DateTime.now().millisecondsSinceEpoch - lastUpdate.toInt();
    if (age > _staleAfterMs) return;

    for (var zone = 1; zone <= 3; zone++) {
      final z = raw["zone$zone"];
      if (z is! Map) continue;
      if (z["sensorOk"] == false) continue;

      final hiRaw = z["heatIndex"];
      if (hiRaw is! num) continue;
      final hi = hiRaw.toDouble();

      final previous = _activeLevel[zone] ?? "";

      if (hi >= _start) {
        final level = _levelFor(hi);
        if (previous.isEmpty || _rank(level) > _rank(previous)) {
          _activeLevel[zone] = level;
          NotificationService.show(
            title: "SMARTMIST — Heat Warning",
            body: "Zone $zone: heat index ${hi.toStringAsFixed(1)}°C ($level).",
          );
        }
      } else if (hi <= _stop) {
        _activeLevel[zone] = "";
      }
    }
  }
}
