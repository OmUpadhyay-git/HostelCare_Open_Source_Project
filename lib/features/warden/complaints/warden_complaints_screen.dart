import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/complaint_status.dart';
import '../../../core/constants/complaint_priority.dart';
import '../../../providers/warden_provider.dart';
import '../../../shared/components/components.dart';
import '../../../shared/widgets/widgets.dart';

class WardenComplaintsScreen extends ConsumerStatefulWidget {
  const WardenComplaintsScreen({super.key});

  @override
  ConsumerState<WardenComplaintsScreen> createState() => _WardenComplaintsScreenState();
}

class _WardenComplaintsScreenState extends ConsumerState<WardenComplaintsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(wardenComplaintListProvider.notifier);
      if (notifier.hasMore) {
        notifier.loadMore();
      }
    }
  }

  void _onSearchChanged(String value) {
    final notifier = ref.read(wardenComplaintListProvider.notifier);
    final currentFilter = notifier.filter;
    notifier.updateFilter(currentFilter.copyWith(
      search: value.isEmpty ? null : value,
      clearSearch: value.isEmpty,
    ));
  }

  void _onStatusFilter(String? status) {
    final notifier = ref.read(wardenComplaintListProvider.notifier);
    final currentFilter = notifier.filter;
    notifier.updateFilter(currentFilter.copyWith(
      status: status,
      clearStatus: status == null,
    ));
  }

  void _onPriorityFilter(String? priority) {
    final notifier = ref.read(wardenComplaintListProvider.notifier);
    final currentFilter = notifier.filter;
    notifier.updateFilter(currentFilter.copyWith(
      priority: priority,
      clearPriority: priority == null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final complaintList = ref.watch(wardenComplaintListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
      ),
      body: Column(
        children: [
          // Search and filters
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
            child: Column(
              children: [
                AppTextField(
                  controller: _searchController,
                  hint: 'Search complaints...',
                  prefixIcon: Icons.search,
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: AppSpacing.sm),
                _FilterRow(
                  onStatusFilter: _onStatusFilter,
                  onPriorityFilter: _onPriorityFilter,
                ),
              ],
            ),
          ),

          // Complaint list
          Expanded(
            child: complaintList.when(
              data: (complaints) {
                if (complaints.isEmpty) {
                  return EmptyState(
                    icon: Icons.report_outlined,
                    title: 'No complaints found',
                    message: 'No complaints match your current filters.',
                    actionLabel: 'Clear Filters',
                    onAction: () {
                      ref.read(wardenComplaintListProvider.notifier).clearFilters();
                      _searchController.clear();
                    },
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingHorizontal,
                  ),
                  itemCount: complaints.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == complaints.length) {
                      // Load more indicator
                      final notifier = ref.read(wardenComplaintListProvider.notifier);
                      if (notifier.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final complaint = complaints[index];
                    return ComplaintCard(
                      complaintNumber: complaint.complaintNumber,
                      title: complaint.title,
                      category: complaint.categoryName,
                      priority: complaint.priority,
                      status: complaint.status,
                      createdAt: complaint.createdAt,
                      onTap: () => context.push('/warden/complaints/${complaint.id}'),
                    );
                  },
                );
              },
              loading: () => const ListSkeletonLoader(itemCount: 5),
              error: (error, _) => ErrorState(
                message: 'Failed to load complaints',
                actionLabel: 'Retry',
                onAction: () {
                  ref.read(wardenComplaintListProvider.notifier).loadComplaints(refresh: true);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final ValueChanged<String?> onStatusFilter;
  final ValueChanged<String?> onPriorityFilter;

  const _FilterRow({
    required this.onStatusFilter,
    required this.onPriorityFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: null,
            decoration: const InputDecoration(
              hintText: 'Status',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Statuses')),
              ...ComplaintStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status.name,
                  child: Text(status.label),
                );
              }),
            ],
            onChanged: onStatusFilter,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: null,
            decoration: const InputDecoration(
              hintText: 'Priority',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Priorities')),
              ...ComplaintPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority.name,
                  child: Text(priority.label),
                );
              }),
            ],
            onChanged: onPriorityFilter,
          ),
        ),
      ],
    );
  }
}
