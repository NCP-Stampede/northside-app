// lib/presentation/placeholder_pages/grades_page.dart

import 'package:flutter/material.dart';

// --- Data Model for Demonstration ---
class ClassGrade {
  const ClassGrade({
    required this.className,
    required this.teacherName,
    required this.grade,
  });
  final String className;
  final String teacherName;
  final double grade;
}
// --- End of Data Model ---

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  // --- State and Placeholder Data ---
  String _selectedYear = '2024-2025';
  String _selectedTerm = 'Current Term';

  final List<String> _years = ['2024-2025', '2023-2024', '2022-2023'];
  final List<String> _terms = ['Current Term', 'Term 1', 'Term 2', 'Final'];

  final List<ClassGrade> _classGrades = const [
    ClassGrade(className: 'HS1 Algebra 1', teacherName: 'Mr George', grade: 98),
    ClassGrade(className: 'HS1 US History', teacherName: 'Mr George', grade: 89.5),
    ClassGrade(className: 'HS1 AP Lang', teacherName: 'Mr George', grade: 76.9),
    ClassGrade(className: 'HS1 Physics', teacherName: 'Mr George', grade: 56.2),
    ClassGrade(className: 'HS1 Physical Education', teacherName: 'Mr George', grade: 100),
    ClassGrade(className: 'HS1 Colloquium', teacherName: 'Mr George', grade: 99),
    ClassGrade(className: 'HS1 Art 1', teacherName: 'Mr George', grade: 22),
  ];
  // --- End of State and Placeholder Data ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildDropdownSelectors(),
          const SizedBox(height: 24),
          _buildGradesList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Grades',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, color: Colors.black, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSelectors() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdownButton(
              value: _selectedYear,
              items: _years,
              onChanged: (newValue) {
                setState(() {
                  _selectedYear = newValue!;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdownButton(
              value: _selectedTerm,
              items: _terms,
              onChanged: (newValue) {
                setState(() {
                  _selectedTerm = newValue!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET WITH THE FIX ---
  Widget _buildDropdownButton({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          // FIX: This gives the dropdown menu itself rounded corners.
          borderRadius: BorderRadius.circular(12),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGradesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: _classGrades.map((grade) => _GradeCard(grade: grade)).toList(),
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.grade});
  final ClassGrade grade;

  Color _getGradeColor() {
    if (grade.grade >= 90) return Colors.green;
    if (grade.grade >= 80) return Colors.yellow.shade700;
    if (grade.grade >= 70) return Colors.orange.shade600;
    if (grade.grade >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _getGradeColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            stops: const [0.5, 1.0],
            colors: [
              Colors.white,
              gradeColor.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade.className,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      grade.teacherName,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: gradeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  grade.grade.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: gradeColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

