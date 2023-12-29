import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UpdateCourses extends StatefulWidget {
  final String courseId;

  UpdateCourses({required this.courseId});

  @override
  _UpdateCoursesState createState() => _UpdateCoursesState();
}

class _UpdateCoursesState extends State<UpdateCourses> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  String imgUrl = '';
  Uint8List? fileBytes;
  late ImageUploader imageUploader;
  bool isLoading = false;

  @override
  void initState() {
    _titleController = TextEditingController();
    _priceController = TextEditingController();
    imageUploader = ImageUploader();

    // Fetch course details based on the courseId from Firebase
    fetchCourseDetails();

    super.initState();
  }

  void fetchCourseDetails() async {
    try {
      DocumentSnapshot courseSnapshot =
          await FirebaseFirestore.instance.collection('courses').doc(widget.courseId).get();

      setState(() {
        _titleController.text = courseSnapshot['title'];
        _priceController.text = courseSnapshot['price'].toString();
        imgUrl = courseSnapshot['image_url'];
      });
    } catch (error) {
      print('Error fetching course details: $error');
      // Handle error (e.g., display an error message)
    }
  }

  Future<void> selectImage() async {
    try {
      setState(() {
        isLoading = true;
      });

      Uint8List? bytes = await imageUploader.pickImage();

      if (bytes != null) {
        setState(() {
          fileBytes = bytes;
          imgUrl = ''; // Clear the existing image URL when a new image is selected
        });
      }
    } catch (error) {
      print('Error selecting image: $error');
      // Handle error (e.g., display an error message)
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

 Future<void> uploadToFirebase() async {
  if (_titleController.text.isNotEmpty && fileBytes != null) {
    try {
      setState(() {
        isLoading = true;
      });

      double price = double.tryParse(_priceController.text) ?? 0.0;

      if (price >= 0) {
        String downloadUrl = imgUrl.isNotEmpty
            ? imgUrl
            : await imageUploader.uploadImage(fileBytes!);

        // Save data to Firebase Firestore
        await saveDataToFirebase(downloadUrl, price);

        // Show confirmation dialog
        showConfirmationDialog('Course updated successfully!');
      } else {
        showConfirmationDialog('Invalid price. Please enter a non-negative value.');
      }
    } catch (error, stackTrace) {
      print("Error uploading to Firebase: $error");
      // Print the stack trace for more detailed error information
      print(stackTrace);
      showConfirmationDialog('Error updating course. Please try again later.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  } else {
    // Handle the case where fileBytes is null (no image selected)
  }
}

Future<void> saveDataToFirebase(String downloadUrl, double price) async {
  try {
    await FirebaseFirestore.instance.collection('courses').doc(widget.courseId).update({
      'title': _titleController.text,
      'image_url': downloadUrl,
      'price': price,
    });
    print('Data updated in Firestore successfully!');
  } catch (error, stackTrace) {
    print('Error updating data in Firestore: $error');
    // Print the stack trace for more detailed error information
    print(stackTrace);
    // Handle error (e.g., display an error message)
  }
}


void showConfirmationDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Course'),
      ),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  selectImage();
                },
                child: Text('Change Image'),
              ),
              SizedBox(height: 20),
             FutureBuilder(
  future: loadImage(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Text('Error loading image: ${snapshot.error}');
      } else {
        return Image.memory(
          snapshot.data as Uint8List,
          height: 200,
          width: 200,
          fit: BoxFit.cover,
        );
      }
    } else {
      return CircularProgressIndicator();
    }
  },
),
              SizedBox(height: 20),
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
              ElevatedButton(
                onPressed: () {
                  uploadToFirebase();
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 180, 139, 187),
                  textStyle: TextStyle(color: Colors.white),
                ),
                child: Text('Update Course'),
              ),
              if (isLoading) CircularProgressIndicator(), // Loading indicator
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> loadImage() async {
    try {
      if (imgUrl.isNotEmpty) {
        return await imageUploader.loadImage(imgUrl);
      } else if (fileBytes != null) {
        return fileBytes;
      } else {
        return null;
      }
    } catch (error) {
      print('Error loading image: $error');
      return null;
    }
  }
}

class ImageUploader {
  Future<String> uploadImage(Uint8List bytes) async {
    FirebaseStorage fs = FirebaseStorage.instance;
    int date = DateTime.now().millisecondsSinceEpoch;
    final reference = await fs.ref().child('courses/$date.png');

    SettableMetadata metadata = SettableMetadata(contentType: 'image/png');
    final uploadTask = reference.putData(bytes, metadata);

    final snapshot = await uploadTask;
    String imageURL = await snapshot.ref.getDownloadURL();
    return imageURL;
  }

  Future<Uint8List?> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.single.bytes;
    }
    return null;
  }

  Future<Uint8List?> loadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image');
      }
    } catch (error) {
      print('Error loading image: $error');
      return null;
    }
  }
}
