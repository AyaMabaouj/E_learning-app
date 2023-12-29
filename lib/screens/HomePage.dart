import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<DocumentSnapshot> courses = [];

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      QuerySnapshot courseSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();
      setState(() {
        courses = courseSnapshot.docs;
      });
    } catch (error) {
      print('Error fetching courses: $error');
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
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return FutureBuilder<Image>(
          future: loadImage(courses[index]['image_url']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return buildCourseItem(courses[index], snapshot.data!);
            } else if (snapshot.hasError) {
              return buildCourseItem(
                  courses[index],
                  Image.asset('assets/placeholder_image.png',
                      fit: BoxFit.cover));
            } else {
              return buildLoadingIndicator();
            }
          },
        );
      },
    );
  }

 Widget buildCourseItem(DocumentSnapshot course, Widget courseImage) {
  return Card(
    margin: EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 200.0, // Adjust the height of the image container as needed
          child: courseImage,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['title'],
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Price: ${course['price']}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ],
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
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/bridge.png',
            height: 150,
            width: 150,
          ),
        ),
        actions: [
          CustomContactUsButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/live.png',
                  fit: BoxFit.fill,
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                ),
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Improve your skills on your own To prepare for a better future',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your registration button functionality here
                          print('Register button pressed');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 167, 34, 79),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discover Our Courses',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add your "View More" button functionality here
                      print('View More button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 167, 34, 79),
                    ),
                    child: Text(
                      'View More',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section for displaying the list of courses
            Container(
              padding: EdgeInsets.all(10),
              child: buildCourseList(),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomContactUsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          print('Contact Us button pressed');
        },
        child: Row(
          children: [
            Icon(
              Icons.contact_mail,
              color: Color.fromARGB(255, 238, 152, 14),
            ),
            SizedBox(width: 5),
            Text(
              'Contact Us',
              style: TextStyle(
                color: Color.fromRGBO(2, 2, 2, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
