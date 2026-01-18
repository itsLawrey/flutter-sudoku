import 'package:flutter/material.dart';

class GameHistoryCard extends StatefulWidget {
  final int index;
  final String date;
  final String difficulty;
  final bool isCompleted;
  final String time;
  final String gameName;
  final VoidCallback? onActionTap;
  final VoidCallback? onDelete;
  final Function(String) onRename;

  const GameHistoryCard({
    super.key,
    required this.index,
    required this.date,
    required this.difficulty,
    required this.isCompleted,
    required this.time,
    required this.gameName,
    required this.onRename,
    this.onActionTap,
    this.onDelete,
  });

  @override
  State<GameHistoryCard> createState() => _GameHistoryCardState();
}

class _GameHistoryCardState extends State<GameHistoryCard> {
  bool isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.gameName.isNotEmpty
          ? widget.gameName
          : 'Game #${widget.index}',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _stopEditing();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      isEditing = true;
    });
    _focusNode.requestFocus();

    // Wait for the keyboard to likely appear or the widget to rebuild
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5, // Center the item in the viewport if possible
        );
      }
    });
  }

  void _stopEditing() {
    setState(() {
      isEditing = false;
    });
    widget.onRename(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    // If the game name changes externally (e.g. initial load), update controller
    if (!isEditing &&
        _controller.text !=
            (widget.gameName.isNotEmpty
                ? widget.gameName
                : 'Game #${widget.index}')) {
      _controller.text = widget.gameName.isNotEmpty
          ? widget.gameName
          : 'Game #${widget.index}';
    }

    return Card(
      color: const Color(0xFF2A2A3C),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.date,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.stairs, size: 16, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        widget.difficulty,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        widget.isCompleted
                            ? Icons.check_circle_outline
                            : Icons.access_time,
                        size: 16,
                        color: widget.isCompleted
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.isCompleted ? 'Completed' : 'In Progress',
                        style: TextStyle(
                          color: widget.isCompleted
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.timer, size: 16, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        widget.time,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(children: [_buildDeleteButton(context)]),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(children: [_buildActionButton(context)]),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    if (isEditing) {
      return FractionallySizedBox(
        widthFactor: 0.7,
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 24, // Match typical text height
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLength: 100,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              counterText: "",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            onSubmitted: (_) => _stopEditing(),
          ),
        ),
      );
    } else {
      return FractionallySizedBox(
        widthFactor: 0.7,
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: _startEditing,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  widget.gameName.isNotEmpty
                      ? widget.gameName
                      : 'Game #${widget.index}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(
                  top: 4.0,
                ), // Align icon visually with text cap height
                child: Icon(Icons.edit, size: 14, color: Colors.white24),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActionButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onActionTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isCompleted
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color:
                (widget.isCompleted ? Colors.greenAccent : Colors.orangeAccent)
                    .withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isCompleted
                    ? Colors.greenAccent == Colors.greenAccent
                          ? Icons.visibility
                          : Icons.visibility
                    : widget.isCompleted
                    ? Icons.visibility
                    : Icons.play_arrow,
                color: widget.isCompleted
                    ? Colors.greenAccent
                    : Colors.orangeAccent,
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                widget.isCompleted ? 'View' : 'Continue',
                style: TextStyle(
                  color: widget.isCompleted
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onDelete,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
            SizedBox(width: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
