import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../app_manager.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({
    @required this.downloadUrl,
    @required this.filename
  });

  final String downloadUrl;
  final String filename;

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {

  double receivedBytes;
  double totalBytes;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _init() async {
    String path = await _downloadFile(widget.downloadUrl, '${widget.filename}.apk');
    _openFile(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Center(
            child: _buildContent()
          )
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Downloading', style: Theme.of(context).textTheme.display1.copyWith(
          color: Colors.black87
        )),
        SizedBox(height: 12.0),
        _buildProgressBar(),
        // Text(fileSize.toString()),
        // Text(downloadProgress.toString())
      ],
    );
  }

  Widget _buildProgressBar() {
    double value = 0;

    if (receivedBytes != null && totalBytes != null) {
      value = receivedBytes / totalBytes;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6.0),
      child: SizedBox(
        height: 18,
        child: LinearProgressIndicator(value: value)
      )
    );
  }

  Future<String> _downloadFile(String url, String filename) async {
    http.Client client = new http.Client();
    var req = await client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    String dir = (await getApplicationDocumentsDirectory()).path;
    String fullPath = '$dir/$filename';
    File file = new File(fullPath);
    await file.writeAsBytes(bytes);
    return fullPath;
  }

  void _openFile(String path) {
    OpenFile.open(path);
  }
}