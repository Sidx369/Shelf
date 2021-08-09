import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  Future updateUserData(String userName, String email, String password) async {
    return await userCollection.doc(uid).set({
      'username': userName,
      'email': email,
      'password': password,
      'groups': [],
      'profilePic': ''
    });
  }

  Future createGroup(String userName, String groupName, String description,
      String code) async {
    DocumentReference groupDocRef = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'admin': userName,
      'description': description,
      'code': code,
      'members': [],
      'channels': [],
      'groupId': '',
    });

    await groupDocRef.update({
      'members': FieldValue.arrayUnion([uid + '_' + userName]),
      'groupId': groupDocRef.id,
    });

    DocumentReference userDocRef = userCollection.doc(uid);
    return await userDocRef.update({
      'groups': FieldValue.arrayUnion([groupDocRef.id + '_' + groupName])
    });
  }

  Future createChannel(
      {String userName,
      String channelName,
      String groupId,
      String description,
      bool readonly}) async {
    final CollectionReference channelCollection =
        groupCollection.doc(groupId).collection('channels');
    DocumentReference channelDocRef = await channelCollection.add({
      'channelName': channelName,
      'channelIcon': '',
      'description': description,
      'readonly': readonly,
      'admin': userName,
      //'messages': ,
      'channelId': '',
      'recentMessage': '',
      'recentMessageSender': ''
    });

    await channelDocRef.update({
      'channelId': channelDocRef.id,
    });

    DocumentReference groupDocRef = groupCollection.doc(groupId);
    await groupDocRef.update({
      'channels': FieldValue.arrayUnion([channelDocRef.id + '_' + channelName])
    });
  }

  // toggling the user group join
  Future togglingGroupJoin(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    DocumentReference groupDocRef = groupCollection.doc(groupId);

    List<dynamic> groups = await userDocSnapshot['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      await userDocRef.update({
        'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayRemove([groupId + '_' + groupName])
      });
    } else {
      await userDocRef.update({
        'groups': FieldValue.arrayUnion([groupId + '_' + groupName])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayUnion([uid + '_' + userName])
      });
    }
  }

  Future<bool> isUserJoined(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    List<dynamic> groups = await userDocSnapshot['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      return true;
    } else {
      return false;
    }
  }

  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    print(snapshot.docs[0].data);
    return snapshot;
  }

  getUserGroups() async {
    return FirebaseFirestore.instance.collection("users").doc(uid).snapshots();
  }

  getGroupDetail(groupId) async {
     return FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .snapshots();
  }

  getChannelDetail(groupId, channelId) async {
    print("getchanneldetail groupid, channelid: $groupId, $channelId");
    return FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .collection("channels")
        .doc(channelId)
        .snapshots();
  }

  sendMessage(String groupId, String channelId, chatMessageData) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .add(chatMessageData);

    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('channels')
        .doc(channelId)
        .update({
      'recentMessage': chatMessageData['messsage'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }

  sendAttachment(file, filetype, int time) async {
    Reference reference;
    String fileName = basename(file.path);

    if (filetype == FileType.image) {
      reference =
          FirebaseStorage.instance.ref().child('images/$time\_$fileName');
    } else {
      reference =
          FirebaseStorage.instance.ref().child('files/$time\_$fileName');
    }

    //String uploadPath = await reference.getPath();
    //print('uploading to $uploadPath');
    //print(reference);
    UploadTask uploadTask = reference.putFile(file);
    var fileUrl = await (await uploadTask).ref.getDownloadURL();
    String url = fileUrl.toString();
    print("Url: $url");
    return url;
  }

  getChats(String groupId, String channelId) async {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  searchByCode(String code) {
    return FirebaseFirestore.instance
        .collection('groups')
        .where('code', isEqualTo: code)
        .get();
  }

  void deleteGroup(groupId, members) {
    FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
    print("groupId: $groupId");
    if(members == null){
      print("members returned null");
      print("members: $members");}

    // remove the {groupId} element from group field array from each {members} user document
    return members.forEach(
      (currentUserId) {
        DocumentReference userDocRef = userCollection
            .doc(currentUserId.substring(0, currentUserId.lastIndexOf('_')));
        userDocRef.update(
          {'groups': FieldValue.arrayRemove(groupId)},
        );
      },
    );
  }
}
