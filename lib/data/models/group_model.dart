import 'package:json_annotation/json_annotation.dart';

part 'group_model.g.dart';

@JsonSerializable()
class GroupModel {
  final int id;
  final String name;
  @JsonKey(name: 'academic_year')
  final String academicYear;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'student_count')
  final int? studentCount; // From admin API response

  const GroupModel({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.createdAt,
    this.studentCount,
  });

  // Get display name with academic year
  String get displayName => '$name ($academicYear)';

  // Check if group has students
  bool get hasStudents => studentCount != null && studentCount! > 0;

  // Get student count text
  String get studentCountText {
    if (studentCount == null) return '';
    if (studentCount == 0) return 'Talabalar yo\'q';
    if (studentCount == 1) return '1 talaba';
    return '$studentCount talaba';
  }

  // JSON serialization
  factory GroupModel.fromJson(Map<String, dynamic> json) => _$GroupModelFromJson(json);
  Map<String, dynamic> toJson() => _$GroupModelToJson(this);

  // Copy with method
  GroupModel copyWith({
    int? id,
    String? name,
    String? academicYear,
    DateTime? createdAt,
    int? studentCount,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      academicYear: academicYear ?? this.academicYear,
      createdAt: createdAt ?? this.createdAt,
      studentCount: studentCount ?? this.studentCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GroupModel(id: $id, name: $name, academicYear: $academicYear, studentCount: $studentCount)';
  }
}