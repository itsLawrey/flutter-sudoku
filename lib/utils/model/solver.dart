import 'game_state.dart';
import 'multicell.dart';

class Solver {
  int solutions = 0;
  late GameState _workingState;

  Solver(List<List<MultiCell>> gameBoard) {
    // Deep copy the board to prevent modifying the original
    List<List<MultiCell>> copiedBoard = gameBoard
        .map(
          (row) => row
              .map((cell) => MultiCell()..numbers.addAll(cell.numbers))
              .toList(),
        )
        .toList();
    _workingState = GameState.fromBoard(copiedBoard);
  }

  /// Counts the number of solutions for a given Sudoku board.
  /// Returns the number of solutions found. Stops searching if it exceeds 1 (found 2).
  int countSolutions() {
    solutions = 0;
    _solve();
    return solutions;
  }

  bool _solve() {
    List<List<MultiCell>> board = _workingState.gameTable;
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col].numbers.isEmpty) {
          for (int num = 1; num <= 9; num++) {
            // Use GameState's validation logic
            // isValidState returns 1 for success/valid
            if (_workingState.isValidState(row, col, num) == 0) {
              board[row][col].addNumber(num);
              if (_solve()) {
                if (solutions > 1) return true; // Stop early optimization
              }
              board[row][col].removeNumber(num); // Backtrack
            }
          }
          return false; // Trigger backtracking
        }
      }
    }
    // Solution found
    solutions++;
    return solutions >
        1; // Return true to stop searching if we want to stop at > 1
  }
}
