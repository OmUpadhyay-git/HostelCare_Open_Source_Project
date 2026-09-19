class ComplaintImage {
  final String id;
  final String complaintId;
  final String storagePath;
  final String uploadedBy;
  final String imageType;
  final DateTime createdAt;

  const ComplaintImage({
    required this.id,
    required this.complaintId,
    required this.storagePath,
    required this.uploadedBy,
    required this.imageType,
    required this.createdAt,
  });

  factory ComplaintImage.fromJson(Map<String, dynamic> json) {
    return ComplaintImage(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      storagePath: json['storage_path'] as String,
      uploadedBy: json['uploaded_by'] as String,
      imageType: json['image_type'] as String? ?? 'complaint',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_id': complaintId,
      'storage_path': storagePath,
      'uploaded_by': uploadedBy,
      'image_type': imageType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
