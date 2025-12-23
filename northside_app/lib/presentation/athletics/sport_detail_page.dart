// lib/presentation/athletics/sport_detail_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../models/sport_data.dart';
import '../../models/athletics_schedule.dart';
import '../../models/athlete.dart';
import '../../core/utils/app_colors.dart';
import '../../controllers/athletics_controller.dart' as AC;
import '../../core/design_constants.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import '../../core/utils/logger.dart';
import '../../widgets/animated_segmented_control.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/liquid_melting_header.dart';
import '../../api.dart';
import '../../widgets/liquid_mesh_background.dart';

class GameSchedule {
  const GameSchedule({required this.date, required this.time, required this.event, required this.opponent, required this.location, required this.score, required this.result});
  final String date;
  final String time;
  final String event;
  final String opponent;
  final String location;
  final String score;
  final String result;
}

class Player {
  const Player({required this.name, required this.number, required this.position, required this.grade});
  final String name;
  final String number;
  final String position;
  final String grade;
}

class SportDetailPage extends StatefulWidget {
  const SportDetailPage({
    super.key, 
    required this.sportName,
    this.gender,
    this.season,
  });
  final String sportName;
  final String? gender;
  final String? season;

  @override
  State<SportDetailPage> createState() => _SportDetailPageState();
}

class _SportDetailPageState extends State<SportDetailPage> {
  final AC.AthleticsController athleticsController = Get.put(AC.AthleticsController());
  String _selectedLevel = 'Varsity';
  List<String> _levels = ['Varsity', 'JV', 'Freshman'];
  List<GameSchedule> _schedules = [];
  List<Player> _roster = [];
  bool _isLoadingRoster = false;

