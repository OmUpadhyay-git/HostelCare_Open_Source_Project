import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint.dart';
import '../models/complaint_category.dart';
import '../models/complaint_history.dart';
import '../models/complaint_image.dart';
import '../repositories/complaint_repository.dart';

/// Complaint repository provider
final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepository();
});

/// Categories provider
final categoriesProvider = FutureProvider<List<ComplaintCategory>>((ref) async {
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.getCategories();
});

/// Complaint counts provider
final complaintCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.getComplaintCounts();
});

/// Complaint list filter state
class ComplaintFilter {
  final String? status;
  final String? categoryId;
  final String? priority;
  final String? search;

  const ComplaintFilter({
    this.status,
    this.categoryId,
    this.priority,
    this.search,
  });

  ComplaintFilter copyWith({
    String? status,
    String? categoryId,
    String? priority,
    String? search,
    bool clearStatus = false,
    bool clearCategory = false,
    bool clearPriority = false,
    bool clearSearch = false,
  }) {
    return ComplaintFilter(
      status: clearStatus ? null : (status ?? this.status),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      priority: clearPriority ? null : (priority ?? this.priority),
      search: clearSearch ? null : (search ?? this.search),
    );
  }

  bool get isEmpty =>
      status == null && categoryId == null && priority == null && search == null;
}

/// Complaint list notifier
class ComplaintListNotifier extends StateNotifier<AsyncValue<List<Complaint>>> {
  final ComplaintRepository _repository;
  ComplaintFilter _filter;
  int _offset;
  static const int _limit = 20;

  ComplaintListNotifier(this._repository)
      : _filter = const ComplaintFilter(),
        _offset = 0,
        super(const AsyncValue.loading()) {
    loadComplaints();
  }

  ComplaintFilter get filter => _filter;

  Future<void> loadComplaints({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      state = const AsyncValue.loading();
    }

    try {
      final complaints = await _repository.getMyComplaints(
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

  Future<void> updateFilter(ComplaintFilter newFilter) async {
    _filter = newFilter;
    _offset = 0;
    await loadComplaints(refresh: true);
  }

  Future<void> clearFilters() async {
    _filter = const ComplaintFilter();
    _offset = 0;
    await loadComplaints(refresh: true);
  }

  bool get hasMore => (state.valueOrNull?.length ?? 0) >= _limit;
}

/// Complaint list provider
final complaintListProvider =
    StateNotifierProvider<ComplaintListNotifier, AsyncValue<List<Complaint>>>((ref) {
  final repository = ref.watch(complaintRepositoryProvider);
  return ComplaintListNotifier(repository);
});

/// Single complaint provider
final complaintDetailProvider =
    FutureProvider.family<Complaint?, String>((ref, complaintId) async {
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.getComplaintById(complaintId);
});

/// Complaint history provider
final complaintHistoryProvider =
    FutureProvider.family<List<ComplaintHistory>, String>((ref, complaintId) async {
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.getComplaintHistory(complaintId);
});

/// Complaint images provider
final complaintImagesProvider =
    FutureProvider.family<List<ComplaintImage>, String>((ref, complaintId) async {
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.getComplaintImages(complaintId);
});

/// Create complaint state
enum CreateComplaintStatus { initial, loading, success, error }

/// Create complaint state class
class CreateComplaintState {
  final CreateComplaintStatus status;
  final Complaint? createdComplaint;
  final String? error;

  const CreateComplaintState({
    this.status = CreateComplaintStatus.initial,
    this.createdComplaint,
    this.error,
  });
}

/// Create complaint notifier
class CreateComplaintNotifier extends StateNotifier<CreateComplaintState> {
  final ComplaintRepository _repository;

  CreateComplaintNotifier(this._repository) : super(const CreateComplaintState());

  Future<bool> createComplaint({
    required String categoryId,
    required String title,
    required String description,
    required String priority,
  }) async {
    state = const CreateComplaintState(status: CreateComplaintStatus.loading);

    try {
      final complaint = await _repository.createComplaint(
        categoryId: categoryId,
        title: title,
        description: description,
        priority: priority,
      );

      state = CreateComplaintState(
        status: CreateComplaintStatus.success,
        createdComplaint: complaint,
      );
      return true;
    } catch (e) {
      state = CreateComplaintState(
        status: CreateComplaintStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() {
    state = const CreateComplaintState();
  }
}

/// Create complaint provider
final createComplaintProvider =
    StateNotifierProvider<CreateComplaintNotifier, CreateComplaintState>((ref) {
  final repository = ref.watch(complaintRepositoryProvider);
  return CreateComplaintNotifier(repository);
});
