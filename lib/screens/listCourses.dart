import 'dart:async';

import 'package:e_learningapp/screens/AddCoursesPage.dart';
import 'package:e_learningapp/screens/UpdateCoursesPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CourseList extends StatefulWidget {
  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  late List<DocumentSnapshot> courses = [];
  late StreamSubscription<QuerySnapshot> courseSubscription;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  @override
  void dispose() {
    courseSubscription.cancel();
    super.dispose();
  }

  Future<void> fetchCourses() async {
    try {
      courseSubscription = FirebaseFirestore.instance
          .collection('courses')
          .snapshots()
          .listen((QuerySnapshot courseSnapshot) {
        setState(() {
          courses = courseSnapshot.docs;
        });
      });
    } catch (error) {
      print('Error fetching courses: $error');
    }
  }

 Future<void> _showDeleteConfirmationDialog(String courseId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this course?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
                deleteCourse(courseId);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSuccessMessage() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Successful'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('The course has been deleted successfully.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the success message dialog
              },
            ),
          ],
        );
      },
    );
  }

  void deleteCourse(String courseId) async {
    try {
      await FirebaseFirestore.instance.collection('courses').doc(courseId).delete();
      fetchCourses();
      _showDeleteSuccessMessage();
    } catch (error) {
      print('Error deleting course: $error');
    }
  }

   Future<Image> loadImage(String imagePath) async {
    FirebaseStorage fs = FirebaseStorage.instance;
    try {
      var downloadURL = await fs.ref().child(imagePath).getDownloadURL();
      print('Image URL: $downloadURL');
      return Image.network(downloadURL.toString(), fit: BoxFit.cover);
    } catch (error) {
      print('Error loading image: $error');
      return Image.asset('assets/placeholder_image.png', fit: BoxFit.cover);
    }
  }

  Widget buildCourseList() {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return FutureBuilder<Image>(
          future: loadImage(courses[index]['image_url']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return buildCourseItem(courses[index], snapshot.data!);
            } else if (snapshot.hasError) {
              return buildCourseItem(courses[index], Image.asset('assets/placeholder_image.png', fit: BoxFit.cover));
            } else {
              return buildLoadingIndicator();
            }
          },
        );
      },
    );
  }

 Widget buildCourseItem(DocumentSnapshot course, Widget? courseImage) {
  return Card(
    margin: EdgeInsets.all(8.0),
    child: ListTile(
      leading: Container(
        width: 50.0,
        height: 50.0,
        child: courseImage ?? Container(),
      ),
      title: Text(course['title']),
      subtitle: Text('Price: ${course['price']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: const Color.fromARGB(255, 96, 191, 99)), // Set color to green
            onPressed: () {
              navigateToUpdateCourse(course.id);
            },
            
          ),
          IconButton(
            icon: Icon(Icons.delete, color: const Color.fromARGB(255, 222, 108, 100)), // Set color to red
            onPressed: () {
              _showDeleteConfirmationDialog(course.id);
            },
          ),
        ],
      ),
      onTap: () {
        // Add any additional behavior when tapping the ListTile itself
      },
    ),
  );
}


  Widget buildLoadingIndicator() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course List'),
        backgroundColor: Color.fromARGB(255, 255, 208, 126),
      ),
      body: buildCourseList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToAddCourses(); // Navigate to the AddCoursesPage
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 251, 176, 47),
      ),
    );
  }

  void navigateToUpdateCourse(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateCourses(courseId: courseId),
      ),
    );
  }

  void navigateToAddCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCourses(),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CourseList(),
  ));
}
