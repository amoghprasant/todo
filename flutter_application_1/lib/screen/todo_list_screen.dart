import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/db_helper.dart'; // Import DbHelper
import 'package:flutter_application_1/model/todo_model.dart';
import 'package:flutter_application_1/repository/todo_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late TodoRepository _todoRepository;
  List<Todo> _todos = [];

  // Initialize the FlutterLocalNotificationsPlugin object
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initDatabaseAndFetchTodos(); // Initialize database and fetch todos
  }

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones(); // Timezone initialization

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Initialize the database and fetch todos
  Future<void> _initDatabaseAndFetchTodos() async {
    Database db = await DBHelper.dbHelper.database;
    // Get the database instance
    _todoRepository = TodoRepository(
        database: db); // Initialize TodoRepository with the database
    _fetchTodos(); // Fetch todos from the repository
  }

  // Fetch todos from the database
  Future<void> _fetchTodos() async {
    try {
      List<Todo> todos = await _todoRepository.getAll();
      setState(() {
        _todos = todos;
      });
    } catch (e) {
      print("Error fetching todos: $e");
    }
  }

  // Show dialog for adding or editing a Todo
  Future<void> _showTodoDialog({Todo? todo}) async {
    final TextEditingController nameController =
        TextEditingController(text: todo?.name ?? '');
    final TextEditingController descriptionController =
        TextEditingController(text: todo?.description ?? '');

    DateTime? selectedTime = todo?.alarmTime;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(todo == null ? 'Add Todo' : 'Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Todo Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Todo Description'),
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (time != null) {
                      selectedTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        time.hour,
                        time.minute,
                      );
                    }
                  }
                },
                child: Text('Pick Date & Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    descriptionController.text.isEmpty) {
                  print("Fields cannot be empty");
                  return;
                }

                Todo newTodo = Todo(
                  id: todo?.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  alarmTime: selectedTime,
                );

                if (todo == null) {
                  await _todoRepository.create(newTodo);
                } else {
                  await _todoRepository.update(newTodo);
                }

                if (selectedTime != null) {
                  _scheduleAlarm(newTodo);
                }

                Navigator.pop(context);
                _fetchTodos();
              },
              child: Text(todo == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  // Add a new Todo
  void _addTodo() {
    _showTodoDialog();
  }

  // Edit an existing Todo
  void _editTodo(Todo todo) {
    _showTodoDialog(todo: todo);
  }

  // Delete a Todo
  void _deleteTodo(int id) async {
    await _todoRepository.delete(id);
    _fetchTodos();
  }

  // Schedule alarm notification for a Todo
  void _scheduleAlarm(Todo todo) async {
    if (todo.alarmTime != null) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        todo.id ??
            DateTime.now()
                .millisecondsSinceEpoch, // Use current timestamp if ID is null
        'Todo Reminder',
        'It\'s time for: ${todo.name}',
        tz.TZDateTime.from(todo.alarmTime!, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _todos.isEmpty
            ? Center(
                child: Text('No Todos available. Add some!'),
              )
            : ListView.separated(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  return ListTile(
                    title: Text(todo.name),
                    subtitle: Text(todo.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editTodo(todo),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteTodo(todo.id!),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }
}
