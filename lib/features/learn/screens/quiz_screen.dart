import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/module.dart';
import '../models/question_state.dart';
import '../providers/modules_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/quiz_option_tile.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.moduleId});
  final String moduleId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;

  // Maps question index → chosen option index
  final Map<int, int> _answers = {};

  // Whether the answer for the current question has been revealed
  bool _revealed = false;

  // True when all questions are answered
  bool _showResults = false;

  void _selectOption(int optionIndex) {
    if (_revealed) return; // already answered
    setState(() {
      _answers[_currentIndex] = optionIndex;
      _revealed = true;
    });
  }

  void _next(int totalQuestions) {
    if (_currentIndex < totalQuestions - 1) {
      setState(() {
        _currentIndex++;
        _revealed = _answers.containsKey(_currentIndex);
      });
    } else {
      setState(() => _showResults = true);
    }
  }

  int _score(List<Question> questions) {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (_answers[i] == questions[i].correctIndex) score++;
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final moduleAsync = ref.watch(moduleByIdProvider(widget.moduleId));

    return moduleAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (module) {
        if (module == null) return const Scaffold(body: Center(child: Text('Not found')));
        final questions = module.quiz.questions;

        if (_showResults) {
          return _ResultsScreen(
            module: module,
            score: _score(questions),
            total: questions.length,
            onSave: () {
              ref
                  .read(progressProvider.notifier)
                  .saveQuizResult(widget.moduleId, _score(questions), questions.length);
            },
            onRetry: () => setState(() {
              _answers.clear();
              _currentIndex = 0;
              _revealed = false;
              _showResults = false;
            }),
            onDone: () => Navigator.of(context).pop(),
          );
        }

        final q = questions[_currentIndex];
        final chosen = _answers[_currentIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text('${module.title} — Quiz'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / questions.length,
                minHeight: 4,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(module.color),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question counter
                Text(
                  'Question ${_currentIndex + 1} of ${questions.length}',
                  style: TextStyle(
                    fontSize: 13,
                    color: module.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Question text
                Text(q.question,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3)),
                const SizedBox(height: 28),

                // Options
                ...List.generate(q.options.length, (i) {
                  final state = !_revealed
                      ? OptionState.idle
                      : i == q.correctIndex
                          ? OptionState.correct
                          : i == chosen
                              ? OptionState.wrong
                              : OptionState.idle;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QuizOptionTile(
                      label: String.fromCharCode(65 + i), // A, B, C, D
                      text: q.options[i],
                      state: state,
                      isSelected: chosen == i,
                      onTap: () => _selectOption(i),
                    ),
                  );
                }),

                // Explanation (shown after answer)
                if (_revealed) ...[
                  const SizedBox(height: 4),
                  AnimatedOpacity(
                    opacity: _revealed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: chosen == q.correctIndex
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: chosen == q.correctIndex
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            chosen == q.correctIndex
                                ? Icons.check_circle_rounded
                                : Icons.info_rounded,
                            color: chosen == q.correctIndex
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              q.explanation,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: chosen == q.correctIndex
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Next / See results button
          bottomNavigationBar: _revealed
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: module.color,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _next(questions.length),
                        child: Text(
                          _currentIndex < questions.length - 1
                              ? 'Next question'
                              : 'See results',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Results screen
// ─────────────────────────────────────────────

class _ResultsScreen extends StatefulWidget {
  const _ResultsScreen({
    required this.module,
    required this.score,
    required this.total,
    required this.onSave,
    required this.onRetry,
    required this.onDone,
  });

  final LearningModule module;
  final int score;
  final int total;
  final VoidCallback onSave;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  @override
  State<_ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<_ResultsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
    widget.onSave(); // persist result
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.total > 0 ? widget.score / widget.total : 0.0;
    final passed = pct >= 0.75;
    final emoji = pct == 1.0 ? '🏆' : passed ? '🎉' : '💪';
    final headline = pct == 1.0
        ? 'Perfect score!'
        : passed
            ? 'Well done!'
            : 'Keep practising!';
    final sub = passed
        ? 'You passed the quiz. Great work!'
        : 'You need 75% to pass. Review the lessons and try again.';

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score ring
              ScaleTransition(
                scale: _anim,
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: pct,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            passed ? widget.module.color : Colors.red.shade400,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 32)),
                          Text(
                            '${widget.score}/${widget.total}',
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${(pct * 100).round()}%',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Text(headline,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(sub,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15, color: Colors.grey.shade600, height: 1.5)),
              const SizedBox(height: 48),

              // Retry
              if (!passed)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: widget.onRetry,
                    child: const Text('Try again',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: passed
                        ? widget.module.color
                        : Colors.grey.shade800,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: widget.onDone,
                  child: Text(
                    passed ? 'Back to modules' : 'Review lessons',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
