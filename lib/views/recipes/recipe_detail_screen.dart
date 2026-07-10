import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/recipe_model.dart';
import '../../widgets/pixel_panel.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ancient Tome')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: PixelPanel(
          baseColor: const Color(0xFFF4EAD4), // Bright parchment paper
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                recipe.title.toUpperCase(),
                style: GoogleFonts.pixelifySans(
                  fontSize: 36, 
                  color: const Color(0xFF8B5A2B),
                  shadows: const [
                    Shadow(color: Color(0x40000000), offset: Offset(2, 2)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Discovered by ${recipe.authorName}', 
                style: GoogleFonts.vt323(fontSize: 22, color: const Color(0xFF5C3A21))
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Divider(color: Color(0xFF321B09), thickness: 4), // Heavy book bind line
              ),
              
              // Dynamic Layout: Side-by-side on wide screens, stacked on narrow screens
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildIngredientsList()),
                        Container(
                          width: 6, 
                          height: 300, 
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF321B09), // Book spine
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ), 
                        Expanded(child: _buildInstructionsList()),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIngredientsList(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(color: Color(0xFF321B09), thickness: 2),
                      ),
                      _buildInstructionsList(),
                    ],
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reagents', // Thematic wording
          style: GoogleFonts.pixelifySans(fontSize: 26, color: const Color(0xFF1A0F08), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...recipe.ingredients.map((ing) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.star, color: Color(0xFFDAA520), size: 20), // Golden star bullet
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ing,
                  style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFF1A0F08)),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildInstructionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ritual Steps', // Thematic wording
          style: GoogleFonts.pixelifySans(fontSize: 26, color: const Color(0xFF1A0F08), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...recipe.instructions.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5A2B),
                  border: Border.all(color: const Color(0xFF1A0F08), width: 2),
                ),
                child: Text(
                  '${entry.key + 1}',
                  style: GoogleFonts.pixelifySans(color: const Color(0xFFF4EAD4), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  entry.value,
                  style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFF1A0F08), height: 1.2),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}