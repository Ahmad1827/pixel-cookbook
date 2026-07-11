import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Recipe>> get publicRecipes {
    return _db
        .collection('recipes')
        .where('isPublic', isEqualTo: true) 
        .snapshots()
        .map((snapshot) {
          final recipes = snapshot.docs
              .map((doc) => Recipe.fromMap(doc.id, doc.data()))
              .toList();
          
          recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return recipes;
        });
  }

  Stream<List<Recipe>> userRecipes(String userId) {
    return _db
        .collection('recipes')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _db.collection('recipes').add(recipe.toMap());
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _db.collection('recipes').doc(recipeId).delete();
  }

  Future<void> updateRecipeStatus(String id, String newStatus) async {
    await _db.collection('recipes').doc(id).update({'status': newStatus});
  }
}