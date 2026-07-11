import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  String id;
  String title;
  String authorId;
  String authorName;
  List<String> ingredients;
  List<String> instructions;
  bool isPublic;
  DateTime createdAt;
  String status;
  String category;

  Recipe({
    required this.id,
    required this.title,
    required this.authorId,
    required this.authorName,
    required this.ingredients,
    required this.instructions,
    required this.isPublic,
    required this.createdAt,
    this.status = 'pending',
    this.category = 'General',
  });

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    DateTime parsedDate = DateTime.now();
    
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedDate = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
      }
    }

    return Recipe(
      id: id,
      title: map['title']?.toString() ?? 'Unknown Scroll',
      authorId: map['authorId']?.toString() ?? '',
      authorName: map['authorName']?.toString() ?? 'Wandering Chef',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      isPublic: map['isPublic'] is bool ? map['isPublic'] : true,
      createdAt: parsedDate,
      status: map['status']?.toString() ?? 'approved',
      category: map['category']?.toString() ?? 'General',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'authorId': authorId,
      'authorName': authorName,
      'ingredients': ingredients,
      'instructions': instructions,
      'isPublic': isPublic,
      'createdAt': createdAt,
      'status': status,
      'category': category,
    };
  }
}