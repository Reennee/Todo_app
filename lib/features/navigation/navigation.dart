import 'package:flutter/material.dart';
import 'package:get_it_done/features/navigation/screens/home_screen.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: HomeScreen(title: "Get It done", key: ValueKey("homeScreenKey"),),
      ),
    );
  }
}