  // Helper function to format level names for display
  String _formatLevelName(String level) {
    switch (level.toLowerCase()) {
      case 'varsity':
        return 'Varsity';
      case 'jv':
      case 'junior varsity':
        return 'JV';
      case 'freshman':
        return 'Freshman';
      default:
        return level;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSportData();
  }

  void _loadSportData() async {
    // Use the gender and season passed from constructor, or extract from sportName as fallback
    String sportName = widget.sportName;
    String? gender = widget.gender;
    
    // Fallback logic for backwards compatibility
    if (gender == null) {
      if (sportName.startsWith("Boys ")) {
        sportName = sportName.substring(5);
        gender = 'boys';  // Use lowercase to match backend data format
      } else if (sportName.startsWith("Girls ")) {
        sportName = sportName.substring(6);
        gender = 'girls';  // Use lowercase to match backend data format
      }
    }

    // Convert sport name to backend format for API calls
    final backendSportName = SportsData.formatSportForBackend(sportName);

    // Use the sport name as formatted by formatSportForBackend (handles case correctly)
    final apiSportName = backendSportName;

    // Load all athletes for this sport/gender to get available levels
    try {
      // Use the new loadTeamData method for fresh data from API
      final teamData = await athleticsController.loadTeamData(
        sport: apiSportName,
        gender: gender,
      );
      
      // Use hardcoded levels - no dynamic detection needed
      _levels = ['Varsity', 'JV', 'Freshman'];
      AppLogger.debug('Using hardcoded levels for $apiSportName ($gender): $_levels');
      
      // Also use fresh schedule data
      if (teamData['schedule'] is List) {
        final freshSchedule = (teamData['schedule'] as List<AthleticsSchedule>);
        _schedules = freshSchedule.map((event) => event.toGameSchedule()).toList();
        AppLogger.debug('Found ${_schedules.length} schedule items for sport: $apiSportName, gender: $gender');
      }
    } catch (e) {
      AppLogger.debug('Error loading fresh team data: $e');
      
      // Use hardcoded levels even on error
      _levels = ['Varsity', 'JV', 'Freshman'];
      
      // Get schedule for this sport and gender as fallback
      final schedule = athleticsController.getScheduleByFilters(
        sport: apiSportName,
        gender: gender,
      );
      _schedules = schedule.map((event) => event.toGameSchedule()).toList();
      AppLogger.debug('Found ${_schedules.length} schedule items for sport: $apiSportName, gender: $gender (fallback)');
    }

    // Load initial roster
    _updateRoster();
    
    setState(() {});
  }

  void _updateRoster() async {
    String sportName = widget.sportName;
    String? gender = widget.gender;
    String? level;
    
    // Fallback logic for backwards compatibility
    if (gender == null) {
      if (sportName.startsWith("Boys ")) {
        sportName = sportName.substring(5);
        gender = 'boys';  // Use lowercase to match backend data format
      } else if (sportName.startsWith("Girls ")) {
        sportName = sportName.substring(6);
        gender = 'girls';  // Use lowercase to match backend data format
      }
    }

    // Convert sport name to backend format for API calls
    final backendSportName = SportsData.formatSportForBackend(sportName);
    final apiSportName = backendSportName;

    if (_selectedLevel != 'Varsity') {
      level = _selectedLevel.toLowerCase();
      // For roster API, athletes use 'jv', not 'junior varsity'
      if (level == 'junior varsity') {
        level = 'jv';
      }
    }

    AppLogger.debug('Updating roster with filters: sport=$apiSportName, gender=$gender, level=$level, selectedLevel=$_selectedLevel');

    setState(() {
      _isLoadingRoster = true;
    });

    // Load roster dynamically from API with filters
    try {
      final athletes = await ApiService.getRoster(
        sport: apiSportName,
        gender: gender,
        level: level,
      );
      _roster = athletes.map((athlete) => athlete.toPlayer()).toList();
      AppLogger.debug('Loaded ${_roster.length} athletes from API for sport: $apiSportName, gender: $gender, level: $level');
    } catch (e) {
      AppLogger.debug('Error loading filtered roster: $e');
      // Fallback to client-side filtering
      final athletes = athleticsController.getAthletesBySport(
        sport: apiSportName,
        gender: gender,
        level: level,
      );
      _roster = athletes.map((athlete) => athlete.toPlayer()).toList();
      AppLogger.debug('Loaded ${_roster.length} athletes from controller fallback for sport: $apiSportName, gender: $gender, level: $level');
    }

    if (mounted) {
      setState(() {
        _isLoadingRoster = false;
      });
    }
  }

  void _updateSchedule() async {
    String sportName = widget.sportName;
    String? gender = widget.gender;
    String? level;
    
    // Fallback logic for backwards compatibility
    if (gender == null) {
      if (sportName.startsWith("Boys ")) {
        sportName = sportName.substring(5);
        gender = 'boys';
      } else if (sportName.startsWith("Girls ")) {
        sportName = sportName.substring(6);
        gender = 'girls';
      }
    }

    // Convert sport name to backend format for API calls
    final backendSportName = SportsData.formatSportForBackend(sportName);
    final apiSportName = backendSportName;

    if (_selectedLevel != 'Varsity') {
      level = _selectedLevel.toLowerCase();
      if (level == 'junior varsity') {
        level = 'jv';
      }
    }

    AppLogger.debug('Updating schedule with filters: sport=$apiSportName, gender=$gender, level=$level');

    // Load schedule dynamically from API with filters
    try {
      final scheduleEvents = await ApiService.getAthleticsSchedule(
        sport: apiSportName,
        gender: gender,
        level: level,
      );
      _schedules = scheduleEvents.map((event) => event.toGameSchedule()).toList();
      AppLogger.debug('Loaded ${_schedules.length} schedule events from API for sport: $apiSportName, gender: $gender, level: $level');
    } catch (e) {
      AppLogger.debug('Error loading filtered schedule: $e');
      // Fallback to client-side filtering
      final scheduleEvents = athleticsController.getScheduleByFilters(
        sport: apiSportName,
        gender: gender,
        level: level,
      );
      _schedules = scheduleEvents.map((event) => event.toGameSchedule()).toList();
      AppLogger.debug('Loaded ${_schedules.length} schedule events from controller fallback for sport: $apiSportName, gender: $gender, level: $level');
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          const LiquidMeshBackground(),
          Obx(() {
            if (athleticsController.isLoading.value) {
              return const LoadingIndicator(
                message: 'Loading sport details...',
                showBackground: false,
              );
            }
            
            if (athleticsController.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${athleticsController.error.value}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () { HapticFeedbackHelper.buttonPress(); athleticsController.refreshData(); },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: LiquidMeltingHeader(
                    title: widget.sportName,
                    showBackButton: true,
                    onBackPressed: () {
                      HapticFeedbackHelper.buttonPress();
                      Get.back();
                    },
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06)
                      .copyWith(top: screenWidth * 0.057),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      AnimatedSegmentedControl(
                        segments: _levels,
                        selectedSegment: _selectedLevel,
                        onSelectionChanged: (level) {
                          setState(() {
                            _selectedLevel = level;
                            _updateRoster();
                            _updateSchedule();
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      AnimatedContentSwitcher(
                        switchKey: _selectedLevel,
                        child: Column(
                          children: [
                            _buildTableContainer(context, 'Schedules and Scores', _buildScheduleTable(context)),
                            SizedBox(height: screenHeight * 0.03),
                            _buildTableContainer(context, 'Rosters', _buildRosterTable(context)),
                            SizedBox(height: screenHeight * 0.05),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableContainer(BuildContext context, String title, Widget table) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: DesignConstants.get24Radius(context),
        cornerSmoothing: 1.0,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.12),
              ],
            ),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: DesignConstants.get24Radius(context),
                cornerSmoothing: 1.0,
              ),
              side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: screenWidth * 0.02),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: table,
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataTable _buildScheduleTable(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (_schedules.isEmpty) {
      return DataTable(
        columnSpacing: screenWidth * 0.08,
        columns: ['DATE', 'TIME', 'EVENT', 'OPPONENT', 'LOCATION', 'SCORE', 'W/L'].map((h) => DataColumn(label: _headerText(h, screenWidth))).toList(),
        rows: [
          DataRow(cells: [
            DataCell(
              Container(
                width: screenWidth * 0.7, // Set explicit width
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                child: Center(
                  child: Text(
                    'No games currently scheduled',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.035,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
          ]),
        ],
      );
    }
    
    return DataTable(
      columnSpacing: screenWidth * 0.08,
      columns: ['DATE', 'TIME', 'EVENT', 'OPPONENT', 'LOCATION', 'SCORE', 'W/L'].map((h) => DataColumn(label: _headerText(h, screenWidth))).toList(),
      rows: _schedules.map((s) => DataRow(cells: [
        DataCell(_dataText(s.date, screenWidth)),
        DataCell(_dataText(s.time, screenWidth)),
        DataCell(_dataText(s.event, screenWidth)),
        DataCell(_dataText(s.opponent, screenWidth)),
        DataCell(_dataText(s.location, screenWidth)),
        DataCell(_dataText(s.score, screenWidth)),
        DataCell(_dataText(s.result, screenWidth)),
      ])).toList(),
    );
  }

  Widget _buildRosterTable(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (_isLoadingRoster) {
      return Container(
        padding: EdgeInsets.all(screenWidth * 0.1),
        child: const LoadingIndicator(
          message: 'Loading roster...',
          showBackground: false,
        ),
      );
    }
    
    if (_roster.isEmpty) {
      return DataTable(
        columnSpacing: screenWidth * 0.08,
        columns: ['NAME', '#', 'POSITION', 'GRADE'].map((h) => DataColumn(label: _headerText(h, screenWidth))).toList(),
        rows: [
          DataRow(cells: [
            DataCell(
              Container(
                width: screenWidth * 0.6, // Set explicit width
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                child: Center(
                  child: Text(
                    'No roster currently exists',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.035,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const DataCell(Text('')),
            const DataCell(Text('')),
            const DataCell(Text('')),
          ]),
        ],
      );
    }
    
    return DataTable(
      columnSpacing: screenWidth * 0.08,
      columns: ['NAME', '#', 'POSITION', 'GRADE'].map((h) => DataColumn(label: _headerText(h, screenWidth))).toList(),
      rows: _roster.map((p) => DataRow(cells: [
        DataCell(_dataText(p.name, screenWidth)),
        DataCell(_dataText(p.number, screenWidth)),
        DataCell(_dataText(p.position, screenWidth)),
        DataCell(_dataText(p.grade, screenWidth)),
      ])).toList(),
    );
  }

  Text _headerText(String text, double screenWidth) {
    return Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: screenWidth * 0.032));
  }

  Text _dataText(String text, double screenWidth) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.w500, fontSize: screenWidth * 0.04, color: Colors.white.withOpacity(0.9)), overflow: TextOverflow.ellipsis);
  }
}

// If there are any pop-up or modal info screens, wrap their content in SafeArea.
