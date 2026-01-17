import 'package:flutter/material.dart';
import 'package:sudoku/utils/model/game_state.dart';

class NumberPad extends StatelessWidget {
  final GameState game;
  final void Function(int number) onNumberSelect;

  const NumberPad({
    super.key,
    required this.game,
    required this.onNumberSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(9, (index) {
          int number = index + 1;
          bool isSelected = game.selectedNumber == number;
          return GestureDetector(
            onTap: () => onNumberSelect(number),
            child: Container(
              width: 40,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 177, 150, 246)
                    : const Color(0xFF2B2B3D),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
