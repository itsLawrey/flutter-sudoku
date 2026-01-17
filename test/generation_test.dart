import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/utils/model/difficulty.dart';
import 'package:sudoku/utils/model/game_state.dart';
import 'package:sudoku/utils/model/solver.dart';

void main() {
  group('Game Generation', () {
    test('prepareGame generates a valid puzzle with unique solution', () async {
      final gameState = GameState(Difficulty.easy);
      await gameState.startNewGame(Difficulty.easy);

      // Check that board is not full (some 0s)
      int emptyCount = 0;
      for (var row in gameState.gameTable) {
        for (var cell in row) {
          if (cell.isEmpty) emptyCount++;
        }
      }
      // We expect significantly more than 0 empty cells.
      expect(emptyCount, greaterThan(20)); // Heuristic check

      // Check that it has a unique solution
      final solver = Solver(gameState.gameTable);
      expect(solver.countSolutions(), equals(1));
    });

    test('remove method preserves uniqueness', () async {
      final gameState = GameState(Difficulty.easy);
      await gameState.startNewGame(Difficulty.easy);

      int initialCount = gameState.filledCellCount();
      // Try to remove further (might fail if already minimal)
      gameState.remove(initialCount);

      // Verify still unique
      final solver = Solver(gameState.gameTable);
      expect(solver.countSolutions(), equals(1));
    });

    test('remainingNumbers returns correct count', () async {
      final gameState = GameState(Difficulty.easy);
      await gameState.startNewGame(Difficulty.easy);

      // manually count
      int count = 0;
      for (var row in gameState.gameTable) {
        for (var cell in row) {
          if (cell.isNotEmpty) count++;
        }
      }
      expect(gameState.filledCellCount(), equals(count));
    });
  });
}
