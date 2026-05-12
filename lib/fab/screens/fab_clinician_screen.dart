import 'package:flutter/material.dart';

class FabClinicianScreen extends StatelessWidget {
  const FabClinicianScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      appBar: AppBar(backgroundColor: const Color(0xFF0D0820), title: const Text('Clinician', style: TextStyle(color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)),
      body: const Center(child: Text('Clinician view coming soon', style: TextStyle(color: Colors.white54))),
    );
  }
}