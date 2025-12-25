// lib/presentation/athletics/all_sports_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../core/utils/app_colors.dart';
import '../../controllers/athletics_controller.dart';
import '../../core/design_constants.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import '../../models/sport_data.dart';
import '../../widgets/animated_segmented_control.dart';
import '../../widgets/liquid_melting_header.dart';
import 'sport_detail_page.dart';
import '../../widgets/liquid_mesh_background.dart';

class AllSportsPage extends StatefulWidget {
  const AllSportsPage({super.key});

  @override
  State<AllSportsPage> createState() => _AllSportsPageState();
}

class _AllSportsPageState extends State<AllSportsPage> {
  final AthleticsController athleticsController = Get.put(AthleticsController());
  String _selectedSeason = 'Fall';
  final List<String> _seasons = ['Fall', 'Winter', 'Spring'];

  List<SportEntry> _getSportsForSeason(String season) {
    return SportsData.getSportsBySeason(season);
  }
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          const LiquidMeshBackground(),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: LiquidMeltingHeader(
                  title: 'All Sports',
                  showBackButton: true,
                  onBackPressed: () {
                    HapticFeedbackHelper.buttonPress();
                    Get.back();
                  },
                  topPadding: MediaQuery.of(context).padding.top,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06)
                    .copyWith(top: screenWidth * 0.057),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: screenHeight * 0.02),
                    _buildSeasonTabs(context),
                    SizedBox(height: screenHeight * 0.03),
                    AnimatedContentSwitcher(
                      switchKey: _selectedSeason,
                      child: _buildSportsColumns(context),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonTabs(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06),
      child: AnimatedSegmentedControl(
        segments: _seasons,
        selectedSegment: _selectedSeason,
        onSelectionChanged: (season) {
          setState(() {
            _selectedSeason = season;
          });
        },
      ),
    );
  }

  Widget _buildSportsColumns(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final seasonSports = _getSportsForSeason(_selectedSeason);
    
    final girlsSports = seasonSports.where((sport) => sport.gender == 'girls').toList();
    final boysSports = seasonSports.where((sport) => sport.gender == 'boys').toList();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Girls Column
        Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                child: Center(
                  child: Text(
                    'Girls',
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              ...girlsSports.map((sport) => Padding(
                padding: EdgeInsets.only(bottom: screenWidth * 0.03),
                child: _SportCard(
                  name: SportsData.getDisplaySportName(sport.sport),
                  onTap: () => Get.to(() => SportDetailPage(
                    sportName: SportsData.getDisplaySportName(sport.sport),
                    gender: sport.gender,
                    season: sport.season,
                  )),
                ),
              )),
            ],
          ),
        ),
        SizedBox(width: screenWidth * 0.04),
        // Boys Column
        Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                child: Center(
                  child: Text(
                    'Boys',
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              ...boysSports.map((sport) => Padding(
                padding: EdgeInsets.only(bottom: screenWidth * 0.03),
                child: _SportCard(
                  name: SportsData.getDisplaySportName(sport.sport),
                  onTap: () => Get.to(() => SportDetailPage(
                    sportName: SportsData.getDisplaySportName(sport.sport),
                    gender: sport.gender,
                    season: sport.season,
                  )),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _SportCard extends StatelessWidget {
  const _SportCard({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double borderRadius = DesignConstants.get24Radius(context);
    final double verticalPadding = screenWidth * 0.04;
    
    return GestureDetector(
      onTapDown: (_) => HapticFeedbackHelper.buttonPress(),
      onTap: onTap,
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: borderRadius,
          cornerSmoothing: 1.0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
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
                  cornerRadius: borderRadius,
                  cornerSmoothing: 1.0,
                ),
                side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
              ),
            ),
            child: Center(
              child: Text(
                name,
                style: GoogleFonts.inter(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
