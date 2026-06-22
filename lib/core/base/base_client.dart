// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fclub/core/constants/my_api_url.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/error/api_exception.dart';
import 'package:fclub/core/services/global_service.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:logger/logger.dart';

class BaseClient {
  static final dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 3)))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['authorized'] == true) {
            final firebaseUser = FirebaseAuth.instance.currentUser;
            final token =
                await firebaseUser?.getIdToken() ??
                GlobalService.instance.idToken;

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
      ),
    );
  static final Logger _logger = Logger();

  static Map<String, String> get header => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (GlobalService.instance.idToken != null &&
        GlobalService.instance.idToken!.isNotEmpty)
      'Authorization': 'Bearer ${GlobalService.instance.idToken}',
  };
  static void _logResponse(String method, Response<dynamic> response) {
    _logger.t(
      '$method ${response.requestOptions.uri}\n'
      'Status: ${response.statusCode}\n'
      'Response: ${response.data}',
    );
  }

  static void _logDioError(String method, DioException e) {
    _logger.e(
      '$method ${e.requestOptions.uri}\n'
      'Error: ${e.message}\n'
      'Status: ${e.response?.statusCode}\n'
      'Error response: ${e.response?.data}',
    );
  }

  static Future<dynamic> getData({
    required String endPoint,
    Object? body,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");
      final response = await dio.get(
        url,
        queryParameters: parameters,
        data: body ?? jsonEncode({}),
        options: options ?? Options(headers: header),
      );
      _logResponse('GET', response);
      if (response.statusCode == 200) return response.data;
      MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
    } on DioException catch (e) {
      _logDioError('GET', e);
      ApiException.handleException(e, ctx);
    } catch (e) {
      _logger.e(e);
      MyDialog().showFailedToast(
        title: "Unexpected Error!",
        msg: e.toString(),
        context: ctx,
      );
    }
  }

  static Future<dynamic> postData({
    required String endPoint,
    Object? body,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
    bool showError = true,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");
      final response = await dio.post(
        url,
        queryParameters: parameters,
        data: body ?? jsonEncode({}),
        options: options ?? Options(headers: header),
      );
      _logResponse('POST', response);
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        return response.data;
      }
      if (showError) {
        MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
      }
    } on DioException catch (e) {
      _logDioError('POST', e);
      if (showError) {
        ApiException.handleException(e, ctx);
      }
    } catch (e) {
      _logger.e(e);
      if (showError) {
        MyDialog().showFailedToast(
          title: "Unexpected Error!",
          msg: e.toString(),
          context: ctx,
        );
      }
    }
  }

  static Future<dynamic> postMultipartFile({
    required String endPoint,
    required String filePath,
    String fileField = 'file',
    Map<String, dynamic>? fields,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
    bool showError = true,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");

      final formData = FormData.fromMap({
        ...?fields,
        fileField: await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final resolvedHeaders = <String, dynamic>{
        ...((options?.headers) ?? header),
        'Content-Type': 'multipart/form-data',
      };

      final resolvedOptions = (options ?? Options()).copyWith(
        headers: resolvedHeaders,
      );

      final response = await dio.post(
        url,
        queryParameters: parameters,
        data: formData,
        options: resolvedOptions,
      );
      _logResponse('POST-MULTIPART', response);

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        return response.data;
      }

      if (showError) {
        MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
      }
    } on DioException catch (e) {
      _logDioError('POST-MULTIPART', e);
      if (showError) {
        ApiException.handleException(e, ctx);
      }
    } catch (e) {
      _logger.e(e);
      if (showError) {
        MyDialog().showFailedToast(
          title: "Unexpected Error!",
          msg: e.toString(),
          context: ctx,
        );
      }
    }
  }

  static Future<dynamic> patchData({
    required String endPoint,
    Object? body,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");
      final response = await dio.patch(
        url,
        queryParameters: parameters,
        data: body ?? jsonEncode({}),
        options: options ?? Options(headers: header),
      );
      _logResponse('PATCH', response);
      if (response.statusCode == 200) return response.data;
      MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
    } on DioException catch (e) {
      _logDioError('PATCH', e);
      ApiException.handleException(e, ctx);
    } catch (e) {
      _logger.e(e);
      MyDialog().showFailedToast(
        title: "Unexpected Error!",
        msg: e.toString(),
        context: ctx,
      );
    }
  }

  static Future<dynamic> putData({
    required String endPoint,
    Object? body,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");
      final response = await dio.put(
        url,
        queryParameters: parameters,
        data: body ?? jsonEncode({}),
        options: options ?? Options(headers: header),
      );
      _logResponse('PUT', response);
      if (response.statusCode == 200) return response.data;
      MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
    } on DioException catch (e) {
      _logDioError('PUT', e);
      ApiException.handleException(e, ctx);
    } catch (e) {
      _logger.e(e);
      MyDialog().showFailedToast(
        title: "Unexpected Error!",
        msg: e.toString(),
        context: ctx,
      );
    }
  }

  static Future<dynamic> deleteData({
    required String endPoint,
    Object? body,
    Map<String, dynamic>? parameters,
    Options? options,
    required BuildContext ctx,
  }) async {
    try {
      final url = "${MyApiUrl.baseUrl}/${MyApiUrl.version}/$endPoint";
      _logger.i("$url/$parameters");
      final response = await dio.delete(
        url,
        queryParameters: parameters,
        data: body ?? jsonEncode({}),
        options: options ?? Options(headers: header),
      );
      _logResponse('DELETE', response);
      if (response.statusCode == 200) return response.data;
      MyDialog().showFailedToast(msg: MyString.errorMsg, context: ctx);
    } on DioException catch (e) {
      _logDioError('DELETE', e);
      ApiException.handleException(e, ctx);
    } catch (e) {
      _logger.e(e);
      MyDialog().showFailedToast(
        title: "Unexpected Error!",
        msg: e.toString(),
        context: ctx,
      );
    }
  }
}
