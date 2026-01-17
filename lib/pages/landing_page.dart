import 'package:flutter/material.dart';
import 'package:sudoku/utils/model/game_state.dart';
import 'package:sudoku/utils/model/meta_state.dart';
import 'package:sudoku/widgets/game_history_card.dart';
import 'package:sudoku/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:sudoku/widgets/new_game_button.dart';

class LandingPage extends StatelessWidget {
  final MetaState metaState;
  final Function(GameState) onGameSelected;
  final Function(GameState) onGameDelete;
  final VoidCallback onNewGame;
  final Function(GameState, String) onGameRename;

  const LandingPage({
    super.key,
    required this.metaState,
    required this.onGameSelected,
    required this.onGameDelete,
    required this.onNewGame,
    required this.onGameRename,
  });

  @override
  Widget build(BuildContext context) {
    // Sort games reverse chronologically
    final history = List<GameState>.from(metaState.gameHistory);
    history.sort((a, b) => b.startDate.compareTo(a.startDate));

    return _buildArchiveView(context, history);
  }

  Widget _buildArchiveView(BuildContext context, List<GameState> history) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Highscores Placeholder
              const Text(
                'Highscores',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildHighscoresDict(metaState),
              const SizedBox(height: 32),

              // Recent Games
              Center(child: NewGameButton(onPressed: onNewGame)),
              const SizedBox(height: 32),
              const Text(
                'Recent Games',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.grid_3x3,
                              size: 80,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No recent games',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start a new game to see it here!',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final game = history[index];
                          return GameHistoryCard(
                            index: history.length - index,
                            date: _formatDate(game.startDate),
                            difficulty: game.difficulty.name.toUpperCase(),
                            isCompleted: game.gameOver,
                            time: GameState.formatTime(game.elapsedSeconds),
                            gameName: game.gameName,
                            onRename: (newName) => onGameRename(game, newName),
                            onActionTap: () => onGameSelected(game),
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) =>
                                    const DeleteConfirmationDialog(),
                              );
                              if (confirm == true) {
                                onGameDelete(game);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighscoresDict(MetaState metaState) {
    // Ensuring highscores are up to date
    metaState.calculateHighscores();

    return Card(
      color: const Color(0xFF2A2A3C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildScoreItem('Easy', metaState.highscoreEasy),
            _buildScoreItem('Medium', metaState.highscoreMedium),
            _buildScoreItem('Hard', metaState.highscoreHard),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, int seconds) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          seconds == 0 ? '--:--' : GameState.formatTime(seconds),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
