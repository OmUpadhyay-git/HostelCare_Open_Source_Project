import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/complaint_priority.dart';
import '../../../providers/complaint_provider.dart';
import '../../../shared/components/components.dart';
import '../../../shared/widgets/widgets.dart';

class CreateComplaintScreen extends ConsumerStatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  ConsumerState<CreateComplaintScreen> createState() =>
      _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends ConsumerState<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  ComplaintPriority _selectedPriority = ComplaintPriority.medium;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a complaint title';
    }
    if (value.trim().length < 5) {
      return 'Title must be at least 5 characters';
    }
    if (value.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe your complaint';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (value.trim().length > 1000) {
      return 'Description must be less than 1000 characters';
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a complaint category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(createComplaintProvider.notifier).createComplaint(
          categoryId: _selectedCategoryId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority.name,
        );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      final state = ref.read(createComplaintProvider);
      final complaint = state.createdComplaint;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complaint ${complaint?.complaintNumber ?? ''} submitted successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to complaint detail or back to list
      if (complaint != null) {
        context.go('/student/complaints/${complaint.id}');
      } else {
        context.go('/student/complaints');
      }
    } else if (mounted) {
      final state = ref.read(createComplaintProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error ?? 'Failed to submit complaint'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    // Listen for success
    ref.listen<CreateComplaintState>(createComplaintProvider, (previous, next) {
      if (next.status == CreateComplaintStatus.success) {
        // Navigation handled in _handleSubmit
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raise Complaint'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category selection
              Text(
                'Category',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: InputDecoration(
                    hintText: 'Select a category',
                    errorText: _validateCategory(_selectedCategoryId),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                      // Set default priority from category
                      if (value != null) {
                        final category = categories.firstWhere(
                          (c) => c.id == value,
                        );
                        _selectedPriority = parseComplaintPriority(
                          category.defaultPriority,
                        );
                      }
                    });
                  },
                ),
                loading: () => const SkeletonLoader(
                  width: double.infinity,
                  height: 56,
                ),
                error: (error, _) => const ErrorState(
                  message: 'Failed to load categories',
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Title
              TextFormField(
                controller: _titleController,
                validator: _validateTitle,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Brief description of the issue',
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Description
              TextFormField(
                controller: _descriptionController,
                validator: _validateDescription,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Provide details about the problem...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Priority selection
              Text(
                'Priority',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: ComplaintPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          priority.icon,
                          size: 14,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : priority.color,
                        ),
                        const SizedBox(width: 4),
                        Text(priority.label),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: priority.color,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedPriority = priority);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit button
              AppButton.primary(
                label: 'Submit Complaint',
                icon: Icons.send,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
