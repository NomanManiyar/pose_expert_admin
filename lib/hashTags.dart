import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pose_expert_admin/home.dart';

class HashTags extends StatefulWidget {
  @override
  _HashTagsState createState() => _HashTagsState();
}

class _HashTagsState extends State<HashTags> {
  List<DocumentSnapshot> hashTags = <DocumentSnapshot>[];
  TextEditingController tagController = TextEditingController();
  Firestore firestore = Firestore.instance;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedTags;
  bool isDeleting = false;
  @override
  void initState() {
    hashTag();
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
                  "Delete HashTags",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (selectedTags != null) {
                    setState(() {
                      isDeleting = true;
                    });
                      await firestore
                        .collection("hashtags")
                        .document(selectedTags)
                        .delete()
                        .then((value) {
                      print("#" + selectedTags + " is Deleted");
                      setState(() {
                        hashTag();
                        selectedTags = null;
                        isDeleting = false;
                      });

                      scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text("HashTag Deleted Successfully")));
                    });
                  } else {
                    scaffoldKey.currentState.showSnackBar(
                        SnackBar(content: Text("Atleast Select one HashTag")));
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: TextFormField(
                      controller: tagController,
                      keyboardType: TextInputType.text,
                      keyboardAppearance: Brightness.dark,
                      decoration: InputDecoration(
                          fillColor: Colors.grey,
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.vertical()),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: "Ex: Mens Poses, Mens Model, Potraits"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: MaterialButton(
                        color: Colors.black,
                        child: Text(
                          "Create HashTags",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          await firestore
                              .collection("hashtags")
                              .document(tagController.text.toUpperCase())
                              .setData({
                            "hashtag": tagController.text.toUpperCase()
                          });
                          setState(() {
                            tagController = TextEditingController();
                          });

                          scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text("HashTag Createad Successfully")));
                          scaffoldKey.currentState.reassemble();
                          setState(() {
                            hashTag();
                          });
                        }),
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
                      text: (selectedTags == null)
                          ? TextSpan(
                              text: "No ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                              children: [
                                  TextSpan(
                                    text: "#Tag ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: "Selected to DELETE")
                                ])
                          : TextSpan(
                              text: "#$selectedTags ",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              children: [
                                  TextSpan(
                                      text: "is seleted to DELETE",
                                      style: TextStyle(fontSize: 16))
                                ]),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Container(
                      child: (hashTags.length > 0)
                          ? ListView.builder(
                              itemCount: hashTags.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return CheckboxListTile(
                                  title: Text(
                                    hashTags[index].data['hashtag'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: (hashTags[index].data['hashtag'] ==
                                          selectedTags)
                                      ? true
                                      : false,
                                  onChanged: (value) => changeSelectedTag(
                                      hashTags[index]
                                          .data['hashtag']
                                          .toString()),
                                );
                              })
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                "There is no HashTah\nPlease create a Hashtag",
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

  hashTag() async {
    List<DocumentSnapshot> data = await getHashTags();

    setState(() {
      hashTags = data;
    });
    for (int i = 0; i < hashTags.length; i++) {
      print("HashTag :" + hashTags[i].data['hashtag'].toString());
    }
  }

  Future<List<DocumentSnapshot>> getHashTags() async {
    return await firestore.collection('hashtags').getDocuments().then((snaps) {
      return snaps.documents;
    });
  }

  changeSelectedTag(String hashTag) {
    if (selectedTags == hashTags) {
      setState(() {
        selectedTags = null;
      });
    } else {
      setState(() {
        selectedTags = hashTag;
        print(selectedTags);
      });
    }
  }
}
