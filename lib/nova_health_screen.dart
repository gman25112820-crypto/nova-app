import 'package:flutter/material.dart';

// Nova Health module menu — expanded in Job 4.
// Placeholder stub so the hub compiles while Job 4 is pending.

class NovaHealthScreen extends StatelessWidget {
  const NovaHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090C18),
        foregroundColor: const Color(0xFFF2EFFF),
        title: const Text('Nova Health'),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Module menu coming in next step.',
          style: TextStyle(color: Color(0xFFAAABC8)),
        ),
      ),
    );
  }
}
