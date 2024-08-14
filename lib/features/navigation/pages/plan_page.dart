import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it_done/utils/app_settings.dart';
import 'package:provider/provider.dart';

import '../../../providers/provider.dart';

class Plan extends StatefulWidget {
  const Plan({Key? key}) : super(key: key);

  @override
  PlanState createState() => PlanState();
}

class PlanState extends State<Plan> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _taskStream;

  @override
  void initState() {
    super.initState();
    _taskStream =
        _db.collection('Tasks').orderBy('date', descending: true).snapshots();
  }

  //updating
  Future<void> _editTask(String taskId, String currentName) async {
    String newName = currentName;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          backgroundColor: AppSettings.primaryColor,
          title: Text(
            'Edit Task',
            style: TextStyle(color: AppSettings.secondaryColor),
          ),
          content: TextField(
            decoration: InputDecoration(
                labelText: 'Name',
                filled: true,
                fillColor: Colors.grey.withOpacity(.5)),
            onChanged: (value) => newName = value,
            controller: TextEditingController(text: currentName),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newName.isNotEmpty) {
                  await _db.collection('Tasks').doc(taskId).update({
                    'name': newName,
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a name.'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  //deleting
  Future<void> _deleteTask(String taskId) async {
    await _db.collection('Tasks').doc(taskId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthStateProvider>(context);
    return Center(
      //reading
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _taskStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final tasks = snapshot.data!.docs
              .where(
                  (doc) => doc.data()['uid'] == authProvider.currentUser!.uid)
              .map((doc) => doc.data())
              .toList();

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                        color: Colors.grey,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  width: AppSettings.screenWidth(context),
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: AppSettings.screenHeight(context),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                "${task["imageUrl"]}",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: task["state"] == "pending"
                                              ? Colors.amberAccent
                                              : Colors.green,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(0),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 3.0,
                                            ),
                                            child: Text(
                                              "${task["name"]}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        await _editTask(
                                          snapshot.data!.docs[index].id,
                                          task["name"],
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    IconButton(
                                      onPressed: () async {
                                        await _deleteTask(
                                            snapshot.data!.docs[index].id);
                                      },
                                      icon: const Icon(
                                        Icons.delete_forever,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
