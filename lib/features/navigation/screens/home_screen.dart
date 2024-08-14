import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it_done/features/navigation/pages/plan_page.dart';
import 'package:get_it_done/features/navigation/pages/tasks_page.dart';
import 'package:get_it_done/utils/app_settings.dart';
import 'package:provider/provider.dart';

import '../../../providers/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final pages = [const Plan(), const TasksPage()];

  //creating
  void _showAddTaskBottomSheet(BuildContext context) {
    String title = '';
    String imageUrl = '';
    final authProvider = Provider.of<AuthStateProvider>(context, listen: false);

    showModalBottomSheet(
      backgroundColor: AppSettings.primaryColor,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Task',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'imageUrl',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      imageUrl = value;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (title.isNotEmpty) {
                        // Add task to Firebase
                        await FirebaseFirestore.instance
                            .collection('Tasks')
                            .add({
                          'name': title,
                          'imageUrl': imageUrl == ''
                              ? 'https://t3.ftcdn.net/jpg/02/48/42/64/240_F_248426448_NVKLywWqArG2ADUxDq6QprtIzsF82dMF.jpg'
                              : imageUrl,
                          'date': DateTime.now(),
                          'uid': authProvider.currentUser?.uid,
                          'state': 'pending'
                        });

                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter title and details.'),
                          ),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.primaryColor,
      appBar: AppBar(
        backgroundColor: AppSettings.secondaryColor,
        title: Text(widget.title),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: SizedBox(
          width: AppSettings.screenWidth(context),
          height: 100,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            useLegacyColorScheme: false,
            backgroundColor: Colors.black87,
            selectedItemColor: Colors.amber,
            unselectedItemColor: Colors.grey,
            iconSize: 30,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outline_rounded),
                label: 'Plan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline_rounded),
                label: 'Tasks',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
