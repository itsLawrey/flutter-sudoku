import 'package:flutter/material.dart';
import 'model/multicell.dart';

class ViewUtils {
  static final Color accentColor = const Color.fromARGB(255, 163, 131, 252);
  //Color.fromARGB(255, 130, 80, 255);

  static Color getCellBackgroundColor(
    bool isGameOver,
    bool isErrorCell,
    bool isSelected,
  ) {
    if (isSelected) {
      return const Color.fromARGB(80, 177, 150, 246); // Purple tint
    }
    if (isErrorCell) {
      return const Color.fromARGB(50, 244, 67, 54); // Red tint
    }
    if (isGameOver) {
      return const Color.fromARGB(100, 18, 144, 1); // Green tint
    }
    return const Color(0xFF2B2B3D); // Default dark
  }

  static Color getNumberPadTextColor(bool isCompleted, bool isGameOver) {
    if (isGameOver) {
      return Colors.green;
    }
    if (isCompleted) {
      return Colors.blue;
    }
    return Colors.white;
  }

  static Widget buildCellContent(
    MultiCell cell,
    int? selectedNumber,
    bool isFixed,
    bool isErrorZone,
    bool isNumberComplete,
  ) {
    if (cell.numbers.isEmpty) {
      return const SizedBox.shrink();
    } else if (cell.numbers.length == 1) {
      int number = cell.numbers.first;
      // Check if this specific number is the one causing conflict
      bool isConflicting =
          isErrorZone && selectedNumber != null && number == selectedNumber;

      return Text(
        number.toString(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: isFixed ? FontWeight.bold : FontWeight.normal,
          color: (isNumberComplete && number == selectedNumber)
              ? Colors.blue
              : (cell.isMarked
                    ? Colors.amber
                    : (isConflicting
                          ? Colors.red
                          : (isFixed ? Colors.white : accentColor))),
        ),
      );
    } else {
      // Multi-value display: 3x3 grid
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int r = 0; r < 3; r++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int c = 0; c < 3; c++)
                  _buildMiniNumber(
                    cell,
                    r * 3 + c + 1,
                    selectedNumber,
                    isFixed,
                    isErrorZone,
                    isNumberComplete,
                  ),
              ],
            ),
        ],
      );
    }
  }

  static Widget _buildMiniNumber(
    MultiCell cell,
    int number,
    int? selectedNumber,
    bool isFixed,
    bool isErrorZone,
    bool isNumberComplete,
  ) {
    if (!cell.numbers.contains(number)) {
      return const SizedBox(
        width: 12,
        height: 12,
      ); // Placeholder to keep alignment
    }

    // Check if this specific number is the one causing conflict
    bool isConflicting =
        isErrorZone && selectedNumber != null && number == selectedNumber;

    return SizedBox(
      width: 12,
      height: 12,
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.normal,
            color: isConflicting
                ? Colors.red
                : (isNumberComplete && number == selectedNumber
                      ? Colors.blue
                      : (isFixed
                            ? Colors.white
                            : const Color.fromARGB(255, 177, 150, 246))),
          ),
        ),
      ),
    );
  }
}
