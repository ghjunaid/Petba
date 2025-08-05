import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// import '../config.dart';

class CallApi {
  final String _url = 'https://commcop.in/petbalaravel/public/api';
  //final String _url = 'https://commcop.in/petbalaravel/public/api';
  final internet = InternetConnection();
  ConnectionResponse? connection;

  Future<http.Response?> postWithConnectionCheck(BuildContext context, {data, apiUrl}) async {
    try {
      connection = await internet.isConnected();
      if (connection!.status != "ONLINE") {
        await _showNoConnectionAlert(context);
        return null;
      }

      final fullUrl = _validateUrl(_url + apiUrl);
      debugPrint('Making POST request to: $fullUrl');
      final response = await http.post(
        Uri.parse(fullUrl),
        body: data,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response('Request Timeout', 408),
      );

      if (response.statusCode == 408) {
        debugPrint('Request timeout for: $fullUrl');
        throw TimeoutException('Request timed out');
      }
      return response;
    } on SocketException catch (e) {
      debugPrint('SocketException in post: $e');
      final message = _getSocketExceptionMessage(e);
      await _showConnectionError(context, message);
      return null;
    } on HttpException catch (e) {
      debugPrint('HttpException in post: $e');
      await _showConnectionError(context, 'HTTP error occurred. Please try again.');
      return null;
    } on FormatException catch (e) {
      debugPrint('FormatException in post: $e');
      await _showConnectionError(context, 'Invalid server response. Please contact support.');
      return null;
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException in post: ${e.message}');
      await _showConnectionError(context, 'Request timed out. Please try again.');
      return null;
    } catch (e) {
      debugPrint('Error in post: $e');
      await _showConnectionError(context, 'An unexpected error occurred. Please try again.');
      return null;
    }
  }

  Future<http.Response?> getWithConnectionCheck(apiUrl, BuildContext context) async {
    try {
      connection = await internet.isConnected();
      if (connection!.status != "ONLINE") {
        await _showNoConnectionAlert(context);
        return null;
      }

      final fullUrl = _validateUrl(_url + apiUrl);
      debugPrint('Making GET request to: $fullUrl'); // Debug log
      final response = await http.get(
        Uri.parse(fullUrl),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response('Request Timeout', 408),
      );

      if (response.statusCode == 408) {
        debugPrint('Request timeout for: $fullUrl');
        throw TimeoutException('Request timed out');
      }
      return response;
    } on SocketException catch (e) {
      debugPrint('SocketException in get: $e');
      final message = _getSocketExceptionMessage(e);
      await _showConnectionError(context, message);
      return null;
    } on HttpException catch (e) {
      debugPrint('HttpException in get: $e');
      await _showConnectionError(context, 'HTTP error occurred. Please try again.');
      return null;
    } on FormatException catch (e) {
      debugPrint('FormatException in get: $e');
      await _showConnectionError(context, 'Invalid server response. Please contact support.');
      return null;
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException in get: ${e.message}');
      await _showConnectionError(context, 'Request timed out. Please try again.');
      return null;
    } catch (e) {
      debugPrint('Error in get: $e');
      await _showConnectionError(context, 'An unexpected error occurred. Please try again.');
      return null;
    }
  }

  String _getSocketExceptionMessage(SocketException e) {
    if (e.osError?.errorCode == 7) { // No address associated with hostname
      return 'Server address not found. Please check the URL and try again.';
    } else if (e.osError?.errorCode == 8) { // Host not found
      return 'Could not find the server. Please check your internet connection.';
    } else if (e.osError?.errorCode == 110) { // Connection timed out
      return 'Connection to server timed out. Please try again.';
    }
    return 'Network error occurred. Please check your internet connection.';
  }

  ////// POST
  Future<http.Response> post(String apiUrl, {required Map<String, dynamic> data}) async {
    final fullUrl = _validateUrl(_url + apiUrl);
    debugPrint('Making POST request to: $fullUrl with body: $data');

    final response = await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data), // Should be JSON string
      headers: {'Content-Type': 'application/json'}, // Add this header
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => http.Response('Request Timeout', 408),
    );

    debugPrint('Response status: ${response.statusCode}');
    return response;
  }

