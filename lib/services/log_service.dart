import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LogService {
  static final DatabaseReference _logs = FirebaseDatabase.instance.ref("Logs");

  static Future<void> addLog({
    required String action,
    required String category,
    required String description,
    String oldValue = "",
    String newValue = "",
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final logRef = _logs.push();

    await logRef.set({
      "logID": logRef.key,
      "action": action,
      "category": category,
      "description": description,
      "oldValue": oldValue,
      "newValue": newValue,
      "timestamp": ServerValue.timestamp,
      "userID": user?.uid ?? "",
      "userName": user?.email ?? "",
    });
  }
}
