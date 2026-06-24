import 'package:flutter/material.dart';
import 'package:fclub/core/base/api_request_options.dart';
import 'package:fclub/core/base/base_client.dart';
import 'package:fclub/core/constants/my_api_url.dart';
import 'package:fclub/core/util/json_reader.dart';
import 'package:fclub/feature/settings/data/model/employee_profile_model.dart';

class ProfileRepository {
  Future<EmployeeProfileModel> updateEmployee(
    BuildContext context, {
    required String uid,
    required String name,
    required String phone,
    required String photoUrl,
  }) async {
    final response = await BaseClient.patchData(
      endPoint: MyApiUrl.updateEmployee(uid),
      body: {'name': name, 'phone': phone, 'photoURL': photoUrl},
      ctx: context,
      options: ApiRequestOptions.authorized(),
    );

    if (response is! Map) {
      throw Exception('Unable to update profile.');
    }

    final responseMap = JsonMap.from(response);

    if (responseMap.containsKey('success') &&
        !readBool(responseMap, 'success')) {
      throw Exception('Unable to update profile.');
    }

    final profileData = _resolveProfileData(responseMap);
    if (profileData.isEmpty) {
      throw Exception('Unable to update profile.');
    }

    return EmployeeProfileModel.fromJson(profileData);
  }

  JsonMap _resolveProfileData(JsonMap responseMap) {
    final data = readMap(responseMap, 'data');
    if (data.isNotEmpty) {
      return data;
    }

    final profile = readMap(responseMap, 'profile');
    if (profile.isNotEmpty) {
      return profile;
    }

    if (responseMap.containsKey('name') ||
        responseMap.containsKey('phone') ||
        responseMap.containsKey('photoURL')) {
      return responseMap;
    }

    return {};
  }
}
