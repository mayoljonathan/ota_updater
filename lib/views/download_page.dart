import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import '../dio_manager.dart';
import '../permission_manager.dart';

enum ViewState {
  DOWNLOADING,
  PERMISSION_NOT_GRANTED
}

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

  int _receivedBytes;
  int _totalBytes;
  double _downloadedValue = 0; // 0-1
  String _downloadedFilePath;

  ViewState _viewState = ViewState.DOWNLOADING;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    var results = await PermissionManager().requestPermissions([PermissionGroup.storage]);
    if (results[PermissionGroup.storage] != PermissionStatus.granted) {
      if (!mounted) return;
      setState(() => _viewState = ViewState.PERMISSION_NOT_GRANTED);
      return;
    }

    if (!mounted) return;
    setState(() => _viewState = ViewState.DOWNLOADING);
    String path = await _downloadFile(widget.downloadUrl, '${widget.filename}.apk');
    Future.delayed(Duration(milliseconds: 200), () => _openFile(path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          width: 480,
          child: Center(
            child: _buildContent()
          )
        ),
      ),
    );
  }

  Widget _buildContent() {
    Widget _widget = Container();
    switch (_viewState) {
      case ViewState.DOWNLOADING:
        _widget = _buildDownloadingLayout();
        break;
      case ViewState.PERMISSION_NOT_GRANTED:
        _widget = _buildPermissionNotGrantedLayout();
        break;
    }
    return _widget;
  }

  Widget _buildPermissionNotGrantedLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Unable to download update', style: Theme.of(context).textTheme.display1.copyWith(
          color: Colors.black87
        )),
        SizedBox(height: 12),
        Text('Please accept the storage permission to download the update.'),
        SizedBox(height: 24.0),
        _buildButton(
          label: 'RETRY',
          onPressed: _init
        )
      ],
    );
  }

  Widget _buildDownloadingLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(_downloadedValue == 1 ? 'Downloaded' : 'Downloading', style: Theme.of(context).textTheme.display1.copyWith(
                  color: Colors.black87
                )),
                _buildProgressText(),
              ],
            ),
            SizedBox(height: 6.0),
            _buildProgressBar(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 18.0),
          child: _buildHelperNote()
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: _downloadedValue == 1 ? 1 : 0,
            child: _buildButton(
              label: 'Install Update',
              onPressed: () => _openFile(_downloadedFilePath)
            )
          ),
        ),
      ],
    );
  }

  Widget _buildHelperNote() {
    return Text('Once you have installed the update, please restart the app.', style: TextStyle(
      color: Theme.of(context).textTheme.caption.color
    ));
  }

  Widget _buildProgressBar() {
    if (_receivedBytes != null && _totalBytes != null) {
      _downloadedValue = _receivedBytes / _totalBytes;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(3.0),
      child: SizedBox(
        height: 12,
        child: LinearProgressIndicator(value: _downloadedValue)
      )
    );
  }

  Widget _buildProgressText() {
    String percentage;
    if (_downloadedValue != null) percentage = (_downloadedValue * 100).toStringAsFixed(0);

    return Opacity(
      opacity: (_receivedBytes == null || _totalBytes == null) ? 0 : 1,
      child: Text('$percentage%', textAlign: TextAlign.end, style: Theme.of(context).textTheme.title),
    );
  }

  Widget _buildButton({String label, VoidCallback onPressed}) {
    return SizedBox(
      height: 44,
      child: RaisedButton(
        child: Text(label, style: TextStyle(
          fontSize: 16.0
        )),
        onPressed: onPressed,
      ),
    );
  }


  Future<String> _downloadFile(String url, String filename) async {
    _onReceiveProgress(int receivedBytes, int totalBytes) {
      if (!mounted) return;
      setState(() {
        _receivedBytes = receivedBytes; 
        _totalBytes = totalBytes;
      });
    }

    try {
      String dir = (await getExternalStorageDirectory()).path;
      String fullPath = '$dir/$filename';
      await DioManager().downloadFile(url, fullPath, onReceiveProgress: _onReceiveProgress);

      if (!mounted) return null;
      setState(() {
        _downloadedFilePath = fullPath;
        _downloadedValue = 1;
      });
      return fullPath;
    } catch (e) {
      print('Catch e: $e');
      return null;
    }
  }

  void _openFile(String path) {
    print(path);
    if (path != null) OpenFile.open(path);
  }
}