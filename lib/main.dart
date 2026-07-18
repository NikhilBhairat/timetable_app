import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/constants.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => StandardsProvider()),
        ChangeNotifierProvider(create: (_) => SubjectsProvider()),
        ChangeNotifierProvider(create: (_) => TimeSlotsProvider()),
      ],
      child: MaterialApp(
        title: 'Timetable Manager',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
