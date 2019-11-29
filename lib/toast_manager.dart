import 'package:fluttertoast/fluttertoast.dart';

class ToastManager {
  static final ToastManager _instance = ToastManager._internal();
  factory ToastManager() => _instance;
  ToastManager._internal();

  static void showToast(String message, [
    ToastGravity gravity = ToastGravity.BOTTOM
  ]){
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIos: 3,
    );
  }
}