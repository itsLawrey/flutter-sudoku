import 'dart:math';
import 'package:sudoku/utils/model/difficulty.dart';
import 'package:hive/hive.dart';

import 'solver.dart';
import 'multicell.dart';

part 'game_state.g.dart';

@HiveType(typeId: 2)
class GameState {
  //PROPERTIES ####################################################
  @HiveField(0)
  late List<List<MultiCell>> gameTable;

  late Set<String> _fixedTable;

  @HiveField(1)
  List<String> get fixedTableList => _fixedTable.toList();

  @HiveField(1)
  set fixedTableList(List<String> value) {
    _fixedTable = value.toSet();
  }

  @HiveField(2)
  int? selectedNumber;
  @HiveField(3)
  late List<int> rowErrors;
  @HiveField(4)
  late List<int> colErrors;
  @HiveField(5)
  late List<int> clusterErrors;
  @HiveField(6)
  late int currentErrors;
  @HiveField(7)
  bool gameOver = false;
  @HiveField(8)
  late Difficulty difficulty;
  @HiveField(9)
  late DateTime startDate;
  @HiveField(10)
  late int elapsedSeconds;
  @HiveField(11)
  String gameName = "";

  //CONSTRUCTORS ####################################################
  GameState(this.difficulty) {
    gameTable = List.generate(
      9,
      (row) => List.generate(9, (col) => MultiCell()),
    );
    rowErrors = List.generate(9, (row) => 0);
    colErrors = List.generate(9, (col) => 0);
    clusterErrors = List.generate(9, (cluster) => 0);
    selectedNumber = null;
    currentErrors = 0;
    gameOver = false;
    startDate = DateTime.now();
    elapsedSeconds = 0;
    gameName = "";
    _fixedTable = {};
  }

  GameState.fromBoard(List<List<MultiCell>> board) {
    gameTable = board;
    _fixedTable = {};
  }

  //INITIALIZE ####################################################
  Future<void> startNewGame(Difficulty difficulty) async {
    await Future.delayed(Duration.zero);

    fillTable(0, 0);
    await prepareGame(difficulty);
    setFixedTable();
    gameOver = false;
  }

  Future<void> prepareGame(Difficulty difficulty) async {
    int threshold = difficulty.threshold;
    int remNums = filledCellCount();

    while (remNums > threshold) {
      await Future.delayed(Duration.zero);

      bool success = remove(remNums);
      if (!success) {
        print("Could not remove more numbers. Stopping at $remNums");
        break;
      }
      remNums = filledCellCount();
    }
  }

  //THIS IS FOR TESTING ONLY!!!
  Future<void> prepareGameTestWin(Difficulty difficulty) async {
    //just remove ONE number manually
    gameTable[0][0].clear();
  }

  bool fillTable(int row, int col) {
    // Base case: If we pass the last row, the board is full!
    if (row == 9) return true;

    // Calculate next cell coordinates
    int nextRow = (col == 8) ? row + 1 : row;
    int nextCol = (col == 8) ? 0 : col + 1;

    // Try numbers 1-9 in RANDOM order to ensure unique games every time
    var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle();

    for (int num in numbers) {
      if (isValidState(row, col, num) == 0) {
        // Recursively try to fill the rest of the board
        placeNumber(row, col, num);
        if (fillTable(nextRow, nextCol)) {
          return true; // Success!
        }

        // If we get here, it means the path failed.
        removeNumber(
          row,
          col,
          num,
        ); // BACKTRACK: Reset cell to 0 and try next number
      }
    }

    return false; // Trigger backtracking in the previous step
  }

