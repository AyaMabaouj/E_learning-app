import 'package:e_learningapp/models/Course.dart';
import 'package:e_learningapp/services/CourseManager.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class CourseController extends GetxController {
  RxList<Course> courses = <Course>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  Future<void> loadCourses() async {
    courses.value = await CourseManager().getCourses();
  }

  Future<void> addCourse(Course course) async {
    await CourseManager().addCourse(course);
    loadCourses();
  }

  Future<void> updateCourse(String courseId, Course course) async {
    await CourseManager().updateCourse(courseId, course);
    loadCourses();
  }

  Future<void> deleteCourse(String courseId) async {
    await CourseManager().deleteCourse(courseId);
    loadCourses();
  }
}