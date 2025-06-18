// lib/presentation/flexes/flexes_controller.dart

import 'package:get/get.dart';
import '../../models/flex_choice.dart';

class FlexesController extends GetxController {
  // A reactive map to store the picked flex for each period.
  // The key is the flex period title (e.g., "Flex 1").
  final pickedFlexes = <String, FlexChoice>{}.obs;

  // Method to update the state when a flex is chosen.
  void selectFlex(String period, FlexChoice choice) {
    pickedFlexes[period] = choice;
    update(); // Notifies listeners to rebuild
  }

  // Helper method to check if a flex has been selected for a given period.
  FlexChoice? getPickedFlexFor(String period) {
    return pickedFlexes[period];
  }
}
