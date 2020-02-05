library ota_updater;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'app_manager.dart';
import 'device_manager.dart';
import 'models/ota_payload.dart';
import 'models/update_response.dart';
import 'views/download_page.dart';

class UResponse {
  AppUpdateStatus status;
  String message;

  UResponse({
    this.status,
    this.message
  });
}

class OTAUpdater {

  Future<UResponse> checkForUpdate(BuildContext context, {
    @required String url,
    @required String appKey,
    bool shouldRemoveAllRoutes = true
  }) async {

    final deviceInfo = await DeviceManager.getDeviceInfo();
    final deviceInfoAsJson = jsonEncode(deviceInfo);
    Version versions = await AppManager.getVersions();

    final payload = OTAPayload(
      appKey: appKey,
      versionCode: versions.versionCode,
      versionName: versions.versionName,
      deviceInfo: deviceInfoAsJson
    );

    try {
      Response response = await Dio().post(url, data: payload.toJson());
      UpdateResponse updateResponse = UpdateResponse.fromJson(response.data);

      switch(updateResponse.status) {
        case AppUpdateStatus.UP_TO_DATE:
          return UResponse(
            status: AppUpdateStatus.UP_TO_DATE,
            message: updateResponse.message
          );
          break;
        case AppUpdateStatus.UPDATE_AVAILABLE:
          _onUpdateAvailable(context, updateResponse, shouldRemoveAllRoutes);
          return UResponse(
            status: AppUpdateStatus.UPDATE_AVAILABLE,
            message: updateResponse.message
          );
          break;
        case AppUpdateStatus.ERROR:
          _onError(context, updateResponse);
          return UResponse(
            status: AppUpdateStatus.ERROR,
            message: updateResponse.message
          );
          break;
      }
    } catch (e) {
      return UResponse(
        status: AppUpdateStatus.ERROR,
        message: e.toString()
      );
    }
    return null;
  }

  void _onUpdateAvailable(BuildContext context, UpdateResponse response, bool shouldRemoveAllRoutes) async {
    bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: response.data.isMandatory,
      builder: (_) {
        return AlertDialog(
          title: Text(response.title),
          content: Text(response.message),
          actions: <Widget>[
            if (!response.data.isMandatory) FlatButton(
              child: Text('MAYBE LATER'),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text(response.data.isMandatory ? 'CONTINUE' : 'DOWNLOAD'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      }
    );

    if (response.data.isMandatory || (result != null && result)) {
      final downloadRoute = MaterialPageRoute(
        builder: (context) => DownloadPage(
          filename: response.data.filename,
          downloadUrl: response.data.downloadUrl,
        )
      );

      if (shouldRemoveAllRoutes) {
        Navigator.of(context).pushAndRemoveUntil(downloadRoute, (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushReplacement(downloadRoute);
      }
    }
  }

  void _onError(BuildContext context, UpdateResponse response) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(response.title ?? ''),
          content: Text(response.message),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }
    );
  }
}
