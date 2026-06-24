import 'package:fclub/core/util/json_reader.dart';

class EmployeeProfileModel {
  const EmployeeProfileModel({
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.status,
  });

  final String name;
  final String phone;
  final String photoUrl;
  final String status;

  factory EmployeeProfileModel.fromJson(JsonMap json) {
    return EmployeeProfileModel(
      name: readString(json, 'name'),
      phone: readString(json, 'phone'),
      photoUrl: readString(json, 'photoURL'),
      status: readString(json, 'status', 'online'),
    );
  }

  JsonMap toUpdateJson() {
    return {'name': name, 'phone': phone, 'photoURL': photoUrl};
  }

  EmployeeProfileModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    String? status,
  }) {
    return EmployeeProfileModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
    );
  }
}
