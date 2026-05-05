import 'package:dio/dio.dart';
import 'secure_storage.dart';
import '../api.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check for expired JWT
    if (err.response?.statusCode == 401 && err.response?.data['message'] == 'expired JWT token') {
      try {
        final refreshToken = await TokenStorage.getRefreshToken();
        if (refreshToken == null) throw Exception('No refresh token available');

        // Request new access token
        final dio = Dio();
        final response = await dio.post(
          '${ApiService.baseUrl}/refresh-token',
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = response.data['accessToken'] as String;
        await TokenStorage.saveToken(newAccessToken);

        // Retry the original request with new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        final cloneReq = await dio.fetch(opts);
        return handler.resolve(cloneReq);
      } catch (_) {
        // If refresh fails → user must re-login
        print("Refresh failed, redirect to login");
      }
    }

    handler.next(err);
  }
}