import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import 'add_todo_page.dart';
import 'edit_todo_page.dart';
import 'todo_detail_page.dart'; // ✅ Halaman baru untuk detail

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todos = [];
  bool _isLoading = true;
  int _completedCount = 0;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });

    final todosData = await StorageService.getTodos();
    _todos = todosData.map((data) => Todo.fromMap(data)).toList();

    // ✅ Hitung status
    _updateCounters();

    setState(() {
      _isLoading = false;
    });
  }

  // ✅ Hitung jumlah todo selesai/belum
  void _updateCounters() {
    _completedCount = _todos.where((todo) => todo.isCompleted).length;
    _pendingCount = _todos.length - _completedCount;
  }

  Future<void> _toggleTodoStatus(Todo todo) async {
    todo.toggleStatus(); // ✅ Gunakan method toggle dengan history
    await StorageService.updateTodo(todo.toMap());
    await _loadTodos();

    // ✅ Show notification
    _showStatusNotification(todo);
  }

  // ✅ Tampilkan notifikasi status
  void _showStatusNotification(Todo todo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              todo.isCompleted ? Icons.check_circle : Icons.pending,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              todo.isCompleted
                  ? '"${todo.title}" telah diselesaikan! ✓'
                  : '"${todo.title}" ditandai belum selesai',
            ),
          ],
        ),
        backgroundColor: todo.isCompleted ? Colors.green : Colors.orange,
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: Colors.white,
          onPressed: () {
            // Undo toggle status
            todo.toggleStatus();
            StorageService.updateTodo(todo.toMap());
            _loadTodos();
          },
        ),
      ),
    );
  }

  Future<void> _deleteTodo(int id) async {
    // ✅ Simpan info todo sebelum dihapus untuk notifikasi
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    final todo = _todos[todoIndex];

    await StorageService.deleteTodo(id);
    await _loadTodos();

    // ✅ Tampilkan notifikasi dengan undo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${todo.title}" telah dihapus'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: Colors.white,
          onPressed: () async {
            // Undo delete - tambah kembali
            await StorageService.addTodo(todo.toMap());
            await _loadTodos();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('"${todo.title}" telah dikembalikan')),
            );
          },
        ),
      ),
    );
  }

  Future<void> _clearAllData() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yakin ingin menghapus semua todo?'),
            SizedBox(height: 8),
            Text(
              '📊 Statistik saat ini:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Total: ${_todos.length} todo'),
            Text('• Selesai: $_completedCount'),
            Text('• Belum: $_pendingCount'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAllData();
      await _loadTodos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua data berhasil dihapus'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editTodo(Todo todo) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTodoPage(todo: todo)),
    );

    if (result == true) {
      await _loadTodos();
    }
  }

  // ✅ Navigasi ke halaman detail
  void _viewTodoDetail(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoDetailPage(todo: todo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List - Tracking Status'),
        actions: [
          // ✅ Tampilkan statistik di AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_completedCount/${_todos.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodos,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearAllData,
            tooltip: 'Clear All Data',
          ),
        ],
      ),

      // ✅ Statistik di atas list
      body: Column(
        children: [
          // Statistik Card
          if (!_isLoading && _todos.isNotEmpty)
            Card(
              margin: EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      icon: Icons.list,
                      label: 'Total',
                      value: _todos.length.toString(),
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      icon: Icons.check_circle,
                      label: 'Selesai',
                      value: _completedCount.toString(),
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      icon: Icons.pending,
                      label: 'Belum',
                      value: _pendingCount.toString(),
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      icon: Icons.update,
                      label: 'Terakhir Update',
                      value: _todos.isNotEmpty
                          ? _todos
                                .map((t) => t.updatedAt)
                                .reduce((a, b) => a.isAfter(b) ? a : b)
                                .toString()
                                .split(' ')[0]
                          : '-',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ),

          // Todo List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _todos.isEmpty
                ? _buildEmptyState()
                : _buildTodoList(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
          await _loadTodos();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Todo'),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list, size: 80, color: Colors.grey.withOpacity(0.5)),
          SizedBox(height: 16),
          Text(
            'Belum ada todo',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Tekan "Tambah Todo" untuk memulai',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTodoPage()),
              );
              await _loadTodos();
            },
            icon: Icon(Icons.add),
            label: Text('Buat Todo Pertama'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return _buildTodoItem(todo);
      },
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: todo.isCompleted ? 1 : 2,
      color: todo.isCompleted ? Colors.grey[50] : Colors.white,
      child: ListTile(
        leading: _buildStatusIndicator(todo),
        title: Row(
          children: [
            Expanded(
              child: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  color: todo.isCompleted ? Colors.grey : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            if (todo.history.isNotEmpty)
              Icon(Icons.history, size: 16, color: Colors.blue),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            _buildTodoMeta(todo),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.info, color: Colors.blue),
              onPressed: () => _viewTodoDetail(todo),
              tooltip: 'Lihat Detail & Riwayat',
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _editTodo(todo),
              tooltip: 'Edit todo',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTodo(todo.id!),
              tooltip: 'Hapus todo',
            ),
          ],
        ),
        onTap: () => _viewTodoDetail(todo),
        onLongPress: () => _toggleTodoStatus(todo),
      ),
    );
  }

  Widget _buildStatusIndicator(Todo todo) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: todo.isCompleted
              ? Colors.green.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
          child: Icon(
            todo.isCompleted ? Icons.check : Icons.access_time,
            color: todo.isCompleted ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        if (todo.history.isNotEmpty)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${todo.history.length}',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTodoMeta(Todo todo) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 12, color: Colors.grey),
        SizedBox(width: 4),
        Text(
          'Dibuat: ${todo.createdAt.toString().split(' ')[0]}',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        SizedBox(width: 12),
        Icon(Icons.update, size: 12, color: Colors.grey),
        SizedBox(width: 4),
        Text(
          'Update: ${todo.updatedAt.toString().split(' ')[0]}',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: todo.isCompleted ? Colors.green[100] : Colors.orange[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            todo.isCompleted ? 'SELESAI' : 'BELUM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: todo.isCompleted ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }
}
