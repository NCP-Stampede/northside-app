// lib/presentation/placeholder_pages/attendance_page.dart

import 'package:flutter/material.dart';

// --- Data Models for Demonstration ---
enum AttendanceStatus { present, absent, tardy, future }

class DayAttendance {
  const DayAttendance({required this.day, required this.status});
  final int day;
  final AttendanceStatus status;
}

class TardyInfo {
  const TardyInfo({required this.className, required this.teacherName});
  final String className;
  final String teacherName;
}
// --- End of Data Models ---

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  // --- Placeholder Data ---
  final List<DayAttendance> _attendanceData = const [
    DayAttendance(day: 29, status: AttendanceStatus.present),
    DayAttendance(day: 30, status: AttendanceStatus.absent),
    DayAttendance(day: 31, status: AttendanceStatus.present),
    DayAttendance(day: 1, status: AttendanceStatus.future),
    DayAttendance(day: 2, status: AttendanceStatus.future),
    DayAttendance(day: 3, status: AttendanceStatus.tardy),
    DayAttendance(day: 4, status: AttendanceStatus.present),
    DayAttendance(day: 5, status: AttendanceStatus.present),
  ];

  final List<TardyInfo> _tardyData = const [
    TardyInfo(className: 'HS1 Algebra', teacherName: 'Mr George'),
    TardyInfo(className: 'AP Chemistry', teacherName: 'Ms. Smith'),
  ];
  // --- End of Placeholder Data ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildDateScroller(),
          const SizedBox(height: 32),
          _buildTardiesSection(),
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
            'Attendance',
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

  Widget _buildDateScroller() {
    return SizedBox(
      // FIX 1: Increased height to prevent shadow clipping.
      height: 70,
      child: ListView.builder(
        // FIX 2: Added clipBehavior to allow shadows to draw outside the bounds.
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _attendanceData.length,
        itemBuilder: (context, index) {
          final data = _attendanceData[index];
          return _DateCircle(day: data.day, status: data.status);
        },
      ),
    );
  }

  Widget _buildTardiesSection() {
    return Column(
      // FIX 3: Changed alignment to stretch, forcing cards to fill the width.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Tardies',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        ..._tardyData.map((tardy) => _TardyCard(info: tardy)).toList(),
      ],
    );
  }
}

class _DateCircle extends StatelessWidget {
  const _DateCircle({required this.day, required this.status});
  final int day;
  final AttendanceStatus status;

  Color _getColor() {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.tardy:
        return Colors.amber.shade700;
      case AttendanceStatus.future:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      // FIX 4: Increased the size of the date circles for better visuals.
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getColor(),
        boxShadow: status != AttendanceStatus.future
            ? [
                BoxShadow(
                  color: _getColor().withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ]
            : [],
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            color: status == AttendanceStatus.future ? Colors.grey.shade600 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20, // Increased font size
          ),
        ),
      ),
    );
  }
}

class _TardyCard extends StatelessWidget {
  const _TardyCard({required this.info});
  final TardyInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      // This margin now works correctly with the stretch alignment.
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.className,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            info.teacherName,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
