import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/workout_session.dart';
import '../models/workout_split.dart';
import '../models/workout_template.dart';
import '../services/workouts_service.dart';

final workoutsServiceProvider = Provider<WorkoutsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WorkoutsService(apiClient: apiClient);
});

class WorkoutsState {
  final bool isLoading;
  final WorkoutSplitDetail? activeSplit;
  final List<WorkoutSplitSummary> splits;
  final List<WorkoutTemplateSummary> templates;
  final List<WorkoutSession> recentSessions;
  final String? errorMessage;

  const WorkoutsState({
    required this.isLoading,
    this.activeSplit,
    required this.splits,
    required this.templates,
    required this.recentSessions,
    this.errorMessage,
  });

  const WorkoutsState.initial()
      : isLoading = true,
        activeSplit = null,
        splits = const [],
        templates = const [],
        recentSessions = const [],
        errorMessage = null;

  WorkoutsState copyWith({
    bool? isLoading,
    WorkoutSplitDetail? activeSplit,
    bool clearActiveSplit = false,
    List<WorkoutSplitSummary>? splits,
    List<WorkoutTemplateSummary>? templates,
    List<WorkoutSession>? recentSessions,
    String? errorMessage,
  }) {
    return WorkoutsState(
      isLoading: isLoading ?? this.isLoading,
      activeSplit: clearActiveSplit ? null : (activeSplit ?? this.activeSplit),
      splits: splits ?? this.splits,
      templates: templates ?? this.templates,
      recentSessions: recentSessions ?? this.recentSessions,
      errorMessage: errorMessage,
    );
  }
}

class WorkoutsNotifier extends StateNotifier<WorkoutsState> {
  final WorkoutsService _service;

  WorkoutsNotifier(this._service) : super(const WorkoutsState.initial()) {
    loadWorkoutsData();
  }

  Future<void> loadWorkoutsData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final activeSplitFuture = _service.getActiveSplit();
      final splitsFuture = _service.listSplits();
      final templatesFuture = _service.listTemplates();
      final sessionsFuture = _service.listSessions();

      final results = await Future.wait([
        activeSplitFuture,
        splitsFuture,
        templatesFuture,
        sessionsFuture,
      ]);

      state = state.copyWith(
        isLoading: false,
        activeSplit: results[0] as WorkoutSplitDetail?,
        splits: results[1] as List<WorkoutSplitSummary>,
        templates: results[2] as List<WorkoutTemplateSummary>,
        recentSessions: results[3] as List<WorkoutSession>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> activateSplit(String splitId) async {
    try {
      await _service.activateSplit(splitId);
      await loadWorkoutsData();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> createSplitFromTemplate(String name, String templateId) async {
    try {
      final newSplit = await _service.createSplitFromTemplate(name, templateId);
      await _service.activateSplit(newSplit.id);
      await loadWorkoutsData();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<WorkoutSession?> logSession({
    String? splitId,
    String? splitDayId,
    required String label,
    required String sessionDate,
    String notes = '',
    required List<WorkoutSessionSet> sets,
  }) async {
    try {
      final session = await _service.logSession(
        splitId: splitId,
        splitDayId: splitDayId,
        label: label,
        sessionDate: sessionDate,
        notes: notes,
        sets: sets,
      );
      state = state.copyWith(recentSessions: [session, ...state.recentSessions]);
      return session;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }
}

final workoutsNotifierProvider =
    StateNotifierProvider<WorkoutsNotifier, WorkoutsState>((ref) {
  final service = ref.watch(workoutsServiceProvider);
  return WorkoutsNotifier(service);
});

