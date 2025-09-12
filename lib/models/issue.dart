class CivicIssue {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final String issueType;
  final DateTime reportedAt;
  final String reportedBy;
  final String status; // pending, assigned, in_progress, resolved
  final String? assignedTo;
  final String? assignedDepartment;
  final String? assignedWorker;
  final int priority; // 1-5 (5 is highest)
  final String? aiAnalysis;
  final double? aiConfidence;

  CivicIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.issueType,
    required this.reportedAt,
    required this.reportedBy,
    this.status = 'pending',
    this.assignedTo,
    this.assignedDepartment,
    this.assignedWorker,
    this.priority = 1,
    this.aiAnalysis,
    this.aiConfidence,
  });

  // Add fromMap and toMap methods for Firestore
}