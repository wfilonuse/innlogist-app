// lib/models/downloaded_file.dart
class DownloadedFile {
  final int id;
  final int orderId;
  final String fileName;
  bool isPending;
  bool isDeleted;

  DownloadedFile({
    required this.id,
    required this.orderId,
    required this.fileName,
    this.isPending = true,
    this.isDeleted = false,
  });

  factory DownloadedFile.fromJson(Map<String, dynamic> json) {
    return DownloadedFile(
      id: json['id'] as int? ?? 0,
      orderId: json['orderId'] as int? ?? 0,
      fileName: json['fileName'] as String? ?? '',
      isPending: json['isPending'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'fileName': fileName,
      'isPending': isPending,
      'isDeleted': isDeleted,
    };
  }
}
