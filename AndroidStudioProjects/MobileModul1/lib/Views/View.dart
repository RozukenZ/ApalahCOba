import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/Controllers.dart';

class TodoScreen extends StatelessWidget
{
  final TodoController todoController = Get.put(TodoController());
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Enter a todo',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      todoController.addTodo(textController.text);
                      textController.clear();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
                  () => ListView.builder(
                itemCount: todoController.todos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(todoController.todos[index].text),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => todoController.removeTodo(index),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}