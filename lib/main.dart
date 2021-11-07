import 'package:flutter/material.dart';
import 'package:todo_app/services/db_service.dart';

import 'models/todo_item_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TodoItem> todos = [];

  String description = '';
  final _formKey = GlobalKey<FormState>();

  final DbService _dbService = DbService();

  getAllTodo() async {
    final result = await _dbService.getAllTodo();

    todos.clear();

    todos.addAll(result);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _dbService.getAllTodo().then((value) {
      todos.addAll(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (ctx, index) {
                var todo = todos[index];
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: Colors.pink,
                  )),
                  child: ListTile(
                    onLongPress: () async {
                      await _dbService.deleteTodo(todo.id!);
                      await getAllTodo();
                    },
                    leading: Text("${todo.id}"),
                    title: Text(todo.description),
                    trailing: Switch(
                      value: todo.isCompleted,
                      onChanged: (bool value) async {
                        todo.isCompleted = value;

                        await _dbService.updateTodo(todo.id!, todo);
                        await getAllTodo();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      onSaved: (value) {
                        description = value!;
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        _formKey.currentState!.save();
                        setState(() {});
                        await _dbService
                            .createTodo(TodoItem(description: description));
                        description = '';
                        _formKey.currentState!.reset();
                        await getAllTodo();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
