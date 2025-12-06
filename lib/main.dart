import 'package:flutter/material.dart';
import 'package:match_music/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Song Link',
      theme: ThemeData.light(),
      home: HomePage(),
    );
  }
}