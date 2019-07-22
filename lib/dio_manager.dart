import 'package:dio/dio.dart';

class DioManager {
  static final DioManager _instance = DioManager._internal();
  factory DioManager() => _instance;
  DioManager._internal();

  Future<Response<dynamic>> downloadFile(String url, String path, {
    Function(int, int) onReceiveProgress    
  }) async {
    return Dio().download(url, path, onReceiveProgress: onReceiveProgress);
  }
}