class Recipe {
  final String id;
  final String title;
  final String authorId;
  final String authorName;
  final List<String> ingredients;
  final List<String> instructions;
  final bool isPublic;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.authorId,
    required this.authorName,
    required this.ingredients,
    required this.instructions,
    required this.isPublic,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'authorId': authorId,
      'authorName': authorName,
      'ingredients': ingredients,
      'instructions': instructions,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      title: map['title'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      isPublic: map['isPublic'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}