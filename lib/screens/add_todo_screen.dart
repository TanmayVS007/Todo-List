import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoScreen extends StatefulWidget {
  final Map? todo;
  const AddTodoScreen({super.key, this.todo});
  static const routeName = '/add_todo_screeen';

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descController.text = description;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? "Edit Todo" : "Add Todo"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  hintText: "Description",
                ),
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 8,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  submitData();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.blue[600])),
                child: Text(
                  isEdit ? "Update" : "Submit",
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ));
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      if (kDebugMode) {
        print("Can not call edit function without data");
      }
      return;
    }
    final id = todo['_id'];

    final title = titleController.text;
    final description = descController.text;
    final task = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(task), headers: {'Content-Type': 'application/json'});

    if (kDebugMode) {
      if (response.statusCode == 200) {
        successMessage();
      } else {
        failureMessage();
      }
    }
  }

  Future<void> submitData() async {
    // Got the data from the form
    final title = titleController.text;
    final desc = descController.text;
    final task = {"title": title, "description": desc, "is_completed": false};

    // Submit data to the server
    const url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(task), headers: {'Content-Type': 'application/json'});

    // show message of success or fail based on status
    if (kDebugMode) {
      if (response.statusCode == 201) {
        successMessage();
      } else {
        failureMessage();
      }
    }
  }

  void successMessage() {
    const snackBar = SnackBar(content: Text("Successfully Created"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void failureMessage() {
    const snackBar = SnackBar(content: Text("Error"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
