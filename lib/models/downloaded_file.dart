class DownloadedFile {
  final int id;
  final int orderId;
  final String fileName;

  DownloadedFile({
    required this.id,
    required this.orderId,
    required this.fileName,
  });

  factory DownloadedFile.fromJson(Map<String, dynamic> json) {
    return DownloadedFile(
      id: json['id'] as int? ?? 0,
      orderId: json['order_id'] as int? ?? 0,
      fileName:
          json['file_name'] as String? ?? json['fileName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'file_name': fileName,
    };
  }
}
