/// Data model representing a max-rep attempt submitted by a user.
class AttemptModel {
  final String id;
  final String userId;
  final String exercise;
  final int reps;
  final String proofType;
  final String? videoUrl;
  final String status; // 'pending' | 'verified' | 'rejected'
  final String createdAt;
  final String? verifiedAt;
  final String? verifiedBy;
  final String? reviewNotes;

  const AttemptModel({
    required this.id,
    required this.userId,
    required this.exercise,
    required this.reps,
    required this.proofType,
    this.videoUrl,
    required this.status,
    required this.createdAt,
    this.verifiedAt,
    this.verifiedBy,
    this.reviewNotes,
  });

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';

  factory AttemptModel.fromJson(Map<String, dynamic> json) {
    return AttemptModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      exercise: json['exercise'] as String? ?? 'pushup',
      reps: json['reps'] as int? ?? 0,
      proofType: json['proof_type'] as String? ?? 'manual',
      videoUrl: json['video_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String? ?? '',
      verifiedAt: json['verified_at'] as String?,
      verifiedBy: json['verified_by'] as String?,
      reviewNotes: json['review_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exercise': exercise,
      'reps': reps,
      'proof_type': proofType,
      'video_url': videoUrl,
      'status': status,
      'created_at': createdAt,
      'verified_at': verifiedAt,
      'verified_by': verifiedBy,
      'review_notes': reviewNotes,
    };
  }
}

/// Data model representing a competitor in the challenge leaderboard.
class LeaderboardEntryModel {
  final int rank;
  final String userId;
  final String displayName;
  final String username;
  final String? area;
  final String? district;
  final String? state;
  final int bestReps;

  const LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.username,
    this.area,
    this.district,
    this.state,
    required this.bestReps,
  });

  String get locationLabel {
    final parts = [area, district, state].where((p) => p != null && p.isNotEmpty).toList();
    return parts.isEmpty ? 'Tamil Nadu' : parts.join(', ');
  }

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] as int? ?? 0,
      userId: json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Anonymous',
      username: json['username'] as String? ?? '',
      area: json['area'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      bestReps: json['best_reps'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'display_name': displayName,
      'username': username,
      'area': area,
      'district': district,
      'state': state,
      'best_reps': bestReps,
    };
  }
}

/// Paginated leaderboard response payload from the backend.
class LeaderboardResponseModel {
  final String exercise;
  final String scope;
  final String period;
  final int total;
  final int limit;
  final int offset;
  final List<LeaderboardEntryModel> entries;
  final LeaderboardEntryModel? myRank;

  const LeaderboardResponseModel({
    required this.exercise,
    required this.scope,
    required this.period,
    required this.total,
    required this.limit,
    required this.offset,
    required this.entries,
    this.myRank,
  });

  factory LeaderboardResponseModel.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'] as List<dynamic>? ?? [];
    final entries = rawEntries
        .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    LeaderboardEntryModel? myRank;
    if (json['my_rank'] != null && json['my_rank'] is Map<String, dynamic>) {
      myRank = LeaderboardEntryModel.fromJson(json['my_rank'] as Map<String, dynamic>);
    }

    return LeaderboardResponseModel(
      exercise: json['exercise'] as String? ?? 'pushup',
      scope: json['scope'] as String? ?? 'district',
      period: json['period'] as String? ?? 'all_time',
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
      offset: json['offset'] as int? ?? 0,
      entries: entries,
      myRank: myRank,
    );
  }
}

