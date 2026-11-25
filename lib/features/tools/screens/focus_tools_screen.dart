import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/todo_item.dart';
import '../services/focus_service.dart';
import '../services/todos_service.dart';

final focusServiceProvider = Provider<FocusService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FocusService(apiClient: apiClient);
});

final todosServiceProvider = Provider<TodosService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TodosService(apiClient: apiClient);
});

class FocusToolsScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const FocusToolsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<FocusToolsScreen> createState() => _FocusToolsScreenState();
}

class _FocusToolsScreenState extends ConsumerState<FocusToolsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Focus Timer State
  int _selectedDurationMinutes = 25;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  String _sessionType = 'Focus'; // 'Focus' or 'Meditation'

  // Todos State
  List<TodoItem> _todos = [];
  bool _isLoadingTodos = true;
  String? _todosError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _loadTodos();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // --- Focus Timer Logic ---
  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    HapticFeedback.mediumImpact();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _handleSessionCompleted();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    HapticFeedback.lightImpact();
  }

  void _resetTimer([int? newMinutes]) {
    _timer?.cancel();
    final mins = newMinutes ?? _selectedDurationMinutes;
    setState(() {
      _selectedDurationMinutes = mins;
      _remainingSeconds = mins * 60;
      _isRunning = false;
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _handleSessionCompleted() async {
    HapticFeedback.heavyImpact();
    try {
      final service = ref.read(focusServiceProvider);
      await service.logFocusSession(
        sessionType: _sessionType,
        durationMinutes: _selectedDurationMinutes,
      );
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.bgCardSolid,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
            title: Text('FOCUS COMPLETE! 🧘', style: AppTypography.headingLarge),
            content: Text(
              '$_selectedDurationMinutes minutes of deep discipline logged to your Hunter profile! +XP',
              style: AppTypography.bodyMedium,
            ),
            actions: [
              PrimaryButton(
                text: 'CONTINUE',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _resetTimer();
                },
              ),
            ],
          ),
        );
      }
    } catch (_) {
      _resetTimer();
    }
  }

  // --- Todos Logic ---
  Future<void> _loadTodos() async {
    setState(() {
      _isLoadingTodos = true;
      _todosError = null;
    });
    try {
      final service = ref.read(todosServiceProvider);
      final list = await service.listTodos();
      if (mounted) {
        setState(() {
          _todos = list;
          _isLoadingTodos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _todosError = e.toString();
          _isLoadingTodos = false;
        });
      }
    }
  }

  Future<void> _toggleTodo(TodoItem item) async {
    HapticFeedback.lightImpact();
    final newStatus = item.isDone ? 'todo' : 'done';
    try {
      final service = ref.read(todosServiceProvider);
      final updated = await service.updateTodo(item.id, status: newStatus);
      setState(() {
        _todos = _todos.map((t) => t.id == item.id ? updated : t).toList();
      });
    } catch (_) {}
  }

  Future<void> _deleteTodo(String id) async {
    HapticFeedback.mediumImpact();
    try {
      final service = ref.read(todosServiceProvider);
      await service.deleteTodo(id);
      setState(() {
        _todos = _todos.where((t) => t.id != id).toList();
      });
    } catch (_) {}
  }

  void _showAddTodoDialog() {
    final titleCtrl = TextEditingController();
    String priority = 'medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCardSolid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('ADD DAILY QUEST', style: AppTypography.headingMedium),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: titleCtrl,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Quest description',
                  hintText: 'e.g. 100 push-ups, drink 3L water',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text('Priority: ', style: AppTypography.bodySmall),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Low'),
                    selected: priority == 'low',
                    onSelected: (s) => setSheetState(() => priority = 'low'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Medium'),
                    selected: priority == 'medium',
                    onSelected: (s) => setSheetState(() => priority = 'medium'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('High'),
                    selected: priority == 'high',
                    onSelected: (s) => setSheetState(() => priority = 'high'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: 'ACCEPT QUEST',
                onPressed: () async {
                  final text = titleCtrl.text.trim();
                  if (text.isEmpty) return;
                  Navigator.of(ctx).pop();
                  try {
                    final service = ref.read(todosServiceProvider);
                    final created = await service.createTodo(text, priority: priority);
                    setState(() => _todos.insert(0, created));
                  } catch (_) {}
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('FOCUS & QUESTS', style: AppTypography.headingMedium),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTypography.labelLarge,
          tabs: const [
            Tab(icon: Icon(Icons.timer_outlined), text: 'FOCUS TIMER'),
            Tab(icon: Icon(Icons.checklist_rounded), text: 'DAILY QUESTS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFocusTimerView(),
          _buildQuestsView(),
        ],
      ),
    );
  }

  // --- View 1: Focus Timer ---
  Widget _buildFocusTimerView() {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final totalSecs = _selectedDurationMinutes * 60;
    final progress = totalSecs > 0 ? (totalSecs - _remainingSeconds) / totalSecs : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          // Type Selector Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('⚡ Deep Focus'),
                selected: _sessionType == 'Focus',
                onSelected: (s) {
                  if (s) setState(() => _sessionType = 'Focus');
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('🧘 Meditation'),
                selected: _sessionType == 'Meditation',
                onSelected: (s) {
                  if (s) setState(() => _sessionType = 'Meditation');
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Cyber Countdown Display Ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppColors.bgCardSolid,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 48,
                      letterSpacing: 2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRunning ? 'LOCKED IN' : 'READY',
                    style: AppTypography.badge.copyWith(
                      color: _isRunning ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Presets Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [15, 25, 45, 60].map((m) {
              final isSel = _selectedDurationMinutes == m && !_isRunning;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSel ? AppColors.primaryMuted : Colors.transparent,
                    foregroundColor: isSel ? AppColors.primary : AppColors.textSecondary,
                    side: BorderSide(color: isSel ? AppColors.primary : AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isRunning ? null : () => _resetTimer(m),
                  child: Text('${m}m'),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning)
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: const Text('START SESSION'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.bgMain,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _startTimer,
                )
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.pause_rounded, size: 28),
                  label: const Text('PAUSE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: AppColors.bgMain,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _pauseTimer,
                ),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                tooltip: 'Reset',
                onPressed: () => _resetTimer(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- View 2: Quests (Todos) ---
  Widget _buildQuestsView() {
    if (_isLoadingTodos) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_todosError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_todosError!, style: AppTypography.bodySmall.copyWith(color: AppColors.danger)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadTodos, child: const Text('RETRY')),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add, color: AppColors.bgMain),
      ),
      body: _todos.isEmpty
          ? Center(
              child: Text('No active quests. Tap + to accept a quest!', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _todos.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (ctx, index) {
                final t = _todos[index];
                return Dismissible(
                  key: Key(t.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.danger,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteTodo(t.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.bgCardSolid,
                      borderRadius: AppSpacing.roundedMd,
                      border: Border.all(color: t.isDone ? AppColors.accentGreen.withValues(alpha: 0.3) : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: t.isDone,
                          activeColor: AppColors.accentGreen,
                          onChanged: (_) => _toggleTodo(t),
                        ),
                        Expanded(
                          child: Text(
                            t.title,
                            style: AppTypography.bodyMedium.copyWith(
                              decoration: t.isDone ? TextDecoration.lineThrough : null,
                              color: t.isDone ? AppColors.textMuted : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: t.priority == 'high'
                                ? AppColors.danger.withValues(alpha: 0.2)
                                : AppColors.bgSidebar,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            t.priority.toUpperCase(),
                            style: AppTypography.badge.copyWith(
                              fontSize: 9,
                              color: t.priority == 'high' ? AppColors.danger : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
