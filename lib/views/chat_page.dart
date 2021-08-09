import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shelf/services/database_service.dart';
import 'package:shelf/widgets/message_tile.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String channelId;
  final String userName;
  final String channelName;
  final bool readonly;

  ChatPage({this.groupId, this.channelId, this.userName, this.channelName, this.readonly});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot> _chats;
  TextEditingController messageEditingController = new TextEditingController();

  Widget _chatMessages() {
    return StreamBuilder(
      stream: _chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 70),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  return Column(children: [
                    MessageTile(
                        message: snapshot.data.docs[index].data()["message"],
                        imgurl: snapshot.data.docs[index].data()["imageurl"],
                        fileurl: snapshot.data.docs[index].data()["fileurl"],
                        img:
                            snapshot.data.docs[index].data()["imageurl"] != null
                                ? true
                                : false,
                        file:
                            snapshot.data.docs[index].data()["fileurl"] != null
                                ? true
                                : false,
                        sender: snapshot.data.docs[index].data()["sender"],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index].data()["sender"],
                        time: snapshot.data.docs[index].data()["time"]),
                    Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                snapshot.data.docs[index].data()["time"])),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      margin: EdgeInsets.only(
                          left: widget.userName ==
                                  snapshot.data.docs[index].data()["sender"]
                              ? 280.0
                              : 0.0,
                          right: widget.userName ==
                                  snapshot.data.docs[index].data()["sender"]
                              ? 0.0
                              : 280.0,
                          top: 5.0,
                          bottom: 5.0),
                    )
                  ]);
                })
            : Container();
      },
    );
  }

  _sendMessage({fileurl, bool img, bool file}) {
    Map<String, dynamic> chatMessageMap;
    if (img) {
      chatMessageMap = {
        "message": null,
        "sender": widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
        'imageurl': fileurl,
        'fileurl': null
      };
    } else if (file) {
      chatMessageMap = {
        "message": null,
        "sender": widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
        'imageurl': null,
        'fileurl': fileurl
      };
    } else if (messageEditingController.text.isNotEmpty) {
      chatMessageMap = {
        "message": messageEditingController.text,
        "sender": widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
        'imageurl': null,
        'fileurl': null
      };
    }

    DatabaseService()
        .sendMessage(widget.groupId, widget.channelId, chatMessageMap);

    setState(() {
      messageEditingController.text = "";
    });
  }

  _sendAttachment(file, filetype) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    String url = await DatabaseService().sendAttachment(file, filetype, time);

    if (filetype == FileType.image) {
      _sendMessage(fileurl: url, img: true, file: false);
    } else {
      _sendMessage(fileurl: url, img: false, file: true);
    }
  }

  _showAttachmentBottomSheet(context) {
    showModalBottomSheet<Null>(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Colors.white,
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Image'),
                    onTap: () => _showFilePicker(FileType.image)),
                ListTile(
                  leading: Icon(Icons.insert_drive_file),
                  title: Text('File'),
                  onTap: () => _showFilePicker(FileType.any),
                ),
              ],
            ),
          );
        });
  }

  _showFilePicker(FileType fileType) async {
    File file;
    final picker = ImagePicker();

    if (fileType == FileType.image) {
      PickedFile pickedImg =
          await picker.getImage(source: ImageSource.gallery); //imageQuality: 70
      if (pickedImg == null) return;
      setState(() {
        file = File(pickedImg.path);
      });
    } else {
      FilePickerResult pickedFile =
          await FilePicker.platform.pickFiles(type: FileType.any);
      if (pickedFile == null) return;
      file = File(pickedFile.files.single.path) != null
          ? File(pickedFile.files.single.path)
          : null;
    }

    if (file == null) {
      print('No file selected.');
      return;
    } else
      _sendAttachment(file, fileType);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blueAccent,
      duration: Duration(milliseconds: 1500),
      content: Text('Sending attachment...', style: TextStyle(fontSize: 17)),
    ));
  }

  @override
  void initState() {
    super.initState();
    DatabaseService().getChats(widget.groupId, widget.channelId).then((val) {
      setState(() {
        _chats = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.channelName, style: TextStyle(color: Colors.black)),
        centerTitle: true,
      backgroundColor: Colors.grey[100],
        elevation: 0.0,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            _chatMessages(),
            // Container(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                color: Colors.white.withOpacity(0.6),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        _showAttachmentBottomSheet(context);
                      },
                      child: Container(
                        height: 40.0,
                        width: 20.0,
                        child: Center(
                            child: Icon(
                          Icons.attach_file,
                          color: Colors.grey[600],
                          size: 30,
                        )),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Expanded(
                      child: TextField(
                        controller: messageEditingController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintText: "Type a message",
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    GestureDetector(
                      onTap: () {
                        _sendMessage(fileurl: null, img: false, file: false);
                      },
                      child: Container(
                        height: 40.0,
                        width: 40.0,
                        child: Center(
                            child: Icon(
                          Icons.send,
                          color: Colors.blue[500],
                          size: 30,
                        )),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
