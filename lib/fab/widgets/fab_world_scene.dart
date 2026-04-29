import 'package:flutter/material.dart';

class FabWorldScene extends StatefulWidget {
  final double height;
  const FabWorldScene({super.key, this.height = 320});
  @override
  State<FabWorldScene> createState() => _FabWorldSceneState();
}

class _FabWorldSceneState extends State<FabWorldScene> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      color: const Color(0xFF080118),
      child: const Center(
        child: Text('🌙 Calm World', style: TextStyle(color: Color(0xFF9F7AEA), fontSize: 18)),
      ),
    );
  }
}