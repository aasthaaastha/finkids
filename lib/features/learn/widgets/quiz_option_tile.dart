import 'package:flutter/material.dart';
import '../models/question_state.dart';

/// A single quiz answer option with idle / correct / wrong visual states.
class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.label,    // "A", "B", "C", "D"
    required this.text,     // The answer text
    required this.state,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String text;
  final OptionState state;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(state, isSelected);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: state == OptionState.idle && !isSelected ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Label bubble
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors.labelBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.labelText,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Answer text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: colors.text,
                      fontWeight: isSelected || state == OptionState.correct
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),

                // State icon
                if (state == OptionState.correct)
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 20)
                else if (state == OptionState.wrong && isSelected)
                  const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _OptionColors _resolveColors(OptionState state, bool isSelected) {
    switch (state) {
      case OptionState.correct:
        return _OptionColors(
          bg: Colors.green.shade50,
          border: Colors.green.shade400,
          text: Colors.green.shade900,
          labelBg: Colors.green.shade400,
          labelText: Colors.white,
        );
      case OptionState.wrong:
        if (isSelected) {
          return _OptionColors(
            bg: Colors.red.shade50,
            border: Colors.red.shade300,
            text: Colors.red.shade900,
            labelBg: Colors.red.shade300,
            labelText: Colors.white,
          );
        }
        // Not the wrong selection — just fade it out
        return _OptionColors(
          bg: Colors.grey.shade50,
          border: Colors.grey.shade200,
          text: Colors.grey.shade400,
          labelBg: Colors.grey.shade200,
          labelText: Colors.grey.shade500,
        );
      case OptionState.idle:
        return isSelected
            ? _OptionColors(
                bg: const Color(0xFFEEEDFE),
                border: const Color(0xFF534AB7),
                text: const Color(0xFF26215C),
                labelBg: const Color(0xFF534AB7),
                labelText: Colors.white,
              )
            : _OptionColors(
                bg: Colors.white,
                border: Colors.grey.shade300,
                text: const Color(0xFF374151),
                labelBg: Colors.grey.shade100,
                labelText: Colors.grey.shade700,
              );
    }
  }
}

class _OptionColors {
  const _OptionColors({
    required this.bg,
    required this.border,
    required this.text,
    required this.labelBg,
    required this.labelText,
  });

  final Color bg;
  final Color border;
  final Color text;
  final Color labelBg;
  final Color labelText;
}
