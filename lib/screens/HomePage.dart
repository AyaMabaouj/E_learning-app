import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<DocumentSnapshot> courses = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
    return Image.network(
      downloadURL.toString(),
      fit: BoxFit.cover,
      width: 150, // Set the desired width
      height: 150, // Set the desired height
    );
  } catch (error) {
    print('Error loading image: $error');
    return Image.asset(
      'assets/placeholder_image.png',
      fit: BoxFit.cover,
      width: 150, // Set the desired width
      height: 150, // Set the desired height
    );
  }
}

Widget buildCourseItem(DocumentSnapshot course) {
  return Card(
    margin: EdgeInsets.all(8.0),
    elevation: 2.0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 12, // Adjust the aspect ratio as needed
          child: FutureBuilder<Image>(
            future: loadImage(course['image_url']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return snapshot.data!;
              } else if (snapshot.hasError) {
                return Image.asset(
                  'assets/placeholder_image.png',
                  fit: BoxFit.cover,
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                course['title'],
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.0),
              Text(
                'Price: ${course['price']}DT/Month',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Color.fromARGB(255, 173, 34, 81),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


 
  Widget buildCourseList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return FutureBuilder<Image>(
          future: loadImage(courses[index]['image_url']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return buildCourseItem(courses[index]);
            } else if (snapshot.hasError) {
              return buildCourseItem(
                courses[index],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        );
      },
    );
  }
  Widget buildLoadingIndicator() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(),
    );
  }

Widget buildContactForm() {
  TextEditingController nameController = TextEditingController(text: 'Aya Mabaouj');
  TextEditingController emailController = TextEditingController(text: 'mabaoujaya@gmail.com');
  TextEditingController messageController = TextEditingController(text: 'Write your message here');

  return Center(
    child: Container(
      width: 700.0,
      padding: EdgeInsets.all(16.0),
      child: Card(
        color: Color.fromARGB(255, 255, 195, 57),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.0),
                buildLabeledTextField('Name', nameController),
                SizedBox(height: 8.0),
                buildLabeledTextField('Email', emailController),
                SizedBox(height: 8.0),
                buildLabeledMultilineTextField('Message', messageController),
                SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your message-sending functionality here
                      print('Send message button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 167, 34, 79),
                      minimumSize: Size(150, 50),
                    ),
                    child: Text(
                      'Send Message',
                      style: TextStyle(
                        color: Colors.white,
                      ),
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

Widget buildLabeledTextField(String label, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(1.0),
        ),
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.grey,
        ),
      ),
    ],
  );
}

Widget buildLabeledMultilineTextField(String label, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
        maxLines: 4,
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.grey,
        ),
      ),
    ],
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
          CustomContactUsButton(scrollController: _scrollController),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
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
            Container(
              padding: EdgeInsets.all(10),
              child: buildCourseList(),
            ),
            // Display the contact form
            buildContactForm(),
          ],
        ),
      ),
    );
  }
}


class CustomContactUsButton extends StatelessWidget {
  final ScrollController scrollController;

  const CustomContactUsButton({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          scrollToContactForm();
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
  void scrollToContactForm() {
    double offset = 700.0; // Adjust the offset based on your layout
    scrollController.animateTo(offset, duration: Duration(seconds: 1), curve: Curves.easeInOut);
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
