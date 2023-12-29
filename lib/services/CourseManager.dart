import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learningapp/models/Course.dart';
class CourseManager {
  final CollectionReference _coursesCollection =
      FirebaseFirestore.instance.collection('courses');

  Future<List<Course>> getCourses() async {
    var snapshot = await _coursesCollection.get();
    return snapshot.docs
        .map((doc) =>
            Course.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addCourse(Course course) async {
    await _coursesCollection.add(course.toMap());
  }

  Future<void> updateCourse(String courseId, Course course) async {
    await _coursesCollection.doc(courseId).update(course.toMap());
  }

  Future<void> deleteCourse(String courseId) async {
    await _coursesCollection.doc(courseId).delete();
  }
}
