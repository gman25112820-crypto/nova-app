import 'package:flutter/material.dart';
import '../widgets/read_aloud_button.dart';
import '../widgets/sleepy_sloth_widget.dart';

class BedtimeSceneScreen extends StatelessWidget {
  const BedtimeSceneScreen({super.key});

  static const String _backgroundAsset =
      'assets/images/rooms/underground/rest_nest_sleep_den_bg.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130D24),
      body: Stack(
        children: [
          const Positioned.fill(child: _RestNestSleepDenBackground()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF080717).withValues(alpha: 0.08),
                    Colors.transparent,
                    const Color(0xFF080717).withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: SleepySlothWidget(showBackground: false),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Sleepy & Saffi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ],
                    ),
                    const FabReadAloudButton(
                      id: 'sleepy-saffi-scene-guidance',
                      text:
                          'Sleepy and Saffi are resting. Sweet dreams, sleepyhead.',
                      margin: EdgeInsets.only(top: 10),
                      color: Color(0xFFC7A0FF),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestNestSleepDenBackground extends StatelessWidget {
  const _RestNestSleepDenBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      BedtimeSceneScreen._backgroundAsset,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
    );
  }
}
