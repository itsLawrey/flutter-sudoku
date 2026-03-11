# Sudoku

A feature-rich Sudoku game built with Flutter as a personal portfolio project. Developed mainly for Android, Web, and Desktop.

---

## Features

### Core Gameplay
- **Three difficulty levels** — Easy, Medium, and Hard, each generating a unique, solvable puzzle every time via a randomised backtracking algorithm.
- **Unique puzzle guarantee** — The puzzle generator uses a constraint-based solver to verify there is exactly **one valid solution** before presenting the board.
- **Symmetric board generation** — Clues are removed using rotational symmetry for a visually balanced starting grid.
- **Keyboard support** — Press keys 1–9 (or numpad) to select numbers; `Escape` / `Backspace` to deselect.

### Multi-Number Cells (Candidate Mode)
- Each cell can hold **more than one number at a time** — useful for pencilling in candidates.
- Tapping a selected number on a cell that already contains it **removes** it (toggle behaviour).
- The game only registers a win once every cell contains exactly one correct number.

### Favourite / Mark Mode
- Select the **star (☆) button** on the number pad to enter mark mode.
- Tap any single-number cell to **highlight it as a favourite** — useful for tracking key cells during solving.

### Error Highlighting
- Selecting a number from the pad **instantly highlights all conflicting rows, columns, and 3×3 boxes** in red.
- Conflicts update in real time as you place or remove numbers.
- A colour legend is available in the side drawer:
  - **White** — Fixed (given) clue
  - **Red** — Conflict
  - **Blue** — Fully and correctly placed number
  - **Green** — Victory state
  - **Amber** — Marked / favourited cell

### Save & Load
- Games are **automatically saved** as you play (every second via the live timer).
- The home screen shows a **full history of all your games**, sorted by most recent.
- Resume any in-progress game or revisit a completed one with a single tap.

### Rename Saves
- Every saved game shows an editable title — tap the name (with the pencil icon) to **rename it inline**.
- Renames persist immediately to local storage.

### Delete Saves
- Swipe or tap the **Delete** button on any game card to remove it, with a confirmation dialog to prevent accidents.

### Best Times / Highscores
- The app tracks your **personal best time** for each difficulty (Easy / Medium / Hard).
- Best times are shown on the home screen highscore board.
- Your current best is displayed **live in the app bar** while you're playing, so you always know if you're on pace for a record.

### Victory Screen
- Completing a puzzle triggers a **victory dialog** showing your time and difficulty.
- Options to start a new game, return to the menu, or **spectate the finished board**.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | Cross-platform UI framework |
| [Hive](https://pub.dev/packages/hive) | Lightweight local persistence (no server needed) |
| [Confetti](https://pub.dev/packages/confetti) | Victory celebration animation |

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.9.2`
- Dart SDK (included with Flutter)

### Run Locally

```bash
git clone https://github.com/your-username/sudoku.git
cd sudoku
flutter pub get
flutter run
```

Targets Android, iOS, Web, Linux, macOS, and Windows out of the box.

---

## Project Structure

```
lib/
├── main.dart               # App entry point, game loop & timer
├── pages/
│   └── landing_page.dart   # Home screen: highscores + game history
├── widgets/
│   ├── sudoku_grid.dart    # The 9×9 board
│   ├── number_pad.dart     # Number selector with star/mark mode
│   ├── game_history_card.dart  # Save slot cards with rename/delete
│   └── dialogs/            # Victory, difficulty, delete dialogs
└── utils/
    └── model/
        ├── game_state.dart  # Core game logic, error tracking, win detection
        ├── multicell.dart   # Multi-number cell model
        ├── meta_state.dart  # Save/load/highscore management
        └── solver.dart      # Backtracking solver (uniqueness check)
```

---

## Screenshots

> *Coming soon*

