import 'package:firebase_database/firebase_database.dart';
import 'package:smartmist_app/services/notification_service.dart';

class HeatWarningService {
  static final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref(
    "sensor",
  );

  static bool _lastHeatWarning = false;
  static bool _started = false;

  static void start() {
    if (_started) return;
    _started = true;

    _sensorRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null || value is! Map) return;

      final data = Map<Object?, Object?>.from(value);

      final isWarning = data["heatWarningActive"] == true;
      final level = data["heatWarningLevel"]?.toString() ?? "Normal";

      if (isWarning && !_lastHeatWarning) {
        NotificationService.show(
          title: "SMARTMIST — Heat Warning",
          body: "Heat index has reached $level level.",
        );
      }

      _lastHeatWarning = isWarning;
    });
  }
}
