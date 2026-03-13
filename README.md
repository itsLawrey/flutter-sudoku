# Sudoku

> A feature-rich, cross-platform Sudoku game that dynamically generates unique, solvable puzzles with real-time error checking and persistent saves.

[![Demo/Live App](https://img.shields.io/badge/Live_Demo-Link-blue)](https://itslawrey-sudoku.web.app/) 

## Visuals



## Tech Stack

* **Frontend:** Flutter / Dart 3.9.2
* **Backend/BaaS:** None (Offline-first architecture)
* **Local Storage:** Hive (NoSQL database for fast, synchronous reads/writes)
* **State Management:** Flutter Native State (`setState`) with a centralized `MetaState` architecture
* **Key Libraries:** `hive` & `hive_flutter` for local persistence

## Core Features

* **Algorithmic Puzzle Generation:** Dynamically generates Easy, Medium, and Hard puzzles using a randomized backtracking solver, mathematically guaranteeing that every board has exactly one unique solution.
* **Multi-Number Candidate Mode (Notes):** Allows players to pencil in multiple potential numbers per cell (notes) and effortlessly toggle them, streamlining the advanced solving process.
* **Favourite / Marking System:** Includes a quick-access star (☆) button to highlight specific cells in amber.
* **Real-time Conflict Highlighting:** Instantly validates user input against Sudoku rules, highlighting any row, column, or 3x3 grid conflicts in red to provide immediate feedback.
* **Intelligent Auto-Saving & History:** Automatically saves the game state every second, maintaining a reverse-chronological history of all past and active games that can be renamed, resumed, or deleted at any time.
* **Keyboard Navigation Support:** Fully supports physical keyboard inputs (standard 1-9, numpad, escape, backspace) using Flutter's `CallbackShortcuts`, providing a seamless and highly responsive experience on Desktop and Web platforms.
* **Highscore Tracking:** Persistently tracks and updates the personal best clear times across all three difficulty levels, displaying them prominently on the landing page and during active gameplay.

## Technical Architecture & Challenges

### State Management & Performance
To keep the application lightweight, I opted for simple state management using Flutter's native `setState`, orchestrated through a master `MetaState` object injected at the top of the widget tree. The `MetaState` holds the active `GameState` and handles side-effects like saving and timer updates. By breaking the UI into independent components like the `NumberPad` and `SudokuGrid`, I minimized unnecessary widget rebuilds. Only the mutated cells or specific UI elements are refreshed during rapid user input, preventing frame drops during gameplay.

### Algorithmic Generation & Uniqueness
Ensuring every generated Sudoku puzzle is genuinely solvable and has only *one* valid solution was a major technical hurdle. I implemented a backtracking algorithm that first generates a completely full, valid 9x9 board. From there, it strategically removes numbers while using a standalone `Solver` class to continuously verify that the resulting board still has exactly one solution. If removing a number creates multiple possible solutions, the algorithm backtracks and tries another cell.

### Offline-First Persistence with Hive
For the save system, I needed a database that was incredibly fast and could handle synchronous operations, as the game saves its state every single second. I chose Hive because it's a lightweight NoSQL key-value store crafted purely in Dart. I wrote custom `TypeAdapter`s for my core classes (`GameState`, `MultiCell`, `Difficulty`) to serialize the complex nested lists of the game board directly into binary storage. This ensures that even if you close the app unexpectedly, you won't lose a single second of your progress.

## Installation & Local Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/itsLawrey/flutter-sudoku.git
   ```

2. Navigate into the project directory:
   ```bash
   cd flutter-sudoku
   ```

3. Fetch all required dependencies:
   ```bash
   flutter pub get
   ```

4. Run the application:
   ```bash
   flutter run
   ```
