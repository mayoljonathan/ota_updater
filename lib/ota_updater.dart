library ota_updater;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_manager.dart';
import 'device_manager.dart';
import 'models/update_response.dart';
import 'views/download_page.dart';

// enum UpdateStatus {
//   /// The application is up to date.
//   UP_TO_DATE,

//   /// There is a new update available
//   UPDATE_AVAILABLE,

//   /// The update package is about to be downloaded.
//   DOWNLOADING_UPDATE,

//   /// The update package is about to be installed.
//   INSTALLING_UPDATE,

//   /// The update packages is already installed
//   UPDATE_INSTALLED,

//   /// An error has occured in downloading, or communicating to the server
//   ERROR
// }

// enum AppUpdateStatus {
//   /// The application is up to date.
//   UP_TO_DATE,

//   /// There is a new update available
//   UPDATE_AVAILABLE,

//   /// An error has occured in communicating to the server
//   ERROR
// }

// class UpdateResponse {
//   AppUpdateStatus status;
//   String message;
//   Map<String, dynamic> data;
// }

class DownloadProgress {
  double totalBytes;
  double receivedBytes;

  DownloadProgress({
    this.totalBytes,
    this.receivedBytes
  });
}

class UpdateStatusProgress {
  // UpdateStatus status;
  String message;

  UpdateStatusProgress({
    // this.status,
    this.message
  });
}

class OTAPayload {
  String appKey;
  String versionCode;
  String versionName;
  String deviceInfo;

  OTAPayload({
    @required this.appKey,
    @required this.versionCode,
    @required this.versionName,
    @required this.deviceInfo
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'appKey': this.appKey,
    'versionCode': this.versionCode,
    'versionName': this.versionName,
    'deviceInfo': this.deviceInfo
  };
}

class OTAUpdater {

  // StreamController<DownloadProgress> _downloadProgressStream = StreamController();
  // StreamController<UpdateStatusProgress> _updateStatusStream = StreamController();

  void checkForUpdate(BuildContext context, {
    @required String url,
    @required String appKey,
  }
    // {
    //   StreamController<DownloadProgress> downloadProgressStream,
    //   StreamController<UpdateStatusProgress> updateStatusStream
    // }
  ) async {

    final deviceInfo = await DeviceManager().getDeviceInfo();
    final deviceInfoAsJson = jsonEncode(deviceInfo);
    Version versions = await AppManager().getVersions();

    final payload = OTAPayload(
      appKey: appKey,
      versionCode: versions.versionCode,
      versionName: versions.versionName,
      deviceInfo: deviceInfoAsJson
    );

    http.Response response = await http.post(url, body: payload.toJson());
    Map<String, dynamic> json = jsonDecode(response.body);
    UpdateResponse updateResponse = UpdateResponse.fromJson(json);

    switch(updateResponse.status) {
      case AppUpdateStatus.UP_TO_DATE:
        print('uptodate');
        break;
      case AppUpdateStatus.UPDATE_AVAILABLE:
        _onUpdateAvailable(context, updateResponse);
        break;
      case AppUpdateStatus.ERROR:
        _onError(context, updateResponse);
        break;
    }

  }

  void _onUpdateAvailable(BuildContext context, UpdateResponse response) async {
    bool result = await showDialog<bool>(
      context: context,
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

    if (result != null && result) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DownloadPage(
          filename: response.data.filename,
          downloadUrl: response.data.downloadUrl,
        )
      ));
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
