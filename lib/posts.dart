import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pose_expert_admin/home.dart';
import 'package:pose_expert_admin/postView.dart';

class GetPosts extends StatefulWidget {
  @override
  _GetPostsState createState() => _GetPostsState();
}

class _GetPostsState extends State<GetPosts> {
  List<DocumentSnapshot> posts = <DocumentSnapshot>[];
  TextEditingController postController = TextEditingController();
  Firestore firestore = Firestore.instance;
  StorageReference firebaseStorage = FirebaseStorage.instance.ref();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedPost;
  bool isDeleting = false;
  String imageID;

  var _error = "";

  @override
  void initState() {
    post();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: isDeleting
            ? null
            : MaterialButton(
                color: Colors.black,
                child: Text(
                  "Delete Post",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (selectedPost != null) {
                    setState(() {
                      isDeleting = true;
                    });
                    try {
                      await firebaseStorage
                          .child(imageID)
                          .delete()
                          .then((onValue) {
                        print("image Deleted ");
                      });
                      await firestore
                          .collection("posts")
                          .document(selectedPost)
                          .delete()
                          .then((value) {
                        print(selectedPost + " is Deleted");
                        setState(() {
                          post();
                          selectedPost = null;
                          isDeleting = false;
                        });

                        scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text("post Deleted Successfully")));
                      });
                    } catch (e) {
                      print("delete Error: " + e.toString());
                      setState(() {
                        _error = e.toString();
                      });
                    }
                  } else {
                    scaffoldKey.currentState.showSnackBar(
                        SnackBar(content: Text("Atleast Select one post")));
                  }
                }),
      ),
      body: SafeArea(
        child: isDeleting
            ? Center(
                child: SpinKitCubeGrid(
                  color: Colors.black,
                ),
              )
            : ListView(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.home),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => Home()));
                          }),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                        child: Text(
                          "Hi Rajendra",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: RichText(
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          text: "Error: ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            _error == null
                                ? TextSpan(
                                    text: _error,
                                    style: TextStyle(color: Colors.red),
                                  )
                                : TextSpan(
                                    text: "No Error Detected",
                                    style: TextStyle(color: Colors.black),
                                  )
                          ]),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      text: (selectedPost == null)
                          ? TextSpan(
                              text: "No ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                              children: [
                                  TextSpan(
                                    text: "Post ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: "Selected to DELETE")
                                ])
                          : TextSpan(
                              text: "$selectedPost ",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              children: [
                                  TextSpan(
                                      text: "is seleted to DELETE",
                                      style: TextStyle(fontSize: 13))
                                ]),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Container(
                      child: (posts.length > 0)
                          ? ListView.builder(
                              itemCount: posts.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PostView(
                                                  posts[index]
                                                      .data['id']
                                                      .toString(),
                                                  posts[index]
                                                      .data['instagramID']
                                                      .toString(),
                                                  posts[index]
                                                      .data['imageURL']
                                                      .toString(),
                                                  posts[index].data['hashTags'],
                                                  posts[index]
                                                      .data['time&date']
                                                      .toString(),
                                                  posts[index]
                                                      .data['type']
                                                      .toString(),
                                                )));
                                  },
                                  title: Text(
                                    posts[index].data['time&date'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Checkbox(
                                    focusColor: Colors.black,
                                    value: (posts[index].data['id'] ==
                                            selectedPost)
                                        ? true
                                        : false,
                                    onChanged: (value) => changeSelectedPost(
                                        posts[index].data['id'].toString(),
                                        posts[index]
                                            .data['imageId']
                                            .toString()),
                                  ),
                                );
                              })
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                "There is no Post Created Yet\nPlease create a post",
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(fontSize: 15),
                              ),
                            )),
                ],
              ),
      ),
    );
  }

  post() async {
    List<DocumentSnapshot> data = await getposts();
    setState(() {
      posts = data;
    });
  }

  Future<List<DocumentSnapshot>> getposts() async {
    return await firestore.collection('posts').getDocuments().then((snaps) {
      return snaps.documents;
    });
  }

  changeSelectedPost(String post, String id) {
    if (selectedPost == post) {
      setState(() {
        selectedPost = null;
        imageID = null;
      });
    } else {
      setState(() {
        selectedPost = post;
        imageID = id;
        print(selectedPost);
        print(imageID);
      });
    }
  }
}
