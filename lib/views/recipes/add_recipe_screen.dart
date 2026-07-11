import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/database_service.dart';
import '../../services/audio_service.dart';
import '../../models/recipe_model.dart';
import '../../widgets/pixel_panel.dart';
import '../../widgets/pixel_button.dart';
import '../../widgets/pixel_text_field.dart';
import 'cooking_sequence_screen.dart'; 

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientController = TextEditingController();
  final _instructionController = TextEditingController();
  
  final List<String> _ingredients = [];
  final List<String> _instructions = [];
  bool _isPublic = true;
  String _selectedCategory = 'General';
  final List<String> _categories = ['All', 'Meat', 'Veggie', 'Dessert', 'Drinks', 'General'];

  void _addIngredient() {
    if (_ingredientController.text.trim().isNotEmpty) {
      // Trigger the knife cut sound!
      Provider.of<AudioService>(context, listen: false).playCutSound();
      
      setState(() {
        _ingredients.add(_ingredientController.text.trim());
        _ingredientController.clear();
      });
    }
  }

  void _addInstruction() {
    if (_instructionController.text.trim().isNotEmpty) {
      // Trigger the knife cut sound!
      Provider.of<AudioService>(context, listen: false).playCutSound();

      setState(() {
        _instructions.add(_instructionController.text.trim());
        _instructionController.clear();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final user = Provider.of<User?>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              PixelPanel(
                baseColor: const Color(0xFF1A0F08),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFF4EAD4)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'CRAFTING BENCH',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pixelifySans(fontSize: 24, color: const Color(0xFFF4EAD4)),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PixelPanel(
                baseColor: const Color(0xFFD4C3A3),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PixelTextField(
                        controller: _titleController,
                        label: 'Creation Name',
                        validator: (val) => val!.isEmpty ? 'Enter a name' : null,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A0F08),
                          border: Border.all(color: const Color(0xFF5C3A21), width: 2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            dropdownColor: const Color(0xFF1A0F08),
                            iconEnabledColor: const Color(0xFFF4EAD4),
                            style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFFF4EAD4)),
                            isExpanded: true,
                            items: _categories.where((c) => c != 'All').map((String category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Inventory (Ingredients)', 
                        style: GoogleFonts.pixelifySans(
                          fontSize: 22, 
                          color: const Color(0xFF5C3A21),
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _ingredients.map((ing) => _buildInventorySlot(ing)).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: PixelTextField(
                              controller: _ingredientController,
                              label: 'Gather Ingredient',
                            ),
                          ),
                          const SizedBox(width: 12),
                          PixelButton(
                            text: '+',
                            color: const Color(0xFF8B5A2B),
                            onPressed: _addIngredient,
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(color: Color(0xFF5C3A21), thickness: 4),
                      ),
                      Text(
                        'Scribe Steps (Instructions)', 
                        style: GoogleFonts.pixelifySans(
                          fontSize: 22, 
                          color: const Color(0xFF5C3A21),
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      const SizedBox(height: 12),
                      ..._instructions.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key + 1}.',
                              style: GoogleFonts.pixelifySans(fontSize: 24, color: const Color(0xFF8B5A2B), fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: GoogleFonts.vt323(fontSize: 22, color: const Color(0xFF1A0F08)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFFCD5C5C), size: 28),
                              onPressed: () {
                                Provider.of<AudioService>(context, listen: false).playCutSound();
                                setState(() {
                                  _instructions.removeAt(entry.key);
                                });
                              },
                            )
                          ],
                        ),
                      )),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: PixelTextField(
                              controller: _instructionController,
                              label: 'Next Action',
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          PixelButton(
                            text: '+',
                            color: const Color(0xFF8B5A2B),
                            onPressed: _addInstruction,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: Text('Pin to Tavern Board (Public)', style: GoogleFonts.pixelifySans(fontSize: 18, color: const Color(0xFF5C3A21))),
                        value: _isPublic,
                        activeColor: const Color(0xFF2E8B57),
                        activeTrackColor: const Color(0xFF8FBC8F),
                        inactiveThumbColor: const Color(0xFFCD5C5C),
                        inactiveTrackColor: const Color(0xFFE2D6B5),
                        onChanged: (val) => setState(() => _isPublic = val),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: PixelButton(
                          text: 'COOK RECIPE',
                          color: const Color(0xFFCD5C5C),
                          onPressed: () {
                            if (_formKey.currentState!.validate() && user != null) {
                              final newRecipe = Recipe(
                                id: '',
                                title: _titleController.text.trim(),
                                authorId: user.uid,
                                authorName: user.displayName ?? user.email?.split('@')[0] ?? 'Chef',
                                ingredients: _ingredients,
                                instructions: _instructions,
                                isPublic: _isPublic,
                                createdAt: DateTime.now(),
                                status: 'pending',
                                category: _selectedCategory,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CookingSequenceScreen(
                                    saveFuture: () => dbService.addRecipe(newRecipe),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventorySlot(String item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE6CE),
        border: Border.all(color: const Color(0xFF1A0F08), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(2, 2),
            blurRadius: 0,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco, color: Color(0xFF2E8B57), size: 16),
          const SizedBox(width: 8),
          Text(
            item, 
            style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFF1A0F08), fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}