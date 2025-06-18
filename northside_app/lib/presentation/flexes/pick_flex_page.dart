// lib/presentation/flexes/pick_flex_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'flexes_controller.dart';
import '../../models/flex_choice.dart';

class PickFlexPage extends StatefulWidget {
  const PickFlexPage({super.key, required this.flexPeriod});
  final String flexPeriod;

  @override
  State<PickFlexPage> createState() => _PickFlexPageState();
}

class _PickFlexPageState extends State<PickFlexPage> {
  // Local state to track the tapped option before confirming with "Done"
  FlexChoice? _selectedChoice;

  // Placeholder data for available flex options
  final List<FlexChoice> _availableChoices = const [
    FlexChoice(teacher: 'Mr. Smith', room: 'Room 201'),
    FlexChoice(teacher: 'Ms. Jones', room: 'Library'),
    FlexChoice(teacher: 'Mr. Davis', room: 'Gymnasium'),
    FlexChoice(teacher: 'Mrs. White', room: 'Room 305'),
  ];

  @override
  Widget build(BuildContext context) {
    // Find the controller to update the state when "Done" is pressed
    final FlexesController flexesController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Pick ${widget.flexPeriod}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _availableChoices.length,
                itemBuilder: (context, index) {
                  final choice = _availableChoices[index];
                  final isSelected = _selectedChoice == choice;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedChoice = choice),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(choice.teacher, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(choice.room, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  // Disable button if no choice is made
                  onPressed: _selectedChoice == null
                      ? null
                      : () {
                          // Update the central state and navigate back
                          flexesController.selectFlex(widget.flexPeriod, _selectedChoice!);
                          Get.back();
                        },
                  child: const Text('Done', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
