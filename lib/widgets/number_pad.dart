import 'package:flutter/material.dart';
import 'package:sudoku/utils/model/game_state.dart';
import 'package:sudoku/utils/view_utils.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint for switching to 2 lines
        // 9 buttons * 40 width = 360. Plus spacing (12 per button) = 468 total needed.
        // Using 500 to be safe and account for any parent padding or scrollbars.
        bool useTwoLines = constraints.maxWidth < 500;

        if (useTwoLines) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [for (int i = 0; i <= 4; i++) _buildButton(i)],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [for (int i = 5; i <= 9; i++) _buildButton(i)],
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (int i = 0; i <= 9; i++) _buildButton(i)],
          );
        }
      },
    );
  }

  Widget _buildButton(int number) {
    bool isSelected = game.selectedNumber == number;
    bool isCompleted = game.isNumberFullyPlaced(number);
    Color textColor = ViewUtils.getNumberPadTextColor(
      isCompleted,
      game.gameOver,
    );

    // Logic for outline
    // When not white AND selected -> Black Outline
    // When not white AND unselected -> White Outline
    bool hasColor = textColor != Colors.white;
    Color? outlineColor;
    if (hasColor) {
      if (isSelected) {
        //utlineColor = Colors.black;
      } else {
        //outlineColor = Colors.white;
      }
    }

    Widget textWidget;
    if (number == 0) {
      textWidget = const Icon(Icons.star, color: Colors.amber, size: 24);
    } else {
      textWidget = Text(
        number.toString(),
        style: TextStyle(
          fontSize: 20,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: () => onNumberSelect(number),
        child: Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? ViewUtils.accentColor : const Color(0xFF2B2B3D),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Center(
            child: outlineColor == null
                ? textWidget
                : Stack(
                    children: [
                      // Stroked text as outline
                      Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth =
                                1 // Thicker for visibility
                            ..color = outlineColor,
                        ),
                      ),
                      // Solid text on top
                      textWidget,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
