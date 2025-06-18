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
  int _selectedTabIndex = 0; // 0 for "Current Year", 1 for "Current Term"

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
          _buildSegmentedControl(),
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

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTabItem('For Current Year', 0),
            _buildTabItem('Current Term', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
              ),
            ),
          ),
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

  // Helper function to get color based on grade
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
              // Class and Teacher Name
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
              // Grade Box and Arrow
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
