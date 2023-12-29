import 'package:e_learningapp/screens/CoursesPage.dart';
import 'package:e_learningapp/screens/HomePage.dart';
import 'package:e_learningapp/screens/UpdateCoursesPage.dart';
import 'package:e_learningapp/screens/listCourses.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
       apiKey: "AIzaSyAjU9YdXHk3_J5HsVsdf8-dO1_JsQgzsKU",
  projectId: "e-learningapp-6b26e",
  messagingSenderId: "553039356072",
  appId: "1:553039356072:web:210107cb3fee24bb5aa29d",
        storageBucket: "e-learningapp-6b26e.appspot.com",

         )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  HomePage(), // Use the AddCourses widget as the home
    );
  }
}
