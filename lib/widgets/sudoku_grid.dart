import 'package:flutter/material.dart';
import '../utils/model/game_state.dart';
import '../utils/model/multicell.dart';
import '../utils/view_utils.dart';

class SudokuGrid extends StatelessWidget {
  final GameState game;
  final void Function(int row, int col) onCellTap;

  const SudokuGrid({super.key, required this.game, required this.onCellTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          int row = index ~/ 9;
          int col = index % 9;
          MultiCell cell = game.gameTable[row][col];
          bool isFixed = game.isFixed(row, col);

          // Identify borders for 3x3 highlighting
          bool rightBorder = (col + 1) % 3 == 0 && col != 8;
          bool bottomBorder = (row + 1) % 3 == 0 && row != 8;

          bool isNumberComplete = false;
          if (game.selectedNumber != null) {
            isNumberComplete = game.isNumberFullyPlaced(game.selectedNumber!);
          }

          bool isSelected =
              game.selectedNumber != null &&
              cell.numbers.contains(game.selectedNumber);
          bool isErrorCell = false;
          if (game.selectedNumber != null) {
            int clusterIndex = (row ~/ 3) * 3 + (col ~/ 3);
            if (game.rowErrors[row] == 1 ||
                game.colErrors[col] == 1 ||
                game.clusterErrors[clusterIndex] == 1) {
              isErrorCell = true;
            }
          }

          return GestureDetector(
            onTap: () => onCellTap(row, col),
            child: Container(
              decoration: BoxDecoration(
                color: ViewUtils.getCellBackgroundColor(
                  game.gameOver,
                  isErrorCell,
                  isSelected,
                ),
                border: Border(
                  right: BorderSide(
                    color: rightBorder ? Colors.white : Colors.white24,
                    width: rightBorder ? 2.0 : 0.5,
                  ),
                  bottom: BorderSide(
                    color: bottomBorder ? Colors.white : Colors.white24,
                    width: bottomBorder ? 2.0 : 0.5,
                  ),
                ),
              ),
              child: Center(
                child: ViewUtils.buildCellContent(
                  cell,
                  game.selectedNumber,
                  isFixed,
                  isErrorCell,
                  isNumberComplete,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
