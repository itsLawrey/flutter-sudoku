import 'package:flutter/material.dart';
import 'package:sudoku/utils/view_utils.dart';

class NewGameButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NewGameButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, // Fixed width for consistency
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ViewUtils.accentColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black45,
        ),
        child: const Text(
          'New Game',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
