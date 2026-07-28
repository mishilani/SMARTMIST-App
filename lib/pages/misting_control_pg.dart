import 'package:flutter/material.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

class MistingControlPage extends StatefulWidget {
  final bool isAdmin;

  const MistingControlPage({super.key, required this.isAdmin});

  @override
  State<MistingControlPage> createState() => _MistingControlPage();
}

class _MistingControlPage extends State<MistingControlPage> {
  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: "Misting Control",
      child: Center(
        child: Text(
          widget.isAdmin ? "Admin Misting Control" : "View Misting Control",
          style: GoogleFonts.poppins(fontSize: 25),
        ),
      ),
    );
  }
}
