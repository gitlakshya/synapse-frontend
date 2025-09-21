import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late http.Client _client;
  static const Duration _timeout = Duration(seconds: 120);
  static const Duration _connectionTimeout = Duration(seconds: 30);

  void initialize() {
    _client = http.Client();
  }

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await _makeRequest(() => _client.get(uri, headers: _addCorsHeaders(headers)));
  }

  Future<http.Response> post(String endpoint, {Map<String, String>? headers, String? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await _makeRequest(() => _client.post(uri, headers: _addCorsHeaders(headers), body: body));
  }

  Future<http.Response> put(String endpoint, {Map<String, String>? headers, String? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await _makeRequest(() => _client.put(uri, headers: _addCorsHeaders(headers), body: body));
  }

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await _makeRequest(() => _client.delete(uri, headers: _addCorsHeaders(headers)));
  }

  Future<http.Response> _makeRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      _logResponse(response);
      return response;
    } catch (e) {
      _logError(e);
      rethrow;
    }
  }

  Map<String, String> _addCorsHeaders(Map<String, String>? headers) {
    final corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, X-Requested-With',
      ...ApiConfig.headers,
    };
    
    if (headers != null) {
      corsHeaders.addAll(headers);
    }
    
    return corsHeaders;
  }

  void _logResponse(http.Response response) {
    print('HTTP ${response.request?.method} ${response.request?.url}');
    print('Status: ${response.statusCode}');
    if (response.statusCode >= 400) {
      print('Error Body: ${response.body}');
    }
  }

  void _logError(dynamic error) {
    print('HTTP Error: $error');
  }

  void dispose() {
    _client.close();
  }
}