import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import 'edit_todo_page.dart'; // ✅ Import EditTodoPage

class TodoDetailPage extends StatefulWidget {
  final Todo todo;

  const TodoDetailPage({super.key, required this.todo});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  late Todo _todo;

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
  }

  Future<void> _toggleStatus() async {
    setState(() {
      _todo.toggleStatus();
    });
    await StorageService.updateTodo(_todo.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _todo.isCompleted
              ? 'Todo ditandai sebagai SELESAI'
              : 'Todo ditandai sebagai BELUM SELESAI',
        ),
        backgroundColor: _todo.isCompleted ? Colors.green : Colors.orange,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // Refresh data dari storage
              final todos = await StorageService.getTodos();
              final updatedTodoData = todos.firstWhere(
                (t) => t['id'] == _todo.id,
                orElse: () => {},
              );

              if (updatedTodoData.isNotEmpty) {
                setState(() {
                  _todo = Todo.fromMap(updatedTodoData);
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: _todo.isCompleted
                  ? Colors.green[50]
                  : Colors
                        .orange[50], // ✅ Colors.green[50] sudah Color? tapi bisa digunakan
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _todo.isCompleted ? Icons.check_circle : Icons.pending,
                      color: _todo.isCompleted ? Colors.green : Colors.orange,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _todo.isCompleted ? 'SELESAI' : 'BELUM SELESAI',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _todo.isCompleted
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _todo.isCompleted
                                ? 'Todo ini telah diselesaikan'
                                : 'Todo ini belum diselesaikan',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _toggleStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _todo.isCompleted
                            ? Colors.orange
                            : Colors.green,
                      ),
                      child: Text(
                        _todo.isCompleted ? 'Tandai Belum' : 'Tandai Selesai',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Todo Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INFORMASI TODO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('ID', '${_todo.id}'),
                    _buildInfoRow('Judul', _todo.title),
                    _buildInfoRow('Deskripsi', _todo.description),
                    _buildInfoRow('Dibuat', _formatDateTime(_todo.createdAt)),
                    _buildInfoRow(
                      'Terakhir Diupdate',
                      _formatDateTime(_todo.updatedAt),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // History/Log
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'RIWAYAT PERUBAHAN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_todo.history.length} aktivitas',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_todo.history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.history, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada riwayat perubahan',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _todo.history.reversed.map((log) {
                          return _buildHistoryItem(log);
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTodoPage(todo: _todo),
                        ),
                      );

                      if (result == true) {
                        // Refresh data jika ada perubahan
                        final todos = await StorageService.getTodos();
                        final updatedTodoData = todos.firstWhere(
                          (t) => t['id'] == _todo.id,
                          orElse: () => {},
                        );

                        if (updatedTodoData.isNotEmpty) {
                          setState(() {
                            _todo = Todo.fromMap(updatedTodoData);
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Todo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus Todo'),
                          content: Text(
                            'Yakin ingin menghapus "${_todo.title}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Tutup dialog
                                Navigator.pop(context); // Kembali ke home
                                StorageService.deleteTodo(_todo.id!);
                              },
                              child: const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> log) {
    final action = log['action'];
    final details = log['details'];
    final timestamp = DateTime.parse(log['timestamp']);

    IconData icon;
    Color color;

    switch (action) {
      case 'UBAH_STATUS':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'EDIT_TITLE':
        icon = Icons.title;
        color = Colors.blue;
        break;
      case 'EDIT_DESCRIPTION':
        icon = Icons.description;
        color = Colors.purple;
        break;
      case 'CREATE':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.history;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromRGBO(238, 238, 238, 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
