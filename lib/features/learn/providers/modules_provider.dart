import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/module.dart';

/// Loads all modules from assets/data/modules.json.
/// Cached automatically by Riverpod for the lifetime of the app.
final modulesProvider = FutureProvider<List<LearningModule>>((ref) async {
  final jsonString =
      await rootBundle.loadString('assets/data/modules.json');
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  final list = json['modules'] as List<dynamic>;
  return list
      .map((m) => LearningModule.fromJson(m as Map<String, dynamic>))
      .toList();
});

/// Finds a single module by ID.
/// Returns null if the module doesn't exist in the JSON.
final moduleByIdProvider =
    FutureProvider.family<LearningModule?, String>((ref, moduleId) async {
  final modules = await ref.watch(modulesProvider.future);
  try {
    return modules.firstWhere((m) => m.id == moduleId);
  } catch (_) {
    return null;
  }
});
