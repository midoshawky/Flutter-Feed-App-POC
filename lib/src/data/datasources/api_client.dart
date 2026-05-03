import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const String _baseUrl = 'https://dev-backend-shuwier.pomac.info';

class ApiClient {
  final Dio _dio;

  ApiClient({required String? Function() tokenProvider})
      : _dio = Dio(BaseOptions(
          baseUrl: kIsWeb ? '' : _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenProvider();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
