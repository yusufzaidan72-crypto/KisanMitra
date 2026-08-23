import 'dart:convert';

class CropMonitor {
  final String id;
  final String cropName;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final String growthStage;
  final String soilType;
  final String notes;
  final List<CropTask> tasks;
  final List<CropNote> history;

  const CropMonitor({
    required this.id,
    required this.cropName,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.growthStage,
    required this.soilType,
    this.notes = '',
    this.tasks = const [],
    this.history = const [],
  });

  int get cropAgeInDays => DateTime.now().difference(plantingDate).inDays;

  int get totalDuration => expectedHarvestDate.difference(plantingDate).inDays;

  double get progressPercent {
    final elapsed = cropAgeInDays;
    if (elapsed <= 0) return 0;
    if (elapsed >= totalDuration) return 1.0;
    return elapsed / totalDuration;
  }

  int get daysToHarvest {
    final remaining = expectedHarvestDate.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropName': cropName,
        'plantingDate': plantingDate.toIso8601String(),
        'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
        'growthStage': growthStage,
        'soilType': soilType,
        'notes': notes,
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'history': history.map((h) => h.toJson()).toList(),
      };

  factory CropMonitor.fromJson(Map<String, dynamic> json) => CropMonitor(
        id: json['id'],
        cropName: json['cropName'],
        plantingDate: DateTime.parse(json['plantingDate']),
        expectedHarvestDate: DateTime.parse(json['expectedHarvestDate']),
        growthStage: json['growthStage'],
        soilType: json['soilType'],
        notes: json['notes'] ?? '',
        tasks: (json['tasks'] as List? ?? [])
            .map((t) => CropTask.fromJson(t))
            .toList(),
        history: (json['history'] as List? ?? [])
            .map((h) => CropNote.fromJson(h))
            .toList(),
      );

  String toJsonString() => jsonEncode(toJson());

  CropMonitor copyWith({
    String? growthStage,
    String? notes,
    List<CropTask>? tasks,
    List<CropNote>? history,
  }) {
    return CropMonitor(
      id: id,
      cropName: cropName,
      plantingDate: plantingDate,
      expectedHarvestDate: expectedHarvestDate,
      growthStage: growthStage ?? this.growthStage,
      soilType: soilType,
      notes: notes ?? this.notes,
      tasks: tasks ?? this.tasks,
      history: history ?? this.history,
    );
  }
}

class CropTask {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final TaskType type;

  const CropTask({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.isCompleted,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dueDate': dueDate.toIso8601String(),
        'isCompleted': isCompleted,
        'type': type.name,
      };

  factory CropTask.fromJson(Map<String, dynamic> json) => CropTask(
        id: json['id'],
        title: json['title'],
        dueDate: DateTime.parse(json['dueDate']),
        isCompleted: json['isCompleted'] ?? false,
        type: TaskType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TaskType.other,
        ),
      );
}

class CropNote {
  final String id;
  final String note;
  final DateTime date;

  const CropNote({required this.id, required this.note, required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory CropNote.fromJson(Map<String, dynamic> json) => CropNote(
        id: json['id'],
        note: json['note'],
        date: DateTime.parse(json['date']),
      );
}

enum TaskType { irrigation, fertilizer, pesticide, harvest, monitoring, other }
