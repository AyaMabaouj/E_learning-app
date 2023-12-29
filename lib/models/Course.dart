class Course {
  late String? id;
  late String? title;
  late String? image;
  late double? price;

  Course({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
  });

  factory Course.fromMap(Map<dynamic, dynamic> map, String id) {
    return Course(
      id: id,
      title: map['title'],
      image: map['image'],
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'image': image,
      'price': price,
    };
  }
}