import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:sudoku/utils/model/difficulty.dart';
import 'package:sudoku/utils/model/game_state.dart';
import 'package:sudoku/utils/model/multicell.dart';
import 'package:sudoku/widgets/dialogs/victory_dialog.dart';

import 'package:sudoku/utils/model/meta_state.dart';
import 'package:sudoku/widgets/dialogs/difficulty_dialog.dart';
import 'package:sudoku/pages/landing_page.dart';
import 'package:sudoku/widgets/loading_indicator.dart';
import 'package:sudoku/widgets/number_pad.dart';
import 'package:sudoku/widgets/sudoku_grid.dart';
import 'package:sudoku/widgets/new_game_button.dart';
import 'package:sudoku/utils/view_utils.dart';
import 'package:sudoku/utils/loader_utils.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DifficultyAdapter());
  Hive.registerAdapter(MultiCellAdapter());
  Hive.registerAdapter(GameStateAdapter());
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  MetaState metaState = MetaState();
  bool isLoading = false;
  Timer? _timer;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      removeWebLoadingIndicator();
    });
    _initPersistence();
  }

  Future<void> _initPersistence() async {
    await metaState.init();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  Future<void> _runWithLoading(Future<void> Function() action) async {
    setState(() {
      isLoading = true;
    });
    _stopTimer();

    // Wait for the loading screen to actually render before starting heavy work
    await WidgetsBinding.instance.endOfFrame;

    // Track start time for minimum loading display
    final startTime = DateTime.now();

    await action();

    // Ensure loading screen shows for at least 1 second
    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime.inMilliseconds < 1000) {
      await Future.delayed(
        Duration(milliseconds: 1000 - elapsedTime.inMilliseconds),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _startNewGame(Difficulty difficulty) async {
    await _runWithLoading(() async {
      // Create new game instance (async)
      await metaState.startNewGame(difficulty);
    });
    metaState.gameState!.resetStartTime();
    _startTimer();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!metaState.inGame()) {
        _stopTimer();
        return;
      }

      if (metaState.gameState!.gameOver) {
        _stopTimer();
        // Ensure UI updates one last time to show final state if needed
        setState(() {});
        return;
      }

      setState(() {
        metaState.gameState!.progressTimer();
        metaState.saveGame();
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _showDifficultyDialog(BuildContext context) async {
    // Use navigator key context to ensure MaterialLocalizations are found
    final ctx = _navigatorKey.currentContext ?? context;
    final difficulty = await showDialog<Difficulty>(
      context: ctx,
      builder: (context) => const DifficultyDialog(),
    );

    if (difficulty != null) {
      await _startNewGame(difficulty);
    }
  }

  Future<void> _handleGameSelection(GameState game) async {
    await _runWithLoading(() async {
      metaState.loadGame(game);
      if (game.selectedNumber != null) {
        // Ensure UI state is consistent
        game.updateErrors(game.selectedNumber);
      }
    });

    if (!game.gameOver) {
      _startTimer();
    }
  }

  // GRAPHICAL UI ##################################################
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C), // Dark Purple/Black
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.purple,
          brightness: Brightness.dark,
        ).copyWith(secondary: ViewUtils.accentColor),
      ),
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              isLoading
                  ? 'Loading...'
                  : !metaState.inGame()
                  ? 'Sudoku'
                  : '${metaState.gameState!.difficulty.name.toUpperCase()} - ${GameState.formatTime(metaState.gameState!.elapsedSeconds)}${_getHighscoreDisplay()}',
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          drawer: _buildDrawer(context),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2A2A3C),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: ViewUtils.accentColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.grid_3x3, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Sudoku',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.add, color: Colors.white),
            title: Text(
              'New Game',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showDifficultyDialog(context);
            },
          ),
          Divider(color: Colors.white24),
          ExpansionTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text(
              'Color Legend',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            shape: const Border(),
            children: [
              _buildLegendItem(Colors.white, 'Fixed'),
              _buildLegendItem(Colors.red, 'Conflict'),
              _buildLegendItem(Colors.blue, 'Completed'),
              _buildLegendItem(Colors.green, 'Victory'),
              _buildLegendItem(Colors.amber, 'Marked'),
            ],
          ),
          if (metaState.inGame()) ...[
            Divider(color: Colors.white24),
            ListTile(
              leading: Icon(Icons.save, color: Colors.white),
              title: Text(
                'Save Game',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // _saveGame(context); // Legacy placeholder
                _exitGame(context);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isOutline = false}) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : color,
          shape: BoxShape.circle,
          border: isOutline ? Border.all(color: color, width: 2) : null,
        ),
        child: isOutline
            ? Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      dense: false,
      contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const LoadingIndicator();
    }

    if (!metaState.inGame()) {
      return LandingPage(
        metaState: metaState,
        onGameSelected: _handleGameSelection,
        onGameDelete: _handleGameDeletion,
        onNewGame: () => _showDifficultyDialog(context),
        onGameRename: _handleGameRename,
      );
    }

    return _buildGameView();
  }

  void _handleGameRename(GameState game, String newName) {
    setState(() {
      game.gameName = newName;
      metaState.saveGame();
    });
  }

  void _handleGameDeletion(GameState game) {
    setState(() {
      metaState.deleteGame(game);
    });
  }

  Widget _buildGameView() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: CallbackShortcuts(
          bindings: {
            // Standard number keys 1-9
            ...{
              for (var i = 0; i <= 9; i++)
                SingleActivator(LogicalKeyboardKey(0x30 + i)): () =>
                    _selectNumber(i),
            },
            // Numpad keys 0-9
            ...{
              for (var i = 0; i <= 9; i++)
                SingleActivator(
                  [
                    LogicalKeyboardKey.numpad0,
                    LogicalKeyboardKey.numpad1,
                    LogicalKeyboardKey.numpad2,
                    LogicalKeyboardKey.numpad3,
                    LogicalKeyboardKey.numpad4,
                    LogicalKeyboardKey.numpad5,
                    LogicalKeyboardKey.numpad6,
                    LogicalKeyboardKey.numpad7,
                    LogicalKeyboardKey.numpad8,
                    LogicalKeyboardKey.numpad9,
                  ][i],
                ): () =>
                    _selectNumber(i),
            },
            const SingleActivator(LogicalKeyboardKey.escape): _deselectNumber,
            const SingleActivator(LogicalKeyboardKey.backspace):
                _deselectNumber,
          },
          child: Focus(
            autofocus: true,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: SudokuGrid(
                          game: metaState.gameState!,
                          onCellTap: _handleCellTap,
                        ),
                      ),
                    ),
                  ),
                ),

                if (metaState.gameState!.gameOver)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => _exitGame(context),
                          child: const Text(
                            'Menu',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 16),
                        NewGameButton(
                          onPressed: () {
                            _exitGame(context);
                            _showDifficultyDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                NumberPad(
                  game: metaState.gameState!,
                  onNumberSelect: _selectNumber,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCellTap(int row, int col) {
    if (!metaState.inGame()) return;

    if (metaState.gameState!.selectedNumber != null) {
      if (!metaState.gameState!.isFixed(row, col)) {
        // Track if game was already over before this move
        bool wasGameOver = metaState.gameState!.gameOver;

        setState(() {
          // Marking mode
          if (metaState.gameState!.selectedNumber == 0) {
            metaState.gameState!.toggleMark(row, col);
            return;
          }

          // if same number is already placed, remove it
          if (metaState.gameState!.gameTable[row][col].numbers.contains(
            metaState.gameState!.selectedNumber!,
          )) {
            metaState.gameState!.removeNumber(
              row,
              col,
              metaState.gameState!.selectedNumber!,
            );
          } else {
            // if not fixed just place it anyways
            metaState.gameState!.placeNumber(
              row,
              col,
              metaState.gameState!.selectedNumber!,
            );
          }
        });

        // Check game over immediately after move - only show dialog if game just ended
        if (!wasGameOver && metaState.gameState!.gameOver) {
          _stopTimer();
          metaState.saveGame();

          // Capture values before showing dialog to avoid null access if game is closed
          final timeStr = GameState.formatTime(
            metaState.gameState!.elapsedSeconds,
          );
          final diffStr = metaState.gameState!.difficulty.name.toUpperCase();

          if (_navigatorKey.currentContext != null) {
            showDialog(
              context: _navigatorKey.currentContext!,
              barrierDismissible: false,
              builder: (context) => VictoryDialog(
                time: timeStr,
                difficulty: diffStr,
                onNewGame: () {
                  Navigator.pop(context); // Close dialog
                  _exitGame(context); // Clean exit first
                  _showDifficultyDialog(context); // Start new flow
                },
                onMenu: () {
                  Navigator.pop(context); // Close dialog
                  _exitGame(context);
                },
                onSpectate: () {
                  Navigator.pop(context); // Close dialog, stay on page
                },
              ),
            );
          }
        }
      }
    }
  }

  String _getHighscoreDisplay() {
    if (!metaState.inGame()) return "";
    metaState.calculateHighscores();
    int highscore = 0;
    switch (metaState.gameState!.difficulty) {
      case Difficulty.easy:
        highscore = metaState.highscoreEasy;
        break;
      case Difficulty.medium:
        highscore = metaState.highscoreMedium;
        break;
      case Difficulty.hard:
        highscore = metaState.highscoreHard;
        break;
    }
    if (highscore == 0) return "";
    return "  (Best: ${GameState.formatTime(highscore)})";
  }

  void _exitGame(BuildContext context) {
    setState(() {
      metaState.closeGame();
    });
  }

  void _selectNumber(int number) {
    if (!metaState.inGame()) return;
    setState(() {
      if (metaState.gameState!.selectedNumber == number) {
        metaState.gameState!.deselectNumber();
      } else {
        metaState.gameState!.selectNumber(number);
      }
    });
  }

  void _deselectNumber() {
    if (!metaState.inGame()) return;
    setState(() {
      metaState.gameState!.deselectNumber();
    });
  }
}
