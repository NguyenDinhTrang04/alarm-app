import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      tasksCollection.add({'title': _controller.text, 'completed': false});
      _controller.clear();
    }
  }

  void _editTask(String id, String currentTitle) {
    TextEditingController editController =
        TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa nhiệm vụ'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: 'Nhập nhiệm vụ mới'),
        ),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Lưu'),
            onPressed: () {
              if (editController.text.isNotEmpty) {
                tasksCollection.doc(id).update({'title': editController.text});
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _deleteTask(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhiệm vụ'),
        content: const Text('Bạn có chắc chắn muốn xóa nhiệm vụ này?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Xóa'),
            onPressed: () {
              tasksCollection.doc(id).delete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhiệm vụ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Nhập nhiệm vụ mới'),
                    onSubmitted: (value) {
                      _addTask(); // Thêm nhiệm vụ khi nhấn Enter
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: tasksCollection.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(doc['title']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editTask(doc.id, doc['title']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteTask(doc.id),
                            ),
                            Checkbox(
                              value: doc['completed'],
                              onChanged: (value) {
                                tasksCollection
                                    .doc(doc.id)
                                    .update({'completed': value});
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