  void setFixedTable() {
    _fixedTable = {};
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (gameTable[i][j].numbers.isNotEmpty) {
          _fixedTable.add("$i,$j");
        }
      }
    }
  }

  bool isFixed(int x, int y) {
    return _fixedTable.contains("$x,$y");
  }

  //ERROR CHECKERS ####################################################

  void isGameOver() {
    currentErrors = calculateTotalErrors();
    if (filledCellCount() == 81) {
      if (currentErrors == 0 && allCellsHaveSingleNumber()) {
        gameOver = true;

        // Unmark all cells on game over
        for (int i = 0; i < 9; i++) {
          for (int j = 0; j < 9; j++) {
            gameTable[i][j].isMarked = false;
          }
        }

        print("Game Over!");
      }
    }
  }

  bool allCellsHaveSingleNumber() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (gameTable[i][j].numbers.length != 1) {
          return false;
        }
      }
    }
    return true;
  }

  int calculateTotalErrors() {
    int errors = 0;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (gameTable[i][j].isNotEmpty) {
          for (int num in gameTable[i][j].numbers) {
            if (isValidState(i, j, num) == 1) {
              errors++;
            }
          }
        }
      }
    }
    return errors;
  }

  bool isNumberFullyPlaced(int selectedNum) {
    //when there are nine of this specific number and no errors for this specific number
    int count = 0;
    bool fullyCorrect = true;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (gameTable[i][j].numbers.contains(selectedNum)) {
          count++;
          if (isValidState(i, j, selectedNum) == 1) {
            fullyCorrect = false;
            break;
          }
        }
      }
    }
    if (count == 9 && fullyCorrect) {
      return true;
    } else {
      return false;
    }
  }

  int isValidState(int x, int y, int num) {
    if (num == 0) {
      return 0;
    } //0 can be anywhere

    if (checkRow(x, y, num) && checkCol(x, y, num) && checkCluster(x, y, num)) {
      return 0; // success
    } else {
      return 1; // failure
    }
  }

  bool checkRow(int x, int y, int num) {
    for (int i = 0; i < 9; i++) {
      if (i == y) continue;
      if (gameTable[x][i].numbers.contains(num)) {
        return false;
      }
    }
    return true;
  }

  bool checkCol(int x, int y, int num) {
    for (int i = 0; i < 9; i++) {
      if (i == x) continue;
      if (gameTable[i][y].numbers.contains(num)) {
        return false;
      }
    }
    return true;
  }

  bool checkCluster(int x, int y, int num) {
    int clusterX =
        x ~/ 3; //integer division, meaning it will truncate the decimal part
    int clusterY = y ~/ 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        int r = clusterX * 3 + i;
        int c = clusterY * 3 + j;
        if (r == x && c == y) continue;
        if (gameTable[r][c].numbers.contains(num)) {
          return false;
        }
      }
    }
    return true;
  }

  //TABLE MANIPULATION ####################################################
  void placeNumber(int x, int y, int num) {
    if (!gameOver) {
      gameTable[x][y].addNumber(num);
      if (selectedNumber != null) {
        updateErrors(selectedNumber);
      }
      isGameOver();
    }
  }

  void removeNumber(int x, int y, int num) {
    if (!gameOver) {
      gameTable[x][y].removeNumber(num);
      if (selectedNumber != null) {
        updateErrors(selectedNumber);
      }
    }
  }

  int solve() {
    //ensure onyl one solution is possible
    Solver solver = Solver(gameTable);
    int solutions = solver.countSolutions();
    return solutions;
  }

  bool remove(int remainingNumbers) {
    int attempts = 50; // Safety break
    while (attempts > 0) {
      int row = Random().nextInt(9);
      int col = Random().nextInt(9);
      // Ensure we pick a filled cell
      if (gameTable[row][col].numbers.isEmpty) continue;

      List<int> toRemoveR = [];
      List<int> toRemoveC = [];
      List<List<int>> backupValues = [];

      // Determine symmetry based on remaining numbers
      // 81 -> ... -> 51: Remove 4
      // 51 -> ... -> 30: Remove 2
      // 30 -> ... : Remove 1
      if (remainingNumbers > 51) {
        // 4-way symmetry
        toRemoveR = [row, row, 8 - row, 8 - row];
        toRemoveC = [col, 8 - col, col, 8 - col];
      } else if (remainingNumbers > 30) {
        // 2-way symmetry
        toRemoveR = [row, 8 - row];
        toRemoveC = [col, 8 - col];
      } else {
        // 1-way (random)
        toRemoveR = [row];
        toRemoveC = [col];
      }

      // 1. Store backup and Remove
      // Use a Set to avoid trying to remove/backup same cell twice (if center)
      Set<String> processed = {};
      bool potentialInvalid = false;

      for (int i = 0; i < toRemoveR.length; i++) {
        int r = toRemoveR[i];
        int c = toRemoveC[i];
        String key = "$r,$c";
        if (processed.contains(key)) continue;
        processed.add(key);

        if (gameTable[r][c].isEmpty) {
          // Already empty? Can happen if we picked a spot that was symmetric counterpart of previous removal?
          potentialInvalid = true;
          break;
        }

        backupValues.add(List.from(gameTable[r][c].numbers));
        gameTable[r][c].clear();
      }

      if (potentialInvalid) {
        // Restore what we removed so far
        int idx = 0;
        processed = {};
        for (int i = 0; i < toRemoveR.length; i++) {
          int r = toRemoveR[i];
          int c = toRemoveC[i];
          String key = "$r,$c";
          if (processed.contains(key)) continue;
          processed.add(key);
          if (idx < backupValues.length) {
            // Restore numbers
            gameTable[r][c].clear();
            for (int val in backupValues[idx]) {
              gameTable[r][c].addNumber(val);
            }
            idx++;
          }
        }
        attempts--;
        continue;
      }

      // 2. Check Uniqueness
      if (solve() == 1) {
        // Success, unique solution exists
        return true;
      } else {
        // Not unique (or no solution which shouldn't happen if we just removed numbers),
        // Restore
        int idx = 0;
        processed = {};
        for (int i = 0; i < toRemoveR.length; i++) {
          int r = toRemoveR[i];
          int c = toRemoveC[i];
          String key = "$r,$c";
          if (processed.contains(key)) continue;
          processed.add(key);
          if (idx < backupValues.length) {
            gameTable[r][c].clear();
            for (int val in backupValues[idx]) {
              gameTable[r][c].addNumber(val);
            }
            idx++;
          }
        }
      }
      attempts--;
    }
    return false; // Could not find a valid removal
  }

  int filledCellCount() {
    int count = 0;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (gameTable[i][j].isNotEmpty) {
          count++;
        }
      }
    }
    return count;
  }

  //SELECTED NUMBER ####################################################
  void selectNumber(int? number) {
    selectedNumber = number;
    updateErrors(number);
  }

  void deselectNumber() {
    selectedNumber = null;
    resetErrors();
  }

  void resetErrors() {
    rowErrors = List.generate(9, (row) => 0);
    colErrors = List.generate(9, (col) => 0);
    clusterErrors = List.generate(9, (cluster) => 0);
  }

  void updateErrors(int? number) {
    resetErrors();
    if (number == null) return;

    for (int i = 0; i < 9; i++) {
      int countR = 0;
      int countC = 0;
      for (int j = 0; j < 9; j++) {
        if (gameTable[i][j].numbers.contains(number)) countR++;
        if (gameTable[j][i].numbers.contains(number)) countC++;
      }
      if (countR > 1) rowErrors[i] = 1;
      if (countC > 1) colErrors[i] = 1;
    }

    for (int k = 0; k < 9; k++) {
      int count = 0;
      int startRow = (k ~/ 3) * 3;
      int startCol = (k % 3) * 3;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (gameTable[startRow + i][startCol + j].numbers.contains(number))
            count++;
        }
      }
      if (count > 1) clusterErrors[k] = 1;
    }
  }

  void toggleMark(int x, int y) {
    if (!gameOver) {
      if (!isFixed(x, y)) {
        gameTable[x][y].handleMarking();
      }
    }
  }

  //OTHER ####################################################
  void resetStartTime() {
    startDate = DateTime.now();
    elapsedSeconds = 0;
  }

  void progressTimer() {
    if (gameOver) return;
    elapsedSeconds += 1;
  }

  static String formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  toString() {
    String str = "";
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        str += gameTable[i][j].toString();
        str += " ";
      }
      str += "\n";
    }
    return str;
  }
}
