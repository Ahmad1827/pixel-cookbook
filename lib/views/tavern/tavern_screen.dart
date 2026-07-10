import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/recipe_model.dart';
import '../../widgets/pixel_panel.dart';
import '../../widgets/pixel_button.dart';
import '../../widgets/guild_auth_dialog.dart';
import '../recipes/add_recipe_screen.dart';
import '../recipes/recipe_detail_screen.dart';

class TavernScreen extends StatelessWidget {
  const TavernScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF2B1D14), // Dark tavern background
      // NO APP BAR. We are building a PC game UI.
      body: Row(
        children: [
          // LEFT SIDEBAR: Guild Navigation (The HUD)
          Container(
            width: 280, // Fixed width for the sidebar
            decoration: const BoxDecoration(
              color: Color(0xFF1A0F08),
              border: Border(right: BorderSide(color: Color(0xFF5C3A21), width: 4)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'THE\nTAVERN\nBOARD',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pixelifySans(
                    color: const Color(0xFFFFD700),
                    fontSize: 42,
                    height: 1.1,
                    shadows: const [Shadow(color: Colors.black, offset: Offset(3, 3))],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -2, end: 2, duration: 2.seconds),
                const SizedBox(height: 40),
                
                // Sidebar Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PixelButton(
                        text: 'CRAFT DISH',
                        color: const Color(0xFF2E8B57), // Green action button
                        onPressed: () {
                          if (user == null) {
                            showGuildAuthDialog(context);
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRecipeScreen()));
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (user != null)
                        PixelButton(
                          text: 'LEAVE GUILD',
                          color: const Color(0xFFCD5C5C), // Red exit button
                          onPressed: () async {
                            await Provider.of<AuthService>(context, listen: false).signOut();
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Player Status
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: const Color(0xFF3A2311),
                  child: Column(
                    children: [
                      const Icon(Icons.person, color: Color(0xFFF4EAD4), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        user != null ? 'Chef Logged In' : 'Wandering Guest',
                        style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFFF4EAD4)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // RIGHT AREA: The Main Quest Board
          Expanded(
            child: Container(
              color: const Color(0xFF3A2311), // Wooden wall color
              child: StreamBuilder<List<Recipe>>(
                stream: dbService.publicRecipes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF2E8B57)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'The board is empty...\nBe the first to pin a recipe!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.vt323(fontSize: 32, color: const Color(0xFFE2D6B5)),
                      ).animate().fadeIn(),
                    );
                  }

                  final recipes = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(32), // Lots of breathing room for PC
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 280, // Perfect card size for wide screens
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return _buildRecipeCard(context, recipes[index])
                          .animate()
                          .fadeIn(delay: (50 * index).ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                  );
                },
              ),
            ),
          ),
        ],
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
        baseColor: const Color(0xFFF4EAD4), // Bright parchment
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5A2B), 
                  border: Border.all(color: const Color(0xFF1A0F08), width: 3),
                ),
                child: const Center(
                  child: Icon(Icons.local_dining, color: Color(0xFFF4EAD4), size: 48), 
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              recipe.title,
              style: GoogleFonts.pixelifySans(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: const Color(0xFF1A0F08),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Chef: ${recipe.authorName}',
              style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFF5C3A21)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}