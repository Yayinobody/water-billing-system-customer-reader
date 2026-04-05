import 'package:dio/dio.dart';
import './interceptor/auth_interceptor.dart'; // Ensure correct path

class ApiService {
 static const String baseUrl = 'http://10.124.78.6:8080/api/mobile';
  // static const String baseUrl = 'https://pajamaed-arjun-phrasally.ngrok-free.dev/api/mobile';

  // Create a Dio instance
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(AuthInterceptor()); // Attach your interceptor here!

  // POST method
  static Future<Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _dio.post(endpoint, data: body);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET method
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data; // Dio automatically decodes JSON
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Exception _handleError(DioException e) {
    return Exception(e.response?.data['message'] ?? 'Connection Error');
  }
}