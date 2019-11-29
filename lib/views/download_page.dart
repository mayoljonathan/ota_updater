import 'package:flutter/material.dart';
import 'package:ota_updater/toast_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import '../dio_manager.dart';
import '../permission_manager.dart';

enum _ViewState {
  PERMISSION_NOT_GRANTED,
  DOWNLOADING_FAILED,
  DOWNLOADING,
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

class _DownloadPageState extends State<DownloadPage> with 
  WidgetsBindingObserver, SingleTickerProviderStateMixin {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isFirstInitDone = false;
  bool _isBackButtonTapped = false;

  int _receivedBytes;
  int _totalBytes;
  double _downloadedValue = 0; // 0-1
  String _downloadedFilePath;

  _ViewState _viewState = _ViewState.PERMISSION_NOT_GRANTED;

  @override
  void initState() {
    super.initState();
    _init();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (_viewState != _ViewState.DOWNLOADING) _canDownload();
    }
  }

  void _init() async {
    try {
      bool canDownload = await _canDownload();

      // Permission was not granted so show a dialog request user
      if (!canDownload) {
        bool isGranted = await _showRequestDialog();
        bool canShowDialog = await PermissionManager.canRequestDialogShow(PermissionGroup.storage);


        if (!canShowDialog && !isGranted && _isFirstInitDone) {
          ToastManager.showToast('Accept the storage permission');
          PermissionManager.openAppSettings();
        } else {
          _onPermissionNotGranted();
        }

        _isFirstInitDone = true;
      }
    } catch (e) {
      print('Catch: Permission failed: $e');
      _onPermissionNotGranted();
      _isFirstInitDone = true;
    }
  }

  // Returns true when permission granted after request
  Future<bool> _showRequestDialog() async {
    try {
      Map<PermissionGroup, PermissionStatus> results = await PermissionManager.requestPermissions([PermissionGroup.storage]);
      if (results[PermissionGroup.storage] != PermissionStatus.granted) {
        _onPermissionNotGranted();
        return false;
      }
      return true;
    } catch (e) {
      print('Catch _showRequestDialog: $e');
      _onPermissionNotGranted();
      return false;
    }
  }

  // If it can download the update then it starts to download and returns true
  Future<bool> _canDownload() async {
    try {
      PermissionStatus permissionStatus = await PermissionManager.checkPermission(PermissionGroup.storage);
      if (permissionStatus == PermissionStatus.granted) {
        _startDownload();
        return true;
      } else {
        _onPermissionNotGranted();
        return false;
      }
    } catch (e) {
      print('_canDownload: $e');
      _onPermissionNotGranted();
      return false;
    }
  }

  void _startDownload() async {
    _onDownloadStarted();

    String path = await _downloadFile(widget.downloadUrl, '${widget.filename}.apk');
    if (path == null) {
      _onDownloadFailed();
      return;
    }
    
    Future.delayed(Duration(milliseconds: 200), () => _openFile(path));
  }

  void _onPermissionNotGranted() {
    if (!mounted) return;
    if (_isFirstInitDone) {
      setState(() => _viewState = _ViewState.PERMISSION_NOT_GRANTED);
    }
  }

  void _onDownloadStarted() {
    if (!mounted) return;
    setState(() => _viewState = _ViewState.DOWNLOADING);
  }

  void _onDownloadFailed() {
    if (!mounted) return;
    setState(() => _viewState = _ViewState.DOWNLOADING_FAILED);
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
      await DioManager.downloadFile(url, fullPath, onReceiveProgress: _onReceiveProgress);

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
    if (path != null) OpenFile.open(path);
  }

  Future<bool> _onNavigateAway() async {
    if (!_isBackButtonTapped) {
      _isBackButtonTapped = true;
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Press back button again to close')
      ));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onNavigateAway,
      child: Scaffold(
        key: _scaffoldKey,
        body: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            width: 480,
            child: Center(
              child: _buildContent()
            )
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    Widget _widget = SizedBox();
    switch (_viewState) {
      case _ViewState.DOWNLOADING:
        _widget = _buildDownloadingLayout();
        break;
      case _ViewState.PERMISSION_NOT_GRANTED:
        _widget = _buildPermissionNotGrantedLayout();
        break;
      case _ViewState.DOWNLOADING_FAILED:
        _widget = _buildDownloadingFailedLayout();
        break;
    }
    return _widget;
  }

  Widget _buildPermissionNotGrantedLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Unable to download update', style: Theme.of(context).textTheme.display1.copyWith(
          color: Colors.black87
        )),
        SizedBox(height: 12),
        Text('Please accept the storage permission to download the update.'),
        SizedBox(height: 24.0),
        Center(
          child: _buildButton(
            label: 'RETRY',
            onPressed: _init
          ),
        )
      ],
    );
  }

  Widget _buildDownloadingFailedLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Download failed', style: Theme.of(context).textTheme.display1.copyWith(
          color: Colors.black87
        )),
        SizedBox(height: 12),
        Text('An error has occured in downloading the update.'),
        SizedBox(height: 24.0),
        Center(
          child: _buildButton(
            label: 'RETRY',
            onPressed: _init
          ),
        )
      ],
    );
  }

  Widget _buildDownloadingLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Center(
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: _downloadedValue == 1 ? 1 : 0,
            child: _buildButton(
              label: 'INSTALL UPDATE',
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
      width: double.infinity,
      child: RaisedButton(
        child: Text(label, style: TextStyle(
          color: Colors.white
        )),
        onPressed: onPressed,
      ),
    );
  }

}