import 'package:json_annotation/json_annotation.dart';

part 'subject_model.g.dart';

@JsonSerializable()
class SubjectModel {
  final int id;
  final String name;
  final String code;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.code,
  });

  // Get display name with code
  String get displayName => '$name ($code)';

  // Get subject icon based on name/code
  String get subjectIcon {
    final lowerName = name.toLowerCase();
    final lowerCode = code.toLowerCase();

    if (lowerName.contains('matematika') || lowerCode.contains('math')) {
      return '📐';
    } else if (lowerName.contains('fizika') || lowerCode.contains('phys')) {
      return '⚡';
    } else if (lowerName.contains('kimyo') || lowerCode.contains('chem')) {
      return '🧪';
    } else if (lowerName.contains('biologiya') || lowerCode.contains('bio')) {
      return '🧬';
    } else if (lowerName.contains('ingliz') || lowerCode.contains('eng')) {
      return '🇬🇧';
    } else if (lowerName.contains('o\'zbek') || lowerCode.contains('uzb')) {
      return '🇺🇿';
    } else if (lowerName.contains('tarix') || lowerCode.contains('hist')) {
      return '📚';
    } else if (lowerName.contains('geografiya') || lowerCode.contains('geo')) {
      return '🌍';
    } else {
      return '📖';
    }
  }

  // Get subject color based on type
  String get subjectColor {
    final lowerCode = code.toLowerCase();

    if (lowerCode.contains('math')) return '#2196F3'; // Blue
    if (lowerCode.contains('phys')) return '#9C27B0'; // Purple
    if (lowerCode.contains('chem')) return '#4CAF50'; // Green
    if (lowerCode.contains('bio')) return '#8BC34A'; // Light Green
    if (lowerCode.contains('eng')) return '#FF9800'; // Orange
    if (lowerCode.contains('uzb')) return '#F44336'; // Red
    if (lowerCode.contains('hist')) return '#795548'; // Brown
    if (lowerCode.contains('geo')) return '#00BCD4'; // Cyan

    return '#607D8B'; // Blue Grey (default)
  }

  // JSON serialization
  factory SubjectModel.fromJson(Map<String, dynamic> json) => _$SubjectModelFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectModelToJson(this);

  // Copy with method
  SubjectModel copyWith({
    int? id,
    String? name,
    String? code,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SubjectModel(id: $id, name: $name, code: $code)';
  }
}