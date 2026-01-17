import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/utils/model/meta_state.dart';
import 'package:sudoku/utils/model/difficulty.dart';

void main() {
  test('Default game naming logic', () async {
    MetaState metaState = MetaState();

    // Start 1st game
    await metaState.startNewGame(Difficulty.easy);
    metaState.saveGame();
    expect(metaState.gameState!.gameName, "Game #1");

    // Start 2nd game
    await metaState.startNewGame(Difficulty.medium);
    metaState.saveGame();
    expect(metaState.gameState!.gameName, "Game #2");

    // Close current game
    metaState.closeGame();

    // Start 3rd game
    await metaState.startNewGame(Difficulty.hard);
    expect(metaState.gameState!.gameName, "Game #3");

    // Rename the 2nd game
    metaState.gameHistory[1].gameName = "Renamed Game";

    // Start 4th game, should ignore "Renamed Game" in count?
    // Logic was: where startsWith("Game #")
    // History: "Game #1", "Renamed Game", "Game #3" (if saved)
    // Count of "Game #" is 2. So next should be "Game #3" again?
    // Let's check the logic: "Game #${gameCount + 1}"
    // gameCount refers to history count.

    await metaState.startNewGame(Difficulty.easy);
    // Expectation based on current implementation:
    // history has: Game #1, Renamed Game. (Game #3 was not saved in this flow logic explicitly in test but let's say we saved it)
    // Actually closeGame() calls saveGame().
  });
}
