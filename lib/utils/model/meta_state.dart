import 'package:sudoku/utils/model/difficulty.dart';
import 'package:sudoku/utils/model/game_state.dart';
import 'package:hive/hive.dart';

class MetaState {
  GameState? gameState;
  late int highscoreEasy;
  late int highscoreMedium;
  late int highscoreHard;
  late List<GameState> gameHistory;

  MetaState() {
    gameState = null;
    highscoreEasy = 0;
    highscoreMedium = 0;
    highscoreHard = 0;
    gameHistory = [];
  }

  Future<void> init() async {
    var box = await Hive.openBox('sudoku_data');
    if (box.containsKey('history')) {
      // Hive stores lists as dynamic, need to cast
      List<dynamic> rawHistory = box.get('history');
      gameHistory = rawHistory.cast<GameState>().toList();
      calculateHighscores();
    }
  }

  Future<void> startNewGame(Difficulty difficulty) async {
    int gameCount = gameHistory
        .where((g) => g.gameName.startsWith("Game #"))
        .length;
    gameState = GameState(difficulty);
    gameState!.gameName = "Game #${gameCount + 1}";
    await gameState!.startNewGame(difficulty);
  }

  void saveGame() {
    //add or keep overwriting a game with the same start date if there is already one
    if (gameState != null) {
      //only remove if there is already one
      if (gameHistory.any((game) => game.startDate == gameState!.startDate)) {
        gameHistory.removeWhere(
          (game) => game.startDate == gameState!.startDate,
        );
      }
      gameHistory.add(gameState!);
      calculateHighscores();
      _saveToHive();
    }
  }

  void loadGame(GameState game) {
    gameState = game;
  }

  void deleteGame(GameState game) {
    gameHistory.remove(game);
    _saveToHive();
  }

  void _saveToHive() {
    if (!Hive.isBoxOpen('sudoku_data')) return;
    var box = Hive.box('sudoku_data');
    box.put('history', gameHistory);
  }

  void closeGame() {
    saveGame();
    gameState = null;
  }

  void calculateHighscores() {
    //least amount of game.elaspedSeconds for given difficulty
    //only count finished games!

    if (gameHistory.isEmpty) {
      highscoreEasy = 0;
      highscoreMedium = 0;
      highscoreHard = 0;
      return;
    }

    var easyGames = gameHistory.where(
      (game) => game.difficulty == Difficulty.easy && game.gameOver,
    );
    if (easyGames.isNotEmpty) {
      highscoreEasy = easyGames
          .reduce(
            (game1, game2) =>
                game1.elapsedSeconds < game2.elapsedSeconds ? game1 : game2,
          )
          .elapsedSeconds;
    } else {
      highscoreEasy = 0;
    }

    var mediumGames = gameHistory.where(
      (game) => game.difficulty == Difficulty.medium && game.gameOver,
    );
    if (mediumGames.isNotEmpty) {
      highscoreMedium = mediumGames
          .reduce(
            (game1, game2) =>
                game1.elapsedSeconds < game2.elapsedSeconds ? game1 : game2,
          )
          .elapsedSeconds;
    } else {
      highscoreMedium = 0;
    }

    var hardGames = gameHistory.where(
      (game) => game.difficulty == Difficulty.hard && game.gameOver,
    );
    if (hardGames.isNotEmpty) {
      highscoreHard = hardGames
          .reduce(
            (game1, game2) =>
                game1.elapsedSeconds < game2.elapsedSeconds ? game1 : game2,
          )
          .elapsedSeconds;
    } else {
      highscoreHard = 0;
    }
  }

  bool inGame() {
    return gameState != null;
  }
}
