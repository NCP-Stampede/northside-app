import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stampede/controllers/athletics_controller.dart';
import 'package:stampede/models/sport_data.dart';

final sportsDataProvider = FutureProvider<SportsData>((ref) async {
  final sportsData = SportsData();
  await sportsData.init();
  return sportsData;
});
