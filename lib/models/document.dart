class Document {
  final int id;
  final String name;
  final String fileName;
  final String scope;

  Document({
    required this.id,
    required this.name,
    required this.fileName,
    required this.scope,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      scope: json['scope'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fileName': fileName,
      'scope': scope,
    };
  }
}