////// GET
  Future<http.Response> get(apiUrl) async {
    final fullUrl = _validateUrl(_url + apiUrl);
    debugPrint('Making GET request to: $fullUrl');
    final response = await http.get(
      Uri.parse(fullUrl),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => http.Response('Request Timeout', 408),
    );

    if (response.statusCode == 408) {
      debugPrint('Request timeout for: $fullUrl');
      throw TimeoutException('Request timed out');
    }
    return response;
  }

  // String _validateUrl(String url) {
  //   if (!url.startsWith('http')) {
  //     throw FormatException('Invalid URL format: $url');
  //   }
  //   // Remove any duplicate slashes
  //   final fixedUrl = url.replaceAll(RegExp(r'/(?=/+)'), '/');
  //   return fixedUrl;
  // }

  String _validateUrl(String url) {
    // Ensure there's exactly one slash between segments
    url = url.replaceAll(RegExp(r'/+'), '/');
    url = url.replaceAll(RegExp(r'^https:/'), 'https://');
    url = url.replaceAll(RegExp(r'^http:/'), 'http://');

    if (!url.startsWith('http')) {
      throw FormatException('Invalid URL format: $url');
    }
    return url;
  }

  Future<void> _showNoConnectionAlert(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _showConnectionError(BuildContext context, String message) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class InternetConnection {
  static final InternetConnection _instance = InternetConnection._();
  factory InternetConnection() => _instance;
  InternetConnection._();

  Future<ConnectionResponse> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Connection check timed out'),
      );
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return ConnectionResponse(status: 'ONLINE');
      }
      return ConnectionResponse(status: 'OFFLINE');
    } on SocketException catch (e) {
      debugPrint('SocketException in InternetConnection check: $e');
      if (e.osError?.errorCode == 7) {
        debugPrint('DNS lookup failed - no internet connection');
      }
      return ConnectionResponse(status: 'OFFLINE');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException in InternetConnection check: ${e.message}');
      return ConnectionResponse(status: 'OFFLINE');
    } catch (e) {
      debugPrint('Error in InternetConnection check: $e');
      return ConnectionResponse(status: 'OFFLINE');
    }
  }
}

class ConnectionResponse {
  final String status;
  ConnectionResponse({required this.status});
}

class CallApiDio {
  // final String _url = 'http://$serverIp/api/';
  final String _url = 'https://commcop.in/petbalaravel/public/api';
  final internet = InternetConnection();
  final dialogStatus = DialogStatus.getInstance();

  Future<Response?> postWithConnectionCheck(data, apiUrl, BuildContext context) async {
    try {
      final connection = await internet.isConnected();
      if (connection.status != "ONLINE") {
        await _showNoConnectionAlert(context);
        return null;
      }

      final fullUrl = _validateUrl(_url + apiUrl);
      return await Dio().post(
        fullUrl,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
    } on DioException catch (e) {
      debugPrint('DioException in post: ${e.message}');
      await _showConnectionError(context, _getErrorMessage(e));
      return null;
    } catch (e) {
      debugPrint('Error in post: $e');
      await _showConnectionError(context, 'An unexpected error occurred. Please try again.');
      return null;
    }
  }

  Future<Response?> getWithConnectionCheck(apiUrl, BuildContext context) async {
    try {
      final connection = await internet.isConnected();
      if (connection.status != "ONLINE") {
        await _showNoConnectionAlert(context);
        return null;
      }

      final fullUrl = _validateUrl(_url + apiUrl);
      return await Dio().get(
        fullUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
    } on DioException catch (e) {
      debugPrint('DioException in get: ${e.message}');
      await _showConnectionError(context, _getErrorMessage(e));
      return null;
    } catch (e) {
      debugPrint('Error in get: $e');
      await _showConnectionError(context, 'An unexpected error occurred. Please try again.');
      return null;
    }
  }

  Future<Response> post(data, apiUrl) async {
    final fullUrl = _validateUrl(_url + apiUrl);
    return await Dio().post(
      fullUrl,
      data: data,
      options: Options(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<Response> get(apiUrl) async {
    final fullUrl = _validateUrl(_url + apiUrl);
    return await Dio().get(
      fullUrl,
      options: Options(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  String _validateUrl(String url) {
    if (!url.startsWith('http')) {
      throw FormatException('Invalid URL format');
    }
    return url;
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 404) {
          return 'Requested resource not found.';
        } else if (e.response?.statusCode == 500) {
          return 'Internal server error. Please try again later.';
        }
        return 'Server error occurred. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        if (e.error is SocketException) {
          final socketEx = e.error as SocketException;
          if (socketEx.osError?.errorCode == 7) {
            return 'Server address not found. Please check the URL.';
          }
        }
        return 'Failed to connect to the server. Please check your internet connection.';
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return 'Network error occurred. Please check your connection.';
        } else if (e.error is TimeoutException) {
          return 'Request timed out. Please try again.';
        }
        return 'An unexpected error occurred. Please try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> _showNoConnectionAlert(BuildContext context) async {
    if (await dialogStatus.status() == false) {
      await dialogStatus.open();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                dialogStatus.close();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showConnectionError(BuildContext context, String message) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class DialogStatus {
  final String _statusKey = 'dialog_status';
  static DialogStatus? _instance;

  static DialogStatus getInstance() => _instance ??= DialogStatus();

  Future<void> open() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_statusKey, 'open');
  }

  Future<void> close() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_statusKey);
  }

  Future<bool?> status() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_statusKey);
    return value == 'open';
  }
}