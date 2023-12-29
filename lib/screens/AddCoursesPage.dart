import 'dart:html' as html;
import 'dart:html';
import 'package:e_learningapp/screens/listCourses.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AddCourses extends StatefulWidget {
  @override
  _AddCoursesState createState() => _AddCoursesState();
}

class _AddCoursesState extends State<AddCourses> {
  bool _isButtonVisible = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _priceController = TextEditingController(); // Fixed here
  String imgUrl = '';
  html.File? file;
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 255, 208, 126),

      title: Text('Add Courses'),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              padding: EdgeInsets.zero, // Remove padding at the top
              children: <Widget>[
                Container(
                  width: 500,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Title',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Price',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Price is required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid number for the price';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              selectImage();
                            },
                            child: Container(
                              height: 300,
                              width: 400,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: _isButtonVisible
                                  ? Center(child: Text('Add Image'))
                                  : imgUrl.isNotEmpty
                                      ? Image.network(
                                          imgUrl,
                                          height: 200,
                                          width: 400,
                                          fit: BoxFit.cover,
                                        )
                                      : Center(child: Text('Select Image')),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                uploadToFirebase();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 144, 59, 111),
                              textStyle: TextStyle(color: Colors.white),
                            ),
                            child: Text(
                              'Add Courses',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Future<void> selectImage() async {
    FileUploadInputElement input = FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((event) async {
      final file = input.files?.first;
      final reader = FileReader();
      reader.readAsDataUrl(file!);
      reader.onLoadEnd.listen((event) async {
        if (file != null) {
          setState(() {
            imgUrl = reader.result as String;
            this.file = file;
            _isButtonVisible = false;
          });
        }
      });
    });
  }

  Future<void> uploadToFirebase() async {
    if (file != null && _titleController.text.isNotEmpty) {
      try {
        FirebaseStorage fs = FirebaseStorage.instance;
        int date = DateTime.now().millisecondsSinceEpoch;
        var snapshot = await fs.ref().child('courses/$date').putBlob(file!);
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Check if the title is a string
        if (_titleController.text is String) {
          // Check if the price is a number (integer or floating-point)
          double? price = double.tryParse(_priceController.text);
          if (price != null) {
            // Save data to Firestore or update existing data
            saveDataToFirebase(downloadUrl, price);
            // Show the confirmation dialog
            showConfirmationDialog();
          } else {
            // Handle error if the price is not a valid number
            print("Error: Price is not a valid number");
          }
        } else {
          // Handle error if the title is not a string
          print("Error: Title is not a string");
        }
      } catch (error) {
        // Handle errors
        print("Error uploading: $error");
      }
    }
  }

  void saveDataToFirebase(String downloadUrl, double price) {
    try {
      // Assuming you have a 'courses' collection in Firestore
      FirebaseFirestore.instance.collection('courses').add({
        'title': _titleController.text, // Assuming _titleController is accessible
        'image_url': downloadUrl,
        'price': price, // Use the provided 'price' parameter directly
      }).then((value) {
        // Handle success, if needed
        print('Data saved to Firestore successfully!');
      }).catchError((error) {
        // Handle error, if needed
        print('Error saving data to Firestore: $error');
      });
    } catch (error) {
      // Handle unexpected errors
      print('Unexpected error: $error');
    }
  }

void showConfirmationDialog() async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Courses added successfully!'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              // Navigate to the CourseList page after a successful add
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CourseList()),
              );
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

}
