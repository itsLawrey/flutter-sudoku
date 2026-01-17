import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:sudoku/widgets/new_game_button.dart';

class VictoryDialog extends StatefulWidget {
  final String time;
  final String difficulty;
  final VoidCallback onNewGame;
  final VoidCallback onSpectate;
  final VoidCallback onMenu;

  const VictoryDialog({
    super.key,
    required this.time,
    required this.difficulty,
    required this.onNewGame,
    required this.onSpectate,
    required this.onMenu,
  });

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _controllerCenter.play();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          //make it lower
          alignment: Alignment.lerp(
            Alignment.topCenter,
            Alignment.center,
            0.5,
          )!,
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
              createParticlePath: drawStar,
              numberOfParticles: 30,
              emissionFrequency: 0.05,
              gravity: 0.2,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: AlertDialog(
            backgroundColor: const Color(0xFF2A2A3C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Column(
              children: const [
                Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                SizedBox(height: 16),
                Text(
                  'VICTORY!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'You solved the puzzle!',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.white54, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.difficulty,
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 24),
                // Buttons Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: widget.onMenu,
                      child: const Text(
                        'Menu',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onSpectate,
                      child: const Text(
                        'Spectate',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                NewGameButton(onPressed: widget.onNewGame),
              ],
            ),
            // actions: [], // Removed default actions
          ),
        ),
      ],
    );
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }
}
