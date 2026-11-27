import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/workout_session.dart';

class WorkoutHistoryView extends StatefulWidget {
  final List<WorkoutSession> sessions;
  final VoidCallback onRefresh;

  const WorkoutHistoryView({
    super.key,
    required this.sessions,
    required this.onRefresh,
  });

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> {
  String _selectedFilter = 'ALL';
  String? _selectedExerciseForChart;

  @override
  Widget build(BuildContext context) {
    if (widget.sessions.isEmpty) {
      return _buildEmptyHistory();
    }

    // Extract unique labels / routines for filtering
    final labels = ['ALL'];
    for (final s in widget.sessions) {
      final label = s.dayLabel.trim();
      if (label.isNotEmpty && !labels.contains(label)) {
        labels.add(label);
      }
    }

    // Extract all unique exercises for progress charting
    final allExercises = <String>{};
    for (final s in widget.sessions) {
      for (final st in s.sets) {
        if (st.exerciseName.trim().isNotEmpty) {
          allExercises.add(st.exerciseName.trim());
        }
      }
    }
    final exerciseList = allExercises.toList()..sort();
    if (_selectedExerciseForChart == null && exerciseList.isNotEmpty) {
      _selectedExerciseForChart = exerciseList.first;
    }

    final filteredSessions = _selectedFilter == 'ALL'
        ? widget.sessions
        : widget.sessions.where((s) => s.dayLabel.trim() == _selectedFilter).toList();

    // Compute metrics
    int totalSets = 0;
    double totalVolume = 0;
    for (final s in widget.sessions) {
      totalSets += s.sets.length;
      for (final st in s.sets) {
        totalVolume += st.reps * (st.weightKg ?? 0);
      }
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 1. Top HUD Analytics Banner
          _buildAnalyticsBanner(
            totalSessions: widget.sessions.length,
            totalVolumeKg: totalVolume,
            totalSets: totalSets,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Exercise Progress Line Chart (CustomPainter)
          if (exerciseList.isNotEmpty && _selectedExerciseForChart != null) ...[
            _buildExerciseChartSection(exerciseList),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 3. Routine Filter Chips
          if (labels.length > 2) ...[
            Text('FILTER BY TEMPLATE ROUTINE', style: AppTypography.labelSmall),
            const SizedBox(height: AppSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: labels.map((l) {
                  final isSelected = _selectedFilter == l;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(l.toUpperCase()),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = l);
                      },
                      selectedColor: AppColors.primaryMuted,
                      backgroundColor: AppColors.bgCardSolid,
                      labelStyle: AppTypography.labelSmall.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SESSION LOGS', style: AppTypography.labelMedium),
              Text(
                '${filteredSessions.length} sessions',
                style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 4. Session Cards
          ...filteredSessions.map((session) => _buildSessionCard(session)),

          const SizedBox(height: 70), // Floating nav bar padding
        ],
      ),
    );
  }

  Widget _buildExerciseChartSection(List<String> exercises) {
    final selectedEx = _selectedExerciseForChart!;
    final points = <_ChartPoint>[];

    // Collect chronologically sorted session data points
    final chronological = List<WorkoutSession>.from(widget.sessions)
      ..sort((a, b) => a.sessionDate.compareTo(b.sessionDate));

    for (final s in chronological) {
      double best1RM = 0;
      for (final st in s.sets) {
        if (st.exerciseName.trim().toLowerCase() == selectedEx.toLowerCase()) {
          final w = st.weightKg;
          if (w != null && w > 0) {
            final e1rm = w * (1.0 + st.reps / 30.0);
            if (e1rm > best1RM) best1RM = e1rm;
          } else if (st.reps > 0 && best1RM == 0) {
            best1RM = st.reps.toDouble();
          }
        }
      }
      if (best1RM > 0) {
        points.add(_ChartPoint(s.sessionDate, best1RM));
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PROGRESSION GRAPH', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text('Estimated 1RM (Epley Formula)', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
              DropdownButton<String>(
                value: _selectedExerciseForChart,
                dropdownColor: AppColors.bgCardSolid,
                style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 20),
                items: exercises.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedExerciseForChart = val);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (points.isEmpty)
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Text('No recorded sets for $selectedEx yet', style: AppTypography.bodySmall),
            )
          else ...[
            SizedBox(
              height: 140,
              width: double.infinity,
              child: CustomPaint(
                painter: _ExerciseChartPainter(points: points),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(points.first.date, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted, fontSize: 10)),
                Text(
                  'Latest: ${points.last.value.toStringAsFixed(1)} kg',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                Text(points.last.date, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsBanner({
    required int totalSessions,
    required double totalVolumeKg,
    required int totalSets,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('COMBAT WORKOUT SUMMARY', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricColumn('SESSIONS', totalSessions.toString(), Icons.fitness_center),
              _buildDivider(),
              _buildMetricColumn(
                'VOLUME',
                totalVolumeKg >= 1000
                    ? '${(totalVolumeKg / 1000).toStringAsFixed(1)}k kg'
                    : '${totalVolumeKg.toInt()} kg',
                Icons.line_weight,
              ),
              _buildDivider(),
              _buildMetricColumn('TOTAL SETS', totalSets.toString(), Icons.repeat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.border,
    );
  }

  Widget _buildMetricColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildSessionCard(WorkoutSession session) {
    // Calculate session volume
    double sessionVolume = 0;
    for (final st in session.sets) {
      sessionVolume += st.reps * (st.weightKg ?? 0);
    }

    // Group sets by exercise name
    final Map<String, List<WorkoutSessionSet>> groupedSets = {};
    for (final st in session.sets) {
      groupedSets.putIfAbsent(st.exerciseName, () => []).add(st);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        session.dayLabel.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                session.sessionDate,
                style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                '${session.sets.length} sets completed',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              if (sessionVolume > 0) ...[
                const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                Text(
                  '${sessionVolume.toInt()} kg volume',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
          if (session.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgMain,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.format_quote, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      session.notes,
                      style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(color: AppColors.border, height: 16),
          // Sets summary list
          ...groupedSets.entries.map((entry) {
            final exName = entry.key;
            final sets = entry.value;
            final setsSummary = sets.map((s) {
              final w = s.weightKg;
              return (w != null && w > 0)
                  ? '${s.reps}r @ ${w.toInt()}kg'
                  : '${s.reps} reps';
            }).join(', ');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('▸ ', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  Expanded(
                    flex: 4,
                    child: Text(
                      exName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      setsSummary,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_toggle_off, color: AppColors.textMuted, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text('No Workout History Yet', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Complete a programmed workout session or log your training to view template-based volume history.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPoint {
  final String date;
  final double value;
  const _ChartPoint(this.date, this.value);
}

class _ExerciseChartPainter extends CustomPainter {
  final List<_ChartPoint> points;
  const _ExerciseChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    const gridLines = 3;
    for (int i = 0; i <= gridLines; i++) {
      final y = size.height * (i / gridLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    double minY = points.first.value;
    double maxY = points.first.value;
    for (final p in points) {
      if (p.value < minY) minY = p.value;
      if (p.value > maxY) maxY = p.value;
    }
    if ((maxY - minY).abs() < 0.1) {
      minY -= 5;
      maxY += 5;
    } else {
      final pad = (maxY - minY) * 0.15;
      minY -= pad;
      maxY += pad;
    }

    final path = Path();
    final fillPath = Path();
    final offsets = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width / 2
          : (size.width / (points.length - 1)) * i;
      final normalizedY = (points[i].value - minY) / (maxY - minY);
      final y = size.height - (normalizedY * size.height);
      final offset = Offset(x, y.clamp(8.0, size.height - 8.0));
      offsets.add(offset);
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
        fillPath.moveTo(offset.dx, size.height);
        fillPath.lineTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
        fillPath.lineTo(offset.dx, offset.dy);
      }
    }
    fillPath.lineTo(offsets.last.dx, size.height);
    fillPath.close();

    // Gradient fill under the line
    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary.withValues(alpha: 0.25),
        AppColors.primary.withValues(alpha: 0.0),
      ],
    );
    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Glowing line
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Data points
    final dotPaint = Paint()..color = AppColors.primary;
    final dotInnerPaint = Paint()..color = AppColors.bgMain;
    for (final offset in offsets) {
      canvas.drawCircle(offset, 4.0, dotPaint);
      canvas.drawCircle(offset, 2.0, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExerciseChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

