import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/recipe_model.dart';
import '../../widgets/pixel_panel.dart';
import '../recipes/add_recipe_screen.dart';
import '../recipes/recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tavern Recipe Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.door_back_door, color: Color(0xFFF4EAD4)),
            tooltip: 'Leave Tavern',
            onPressed: () async => await authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: dbService.publicRecipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2E8B57)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No recipes pinned to the board yet.',
                style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFFE2D6B5)),
              ),
            );
          }

          final recipes = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return _buildRecipeCard(context, recipes[index])
                  .animate()
                  .fadeIn(delay: (50 * index).ms) // Staggered entrance
                  .slideY(begin: 0.1, end: 0);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E8B57),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF1A0F08), width: 4),
          borderRadius: BorderRadius.circular(0), // Hard edges
        ),
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        label: Text(
          'CRAFT',
          style: GoogleFonts.pixelifySans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRecipeScreen()));
        },
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)));
      },
      child: PixelPanel(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5A2B), // Placeholder for food pixel image
                  border: Border.all(color: const Color(0xFF1A0F08), width: 3),
                ),
                child: const Center(
                  child: Icon(Icons.restaurant, color: Color(0xFFF4EAD4), size: 40), // Replace with pixel assets
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              recipe.title,
              style: GoogleFonts.pixelifySans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A0F08)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'By ${recipe.authorName}',
              style: GoogleFonts.vt323(fontSize: 18, color: const Color(0xFF5C3A21)),
            ),
          ],
        ),
      ),
    );
  }
}