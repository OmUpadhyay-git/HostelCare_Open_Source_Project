import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint.dart';
import '../models/complaint_category.dart';
import '../models/complaint_history.dart';
import '../models/complaint_image.dart';
import '../models/staff.dart';
import '../models/warden.dart';
import '../repositories/warden_repository.dart';

/// Warden repository provider
final wardenRepositoryProvider = Provider<WardenRepository>((ref) {
  return WardenRepository();
});

/// Warden record provider
final wardenRecordProvider = FutureProvider<WardenRecord?>((ref) async {
  final repository = ref.watch(wardenRepositoryProvider);
  return repository.getWardenRecord();
});

/// Warden complaint counts provider
final wardenComplaintCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(wardenRepositoryProvider);
  return repository.getComplaintCounts();
});

/// Warden complaint list filter state
class WardenComplaintFilter {
  final String? status;
  final String? categoryId;
  final String? priority;
  final String? search;

  const WardenComplaintFilter({
    this.status,
    this.categoryId,
    this.priority,
    this.search,
  });

  WardenComplaintFilter copyWith({
    String? status,
    String? categoryId,
    String? priority,
    String? search,
    bool clearStatus = false,
    bool clearCategory = false,
    bool clearPriority = false,
    bool clearSearch = false,
  }) {
    return WardenComplaintFilter(
      status: clearStatus ? null : (status ?? this.status),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      priority: clearPriority ? null : (priority ?? this.priority),
      search: clearSearch ? null : (search ?? this.search),
    );
  }

  bool get isEmpty =>
      status == null && categoryId == null && priority == null && search == null;
}

/// Warden complaint list notifier
class WardenComplaintListNotifier extends StateNotifier<AsyncValue<List<Complaint>>> {
  final WardenRepository _repository;
  WardenComplaintFilter _filter;
  int _offset;
  static const int _limit = 20;

  WardenComplaintListNotifier(this._repository)
      : _filter = const WardenComplaintFilter(),
        _offset = 0,
        super(const AsyncValue.loading()) {
    loadComplaints();
  }

  WardenComplaintFilter get filter => _filter;

  Future<void> loadComplaints({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      state = const AsyncValue.loading();
    }

    try {
      final complaints = await _repository.getComplaints(
        limit: _limit,
        offset: _offset,
        status: _filter.status,
        categoryId: _filter.categoryId,
        priority: _filter.priority,
        search: _filter.search,
      );

      if (refresh || _offset == 0) {
        state = AsyncValue.data(complaints);
      } else {
        final existing = state.valueOrNull ?? [];
        state = AsyncValue.data([...existing, ...complaints]);
      }

      _offset += complaints.length;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadMore() async {
    await loadComplaints();
  }

  Future<void> updateFilter(WardenComplaintFilter newFilter) async {
    _filter = newFilter;
    _offset = 0;
    await loadComplaints(refresh: true);
  }

  Future<void> clearFilters() async {
    _filter = const WardenComplaintFilter();
    _offset = 0;
    await loadComplaints(refresh: true);
  }

  bool get hasMore => (state.valueOrNull?.length ?? 0) >= _limit;
}

/// Warden complaint list provider
final wardenComplaintListProvider =
    StateNotifierProvider<WardenComplaintListNotifier, AsyncValue<List<Complaint>>>((ref) {
  final repository = ref.watch(wardenRepositoryProvider);
  return WardenComplaintListNotifier(repository);
});

/// Single complaint provider for warden
final wardenComplaintDetailProvider =
    FutureProvider.family<Complaint?, String>((ref, complaintId) async {
  final repository = ref.watch(wardenRepositoryProvider);
  return repository.getComplaintById(complaintId);
});

/// Complaint history provider for warden
final wardenComplaintHistoryProvider =
    FutureProvider.family<List<ComplaintHistory>, String>((ref, complaintId) async {
  final repository = ref.watch(wardenRepositoryProvider);
  return repository.getComplaintHistory(complaintId);
});

/// Complaint images provider for warden
final wardenComplaintImagesProvider =
    FutureProvider.family<List<ComplaintImage>, String>((ref, complaintId) async {
  final repository = ref.watch(wardenRepositoryProvider);
  return repository.getComplaintImages(complaintId);
});

/// Available staff provider
final wardenAvailableStaffProvider = FutureProvider<List<StaffMember>>((ref) async {
  final repository = ref.watch(wardenRepositoryProvider);
  return repository.getAvailableStaff();
});

/// Categories provider for warden filters
final wardenCategoriesProvider = FutureProvider<List<ComplaintCategory>>((ref) async {
  // Categories are loaded via the same complaint query pattern
  return [];
});
