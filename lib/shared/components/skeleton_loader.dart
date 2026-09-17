import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(
              alpha: _animation.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class ComplaintCardSkeleton extends StatelessWidget {
  const ComplaintCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(width: 100, height: 12),
              const Spacer(),
              SkeletonLoader(width: 80, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          SkeletonLoader(width: 200, height: 16),
          const SizedBox(height: 12),
          Row(
            children: [
              SkeletonLoader(width: 60, height: 24, borderRadius: 12),
              const SizedBox(width: 8),
              SkeletonLoader(width: 60, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 8),
          SkeletonLoader(width: 80, height: 12),
        ],
      ),
    );
  }
}

class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const ListSkeletonLoader({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const ComplaintCardSkeleton(),
    );
  }
}

class DashboardSkeletonLoader extends StatelessWidget {
  const DashboardSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SkeletonLoader(width: double.infinity, height: 80, borderRadius: 12)),
              const SizedBox(width: 12),
              Expanded(child: SkeletonLoader(width: double.infinity, height: 80, borderRadius: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SkeletonLoader(width: double.infinity, height: 80, borderRadius: 12)),
              const SizedBox(width: 12),
              Expanded(child: SkeletonLoader(width: double.infinity, height: 80, borderRadius: 12)),
            ],
          ),
          const SizedBox(height: 24),
          SkeletonLoader(width: 150, height: 20),
          const SizedBox(height: 16),
          const ListSkeletonLoader(itemCount: 3),
        ],
      ),
    );
  }
}
