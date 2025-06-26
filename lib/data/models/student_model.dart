import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'group_model.dart';

part 'student_model.g.dart';

@JsonSerializable()
class StudentModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'group_id')
  final int groupId;
  @JsonKey(name: 'parent_phone')
  final String parentPhone;
  @JsonKey(name: 'graduation_year')
  final int graduationYear;

  // From API responses with joined data
  final String? name; // user.full_name
  final String? phone; // user.phone
  @JsonKey(name: 'group_name')
  final String? groupName; // group.name
  @JsonKey(name: 'is_active')
  final bool? isActive; // user.is_active

  // Related models (when loaded with relationships)
  final UserModel? user;
  final GroupModel? group;

  const StudentModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.parentPhone,
    required this.graduationYear,
    this.name,
    this.phone,
    this.groupName,
    this.isActive,
    this.user,
    this.group,
  });

  // Get student display name
  String get displayName {
    if (name != null) return name!;
    if (user != null) return user!.fullName;
    return 'Talaba #$id';
  }

  // Get student phone
  String get studentPhone {
    if (phone != null) return phone!;
    if (user != null) return user!.phone;
    return '';
  }

  // Get group display name
  String get groupDisplayName {
    if (groupName != null) return groupName!;
    if (group != null) return group!.name;
    return 'Guruh #$groupId';
  }

  // Check if student is active
  bool get studentIsActive {
    if (isActive != null) return isActive!;
    if (user != null) return user!.isActive;
    return true;
  }

  // Get graduation status
  String get graduationStatus {
    final currentYear = DateTime.now().year;
    if (graduationYear < currentYear) {
      return 'Bitirgan ($graduationYear)';
    } else if (graduationYear == currentYear) {
      return 'Bitiruvchi ($graduationYear)';
    } else {
      return 'Talaba ($graduationYear yilda bitiradi)';
    }
  }

  // Calculate academic year
  String get academicYear {
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    // Academic year typically starts in September
    int startYear = currentMonth >= 9 ? currentYear : currentYear - 1;
    int endYear = startYear + 1;

    return '$startYear-$endYear';
  }

  // Get years until graduation
  int get yearsUntilGraduation {
    final currentYear = DateTime.now().year;
    return graduationYear - currentYear;
  }

  // Check if about to graduate
  bool get isAboutToGraduate => yearsUntilGraduation <= 1;

  // Get parent contact info
  String get parentContact => parentPhone;

  // JSON serialization
  factory StudentModel.fromJson(Map<String, dynamic> json) => _$StudentModelFromJson(json);
  Map<String, dynamic> toJson() => _$StudentModelToJson(this);

  // Copy with method
  StudentModel copyWith({
    int? id,
    int? userId,
    int? groupId,
    String? parentPhone,
    int? graduationYear,
    String? name,
    String? phone,
    String? groupName,
    bool? isActive,
    UserModel? user,
    GroupModel? group,
  }) {
    return StudentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      parentPhone: parentPhone ?? this.parentPhone,
      graduationYear: graduationYear ?? this.graduationYear,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      groupName: groupName ?? this.groupName,
      isActive: isActive ?? this.isActive,
      user: user ?? this.user,
      group: group ?? this.group,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StudentModel(id: $id, name: $displayName, group: $groupDisplayName, graduationYear: $graduationYear)';
  }
}

// Model for child info (used in parent endpoints)
@JsonSerializable()
class ChildModel {
  final int id;
  final String name;
  @JsonKey(name: 'group_name')
  final String groupName;
  @JsonKey(name: 'graduation_year')
  final int graduationYear;

  const ChildModel({
    required this.id,
    required this.name,
    required this.groupName,
    required this.graduationYear,
  });

  // Get display info
  String get displayInfo => '$name - $groupName';

  // JSON serialization
  factory ChildModel.fromJson(Map<String, dynamic> json) => _$ChildModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChildModelToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChildModel(id: $id, name: $name, group: $groupName)';
  }
}