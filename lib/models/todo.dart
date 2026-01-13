class Todo {
  int? id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime updatedAt; // ✅ Tambah field updatedAt
  List<Map<String, dynamic>> history; // ✅ Tambah riwayat perubahan

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? history,
  }) : updatedAt = updatedAt ?? createdAt,
       history = history ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'history': history, // ✅ Simpan history
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.parse(map['createdAt']),
      history: map['history'] != null
          ? List<Map<String, dynamic>>.from(map['history'])
          : [],
    );
  }

  // ✅ Method untuk tambah riwayat
  void addHistory(String action, String details) {
    history.add({
      'action': action,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    });
    updatedAt = DateTime.now();
  }

  // ✅ Method untuk toggle status dengan riwayat
  void toggleStatus() {
    final oldStatus = isCompleted ? 'Selesai' : 'Belum Selesai';
    isCompleted = !isCompleted;
    final newStatus = isCompleted ? 'Selesai' : 'Belum Selesai';

    addHistory(
      'UBAH_STATUS',
      'Status berubah dari "$oldStatus" menjadi "$newStatus"',
    );
  }

  // ✅ Method untuk update dengan riwayat
  void updateTodo(String newTitle, String newDescription) {
    final oldTitle = title;
    final oldDescription = description;

    if (oldTitle != newTitle) {
      addHistory(
        'EDIT_TITLE',
        'Judul berubah dari "$oldTitle" menjadi "$newTitle"',
      );
    }

    if (oldDescription != newDescription) {
      addHistory('EDIT_DESCRIPTION', 'Deskripsi diperbarui');
    }

    title = newTitle;
    description = newDescription;
    updatedAt = DateTime.now();
  }
}
