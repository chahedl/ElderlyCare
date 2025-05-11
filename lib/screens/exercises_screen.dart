import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/exercise.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late Future<List<Exercise>> _exercisesFuture;
  String? selectedMuscle = 'biceps';
  String? selectedDifficulty;
  String? selectedType;

  final List<String> muscleGroups = [
    'abdominals',
    'abductors',
    'adductors',
    'biceps',
    'calves',
    'chest',
    'forearms',
    'glutes',
    'hamstrings',
    'lats',
    'lower_back',
    'middle_back',
    'neck',
    'quadriceps',
    'traps',
    'triceps',
  ];

  final List<String> difficulties = ['beginner', 'intermediate', 'expert'];

  final List<String> types = [
    'cardio',
    'olympic_weightlifting',
    'plyometrics',
    'powerlifting',
    'strength',
    'stretching',
    'strongman',
  ];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  void _fetchExercises() {
    final apiService = ApiService('', null);
    _exercisesFuture = apiService.fetchExercises(
      muscle: selectedMuscle,
      difficulty: selectedDifficulty,
      type: selectedType,
    );
  }

  void _onFilterChanged() {
    setState(() {
      _fetchExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Exercises'),
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.2),
                  primaryColor.withOpacity(0.1)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              alignment: WrapAlignment.center,
              children: [
                _buildFilterDropdown(
                  hint: 'Muscle',
                  value: selectedMuscle,
                  items: muscleGroups,
                  icon: Icons.accessibility,
                  onChanged: (value) {
                    setState(() {
                      selectedMuscle = value;
                      _onFilterChanged();
                    });
                  },
                  primaryColor: primaryColor,
                ),
                _buildFilterDropdown(
                  hint: 'Difficulty',
                  value: selectedDifficulty,
                  items: difficulties,
                  icon: Icons.fitness_center,
                  onChanged: (value) {
                    setState(() {
                      selectedDifficulty = value;
                      _onFilterChanged();
                    });
                  },
                  primaryColor: primaryColor,
                ),
                _buildFilterDropdown(
                  hint: 'Type',
                  value: selectedType,
                  items: types,
                  icon: Icons.category,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                      _onFilterChanged();
                    });
                  },
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
          // Exercise List
          Expanded(
            child: FutureBuilder<List<Exercise>>(
              future: _exercisesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final exercises = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: exercises.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return ExerciseCard(exercise: exercise);
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    required Color primaryColor,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(hint, style: TextStyle(color: primaryColor)),
          ],
        ),
        value: value,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('All', style: TextStyle(color: primaryColor)),
          ),
          ...items.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item.capitalize(),
                    style: TextStyle(color: Colors.black87)),
              )),
        ],
        onChanged: onChanged,
        underline: const SizedBox(),
        style: TextStyle(color: Colors.black87, fontSize: 16),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);

    return GestureDetector(
      onTap: () {
        _showExerciseDetails(context, exercise);
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: 1.0,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: primaryColor.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Icon
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.fitness_center,
                    color: primaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                // Exercise Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.accessibility,
                              color: primaryColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            exercise.muscle.capitalize(),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.fitness_center,
                              color: primaryColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            exercise.difficulty.capitalize(),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                          const Spacer(),
                          Icon(Icons.category, color: primaryColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            exercise.type.capitalize(),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: primaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
    const primaryColor = Color(0xFF199A8E);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.accessibility, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Muscle: ${exercise.muscle.capitalize()}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.fitness_center, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Difficulty: ${exercise.difficulty.capitalize()}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Type: ${exercise.type.capitalize()}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.build, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Equipment: ${exercise.equipment.capitalize()}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.instructions,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
