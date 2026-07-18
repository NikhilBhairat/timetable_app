import 'package:flutter/material.dart';
import 'standards_screen.dart';
import 'subjects_screen.dart';
import 'time_slots_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Standards'),
            subtitle: const Text('Manage academic standards'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const StandardsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Subjects'),
            subtitle: const Text('Manage subjects'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SubjectsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Time Slots'),
            subtitle: const Text('Manage class time slots'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TimeSlotsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
