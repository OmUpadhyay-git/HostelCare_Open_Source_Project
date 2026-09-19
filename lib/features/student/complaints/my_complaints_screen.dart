import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/complaint_status.dart';
import '../../../providers/complaint_provider.dart';
import '../../../shared/components/components.dart';
import '../../../shared/widgets/widgets.dart';

class MyComplaintsScreen extends ConsumerStatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  ConsumerState<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends ConsumerState<MyComplaintsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(complaintListProvider.notifier);
      if (notifier.hasMore) {
        notifier.loadMore();
      }
    }
  }

  void _showFilterDialog() {
    final currentFilter = ref.read(complaintListProvider.notifier).filter;

    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(
        currentFilter: currentFilter,
        onApply: (filter) {
          ref.read(complaintListProvider.notifier).updateFilter(filter);
          Navigator.pop(context);
        },
        onClear: () {
          ref.read(complaintListProvider.notifier).clearFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaintList = ref.watch(complaintListProvider);
    final currentFilter = ref.watch(complaintListProvider.notifier).filter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search complaints...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(complaintListProvider.notifier).updateFilter(
                                currentFilter.copyWith(clearSearch: true),
                              );
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {}); // Update clear button visibility
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    ref.read(complaintListProvider.notifier).updateFilter(
                          currentFilter.copyWith(search: value),
                        );
                  }
                });
              },
            ),
          ),

          // Active filters
          if (!currentFilter.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
              child: _ActiveFilters(
                filter: currentFilter,
                onRemove: (filter) {
                  ref.read(complaintListProvider.notifier).updateFilter(filter);
                },
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
                    message: currentFilter.isEmpty
                        ? 'You haven\'t raised any complaints yet.'
                        : 'No complaints match your search criteria.',
                    actionLabel: currentFilter.isEmpty ? 'Raise Complaint' : null,
                    onAction: currentFilter.isEmpty
                        ? () => context.push('/student/complaints/new')
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(complaintListProvider.notifier)
                        .loadComplaints(refresh: true);
                  },
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                    itemCount: complaints.length +
                        (ref.read(complaintListProvider.notifier).hasMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index >= complaints.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.base),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final complaint = complaints[index];
                      return ComplaintCard(
                        complaintNumber: complaint.complaintNumber,
                        title: complaint.title,
                        category: complaint.categoryName,
                        priority: complaint.priority,
                        status: complaint.status,
                        createdAt: complaint.createdAt,
                        onTap: () =>
                            context.push('/student/complaints/${complaint.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => const ListSkeletonLoader(itemCount: 5),
              error: (error, _) => ErrorState(
                message: 'Failed to load complaints',
                details: 'Please check your connection and try again.',
                actionLabel: 'Retry',
                onAction: () async {
                  await ref
                      .read(complaintListProvider.notifier)
                      .loadComplaints(refresh: true);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/student/complaints/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final ComplaintFilter currentFilter;
  final ValueChanged<ComplaintFilter> onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _selectedStatus;
  late String? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentFilter.status;
    _selectedPriority = widget.currentFilter.priority;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Complaints',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: widget.onClear,
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),

            // Status filter
            Text(
              'Status',
              style: AppTextStyles.labelLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedStatus == null,
                  onTap: () => setState(() => _selectedStatus = null),
                ),
                ...ComplaintStatus.values.map((status) => _FilterChip(
                      label: status.label,
                      isSelected: _selectedStatus == status.name,
                      color: status.color,
                      onTap: () => setState(() => _selectedStatus = status.name),
                    )),
              ],
            ),
            const SizedBox(height: AppSpacing.base),

            // Priority filter
            Text(
              'Priority',
              style: AppTextStyles.labelLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedPriority == null,
                  onTap: () => setState(() => _selectedPriority = null),
                ),
                ...ComplaintStatus.values.map((_) => const SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Apply button
            AppButton.primary(
              label: 'Apply Filters',
              onPressed: () {
                widget.onApply(ComplaintFilter(
                  status: _selectedStatus,
                  priority: _selectedPriority,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chipColor = color ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? chipColor : colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? chipColor : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  final ComplaintFilter filter;
  final ValueChanged<ComplaintFilter> onRemove;

  const _ActiveFilters({
    required this.filter,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (filter.status != null) {
      chips.add(_RemovableChip(
        label: filter.status!.toUpperCase(),
        onRemove: () => onRemove(filter.copyWith(clearStatus: true)),
      ));
    }

    if (filter.priority != null) {
      chips.add(_RemovableChip(
        label: filter.priority!.toUpperCase(),
        onRemove: () => onRemove(filter.copyWith(clearPriority: true)),
      ));
    }

    if (filter.search != null) {
      chips.add(_RemovableChip(
        label: 'Search: ${filter.search}',
        onRemove: () => onRemove(filter.copyWith(clearSearch: true)),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips,
        ),
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _RemovableChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Chip(
        label: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: colorScheme.primary,
          ),
        ),
        deleteIcon: Icon(
          Icons.close,
          size: 14,
          color: colorScheme.primary,
        ),
        onDeleted: onRemove,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        side: BorderSide.none,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
