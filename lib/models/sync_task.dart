enum SyncTaskType {
  documentUpload,
  documentDelete,
  reportAdd,
  reportUpdate,
  reportDelete,
  expenseAdd,
  expenseDelete,
  orderAdd,
  orderUpdate,
  orderDelete,
  progressUpdate,
  progressDelete,
}

class SyncTask {
  final int? id;
  final SyncTaskType type;
  final Map<String, dynamic> data;

  SyncTask({this.id, required this.type, required this.data});

  factory SyncTask.fromJson(Map<String, dynamic> json) {
    return SyncTask(
      id: json['id'] as int?,
      type: SyncTaskType.values[json['type'] as int],
      data: Map<String, dynamic>.from(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'data': data,
    };
  }
}
