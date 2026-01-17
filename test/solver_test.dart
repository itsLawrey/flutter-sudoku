import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/utils/model/solver.dart';
import 'package:sudoku/utils/model/multicell.dart';

void main() {
  group('Solver', () {
    test(
      'Partially filled board has multiple solutions',
      () {
        final board = [
          [5, 3, 0, 0, 7, 0, 0, 0, 0],
          [6, 0, 0, 1, 9, 5, 0, 0, 0],
          [0, 9, 8, 0, 0, 0, 0, 6, 0],
          [8, 0, 0, 0, 6, 0, 0, 0, 3],
          [4, 0, 0, 8, 0, 3, 0, 0, 1],
          [7, 0, 0, 0, 2, 0, 0, 0, 6],
          [0, 6, 0, 0, 0, 0, 2, 8, 0],
          [0, 0, 0, 4, 1, 9, 0, 0, 5],
          [0, 0, 0, 0, 8, 0, 0, 7, 9],
        ];
        // Create ambiguity by removing a few numbers
        board[0][0] = 0;
        board[0][1] = 0;
        board[0][2] = 0;

        final solver = Solver(toMultiCellBoard(board));
        final count = solver.countSolutions();
        expect(count, greaterThan(1));
      },
      timeout: Timeout(Duration(seconds: 5)),
    );

    test('Valid unique board has exactly 1 solution', () {
      final board = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];
      final solver = Solver(toMultiCellBoard(board));
      final count = solver.countSolutions();
      expect(count, equals(1));
    });

    test('Invalid board (no solution) returns 0', () {
      // Create a board that leads to a contradiction.
      // E.g. a board that is almost full but the last cell has no valid options.

      // This is the unique board. One solution.
      // Let's make it impossible.
      // The solution has '4' at [0,2] (inferred).
      // If we force [0,2] to be '1' (by pre-filling it), and '1' is invalid there...
      // '1' exists in Row 0 at [0,7]? No.
      // '1' exists in Col 2? Row 7 has '1' at [7,4].. not in col 2.
      // Let's just find a conflict.
      // Row 0 solution is likely: 5 3 4 6 7 8 9 1 2.
      // If we pre-fill [0,2] with 9?
      // Sol: 5 3 9 ...
      // Is 9 valid at [0,2]?
      // Row 0 has 9? No.
      // Col 2 has 9? [2,2]=8. [7,2]=0.
      // Box 0 has 9? [2,1]=9.
      // YES! Box 0 has 9 at [2,1].
      // So putting 9 at [0,2] is INVALID by Sudoku rules locally.
      // Solver should see valid State(0,2,9) is false.
      // BUT Solver only calls isValid for EMPTY cells.
      // If we pre-fill it with 9, Solver assumes it is fixed.
      // And then tries to solve the REST.
      // If the rest has no solution consistent with this 9, it returns 0.
      // BUT if the 9 itself is conflicting with existing 9, Solver doesn't check "existing vs existing".
      // It checks "new vs existing".
      // So if we put 9 at [0,2], and there is 9 at [2,1].
      // Solver fills other cells.
      // When it tries to fill a cell in Box 0... it avoids 9.
      // It avoids 9 because of [2,1] AND [0,2].
      // Can it fill the board?
      // likely NO, because Sudoku rules say 1-9 must appear in Box 0.
      // We have two 9s in Box 0. So we are missing one number (e.g. 1).
      // We have 8 empty spots in Box 0? No, Box 0 has 5,3,6,9,8 filled. 4 spots left.
      // We need to put 1, 2, 4, 7 (example).
      // Can we?
      // As long as row/col allows.
      // The issue is: The board IS invalid.
      // Does solver return 0?
      // Yes, if it eventually reaches a state where it cannot place any number.
      // But with an invalid starting state (duplicate 9s), it might still find a "solution" to the REST of the cells that satisfies logic LOCALLY for each new cell.
      // But preserving the global 1-9 constraint?
      // If Box 0 has two 9s, it can never have all 1-9.
      // So it's not a Sudoku solution.
      // But my `countSolutions` counts valid completions.
      // If the completion has two 9s, is it a solution?
      // User asked: "solves a given game table".
      // Usually "move is valid" checks constraints.
      // If I start with garbage, I might end with garbage + valid moves.

      // I should use a generic case where I simply block a cell from having ANY number.
      // Take a nearly full board.
      // Clear one cell.
      // Make sure NO number 1-9 can go there.
      // How?
      // Ensure 1-9 are present in its row, col, or box.
      // Example:
      // Row 0: 1 2 3 4 5 6 7 8 0
      // We need 9 at [0,8].
      // But if Col 8 has 9...
      // And Box 2 has 9... (redundant if col has it? No).
      // If Col 8 has 9 at [1,8].
      // Then [0,8] cannot be 9.
      // And it cannot be 1-8.
      // So no solution.
      // This is a robust test case.
      // Let's construct it.

      var invalidBoard = List.generate(9, (_) => List.filled(9, 0));
      // Fill Row 0 with 1-8
      for (int i = 0; i < 8; i++) invalidBoard[0][i] = i + 1;
      // Now invalidBoard[0][8] is 0. Needs 9.
      // Put 9 in Col 8 at Row 1.
      invalidBoard[1][8] = 9;

      // We also need to fill the Rest of the board enough so it doesn't allow 9 to move?
      // No, invalidBoard[0][8] CANNOT be filled.
      // Solver tries 1-9.
      // 1-8 blocked by Row 0.
      // 9 blocked by invalidBoard[1][8].
      // Returns false.
      // Count = 0.

      final solver = Solver(toMultiCellBoard(invalidBoard));
      final count = solver.countSolutions();
      expect(count, equals(0));
    });
  });
}

List<List<MultiCell>> toMultiCellBoard(List<List<int>> intBoard) {
  return intBoard
      .map(
        (row) => row.map((val) {
          var cell = MultiCell();
          if (val != 0) cell.addNumber(val);
          return cell;
        }).toList(),
      )
      .toList();
}
