import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  final _imagePicker = ImagePicker();

  String? _selectedCategoryId;
  ComplaintPriority _selectedPriority = ComplaintPriority.medium;
  bool _isSubmitting = false;
  final List<File> _selectedImages = [];

  static const int _maxImages = 5;
  static const int _maxFileSizeMB = 10;
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

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

  bool _validateImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only JPG, PNG, and WebP images are allowed'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }

    final sizeInBytes = file.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    if (sizeInMB > _maxFileSizeMB) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image must be smaller than $_maxFileSizeMB MB'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _pickImages(ImageSource source) async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxImages images allowed'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (_validateImageFile(file)) {
          setState(() {
            _selectedImages.add(file);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImages(String complaintId) async {
    if (_selectedImages.isEmpty) return;

    final repository = ref.read(complaintRepositoryProvider);
    for (final image in _selectedImages) {
      try {
        await repository.uploadComplaintImage(
          complaintId: complaintId,
          filePath: image.path,
          imageType: 'complaint',
        );
      } catch (e) {
        // Log error but don't block complaint submission
        debugPrint('Failed to upload image: $e');
      }
    }
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

    if (success && mounted) {
      final state = ref.read(createComplaintProvider);
      final complaint = state.createdComplaint;

      // Upload images if complaint was created successfully
      if (complaint != null && _selectedImages.isNotEmpty) {
        await _uploadImages(complaint.id);
      }

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint ${complaint?.complaintNumber ?? ''} submitted successfully'),
            backgroundColor: AppColors.success,
          ),
        );

        if (complaint != null) {
          context.go('/student/complaints/${complaint.id}');
        } else {
          context.go('/student/complaints');
        }
      }
    } else if (mounted) {
      setState(() => _isSubmitting = false);
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
              const SizedBox(height: AppSpacing.base),

              // Photos section
              Text(
                'Photos (optional)',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add up to $_maxImages images to help explain the issue',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Image grid
              if (_selectedImages.isNotEmpty) ...[
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImages[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // Add photo button
              if (_selectedImages.length < _maxImages)
                AppButton.outlined(
                  label: 'Add Photo',
                  icon: Icons.add_a_photo,
                  onPressed: _isSubmitting ? null : _showImageSourceDialog,
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
