import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'dart:isolate';

//import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shelf/widgets/image_fullscreen.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String imgurl;
  final String fileurl;
  bool img = false;
  bool file = false;
  final String sender;
  final bool sentByMe;
  final int time;

  MessageTile(
      {this.message,
      this.imgurl,
      this.fileurl,
      this.img,
      this.file,
      this.sender,
      this.sentByMe,
      this.time});

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _permissionReady = false;
  String _localPath;

  @override
  void initState() {
    super.initState();

    FlutterDownloader.registerCallback(downloadCallback);

    _permissionReady = false;
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  void _downloadFile(String fileUrl) async {
    _localPath =
        (await _findLocalPath()); // + Platform.pathSeparator + 'Download';

    //final Directory downloadsDirectory =
    // _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    //    await DownloadsPathProvider.downloadsDirectory;
    //final String downloadsPath = await DownloadsPathProvider.downloadsDirectory;

    print("DownloadsPath: $_localPath");
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    await FlutterDownloader.enqueue(
      url: fileUrl,
      savedDir: _localPath,
      showNotification: true, // show download progress in status bar
      openFileFromNotification:
          true, // click on notification to open downloaded file
    );
    //FlutterDownloader.open(taskId: taskId);
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }

    return false;
  }

  Widget _buildNoPermissionWarning() => Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Please grant accessing storage permission to continue -_-',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              FlatButton(
                  onPressed: () {
                    _checkPermission().then((hasGranted) {
                      setState(() {
                        _permissionReady = hasGranted;
                      });
                    });
                  },
                  child: Text(
                    'Retry',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ))
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: widget.sentByMe
            ? EdgeInsets.only(top: 0, bottom: 16, left: 16, right: 16)
            : EdgeInsets.only(top: 10, bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: widget.sentByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: widget.sentByMe
                      ? Radius.circular(22)
                      : Radius.circular(7))
              : BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: widget.sentByMe
                      ? Radius.circular(7)
                      : Radius.circular(27),
                ),
          color: widget.sentByMe ? Colors.blue[500] : Color(0xff7acbcd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 0.0),
            Text(widget.sentByMe ? '' : widget.sender,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.4)),
            SizedBox(height: 3.0),
            new Container(
              margin: const EdgeInsets.only(top: 0.0),
              child: widget.img != false
                  ? new GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ImageFullScreen(widget.imgurl)));
                      },
                      child: FadeInImage.assetNetwork(
                        image: widget.imgurl,
                        placeholder: 'assets/placeholder1.png',
                        width: 250.0,
                      ))
                  : widget.file != false
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Stack(
                                alignment: AlignmentDirectional.center,
                                children: <Widget>[
                                  Container(
                                    width: 75,
                                    height: 60,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text('File',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      Container(
                                          height: 50,
                                          child: IconButton(
                                              icon: Icon(
                                                CupertinoIcons
                                                    .arrow_down_doc_fill,
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                              onPressed: () =>
                                                  _checkPermission()
                                                      .then((hasGranted) {
                                                    setState(
                                                      () {
                                                        _permissionReady =
                                                            hasGranted;
                                                      },
                                                    );
                                                    _permissionReady
                                                        ? _downloadFile(
                                                            widget.fileurl)
                                                        : _buildNoPermissionWarning();
                                                  })))
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : new Text(widget.message,
                          textAlign: TextAlign.start,
                          style:
                              TextStyle(fontSize: 17.0, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
