import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';

class EditTodoPage extends StatefulWidget {
  final Todo todo;

  const EditTodoPage({super.key, required this.todo});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateTodo() async {
    if (_formKey.currentState!.validate()) {
      // Buat todo baru dengan data yang diupdate
      final updatedTodo = Todo(
        id: widget.todo.id,
        title: _titleController.text,
        description: _descriptionController.text,
        isCompleted: widget.todo.isCompleted,
        createdAt: widget.todo.createdAt,
        updatedAt: DateTime.now(),
        history: List.from(widget.todo.history),
      );

      // Tambah history jika ada perubahan
      if (widget.todo.title != _titleController.text) {
        updatedTodo.addHistory(
          'EDIT_TITLE',
          'Judul berubah dari "${widget.todo.title}" menjadi "${_titleController.text}"',
        );
      }

      if (widget.todo.description != _descriptionController.text) {
        updatedTodo.addHistory('EDIT_DESCRIPTION', 'Deskripsi diperbarui');
      }

      // Simpan ke storage
      await StorageService.updateTodo(updatedTodo.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todo berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateTodo,
            tooltip: 'Simpan Perubahan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700], size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'Informasi Todo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${widget.todo.id}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Dibuat: ${widget.todo.createdAt.toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Status: ${widget.todo.isCompleted ? "Selesai ✓" : "Belum Selesai"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.todo.isCompleted
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.todo.history.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Riwayat: ${widget.todo.history.length} perubahan',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Todo',
                  hintText: 'Masukkan judul todo baru',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Masukkan deskripsi todo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updateTodo,
                  icon: const Icon(Icons.update),
                  label: const Text('Update Todo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
