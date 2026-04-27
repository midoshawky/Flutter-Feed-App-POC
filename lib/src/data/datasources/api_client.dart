import 'package:dio/dio.dart';

const String _baseUrl = 'https://dev-backend-shuwier.pomac.info';

class ApiClient {
  final Dio _dio;

  ApiClient({required String? Function() tokenProvider})
      : _dio = Dio(BaseOptions(baseUrl: _baseUrl)) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = tokenProvider();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;
}
