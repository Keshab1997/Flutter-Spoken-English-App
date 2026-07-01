import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/guide_model.dart';

/// Service to load guide data from JSON assets
class GuideService {
  static const String _studentGuidePath = 'assets/pdfs/student_guide.json';
  static const String _studyRoutinePath = 'assets/pdfs/study_routine.json';

  /// Loads the Student Guide from the JSON asset
  static Future<GuideData> loadStudentGuide() async {
    final jsonString = await rootBundle.loadString(_studentGuidePath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return GuideData.fromJson(json, iconOverride: Icons.school_rounded);
  }

  /// Loads the Study Routine from the JSON asset
  static Future<GuideData> loadStudyRoutine() async {
    final jsonString = await rootBundle.loadString(_studyRoutinePath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return GuideData.fromJson(json, iconOverride: Icons.calendar_today_rounded);
  }
}
