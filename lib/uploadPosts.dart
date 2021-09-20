import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'home.dart';

class UploadPosts extends StatefulWidget {
  @override
  _UploadPostsState createState() => _UploadPostsState();
}

class _UploadPostsState extends State<UploadPosts> {
  Firestore firestore = Firestore.instance;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> selectedTags = <String>[];
  List<DocumentSnapshot> hashTags = <DocumentSnapshot>[];
  TextEditingController instaIdController = TextEditingController();
  TextEditingController startingIdController = TextEditingController();
  File image;

  bool isloading = false;

  String radioValue = "Boys";

  @override
  void initState() {
    super.initState();
    hashTag();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Form(
        key: formKey,
        child: isloading
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
                            TextSpan(
                              text: "No Error Detected",
                              style: TextStyle(color: Colors.black),
                            )
                          ]),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            //Select Images
                            MaterialButton(
                                color: Colors.black,
                                child: Text(
                                  "Select Images",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  selectedImage(ImagePicker.pickImage(
                                      source: ImageSource.gallery));
                                }),
                            //Upload Images
                            MaterialButton(
                                color: Colors.black,
                                child: Text(
                                  "Upload Images",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  validateAndUpload();
                                }),
                            //cancel Upload
                            MaterialButton(
                                color: Colors.black,
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  print("Cancel was tapped");
                                  Navigator.pop(context);
                                }),
                          ])),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            child: Row(children: <Widget>[
                          Radio(
                              value: "Boys",
                              groupValue: radioValue,
                              onChanged: (String value) {
                                setState(() {
                                  radioValue = value;
                                  print(radioValue);
                                });
                              }),
                          Text("Boys")
                        ])),
                        Container(
                            child: Row(children: <Widget>[
                          Radio(
                              value: "Girls",
                              groupValue: radioValue,
                              onChanged: (String value) {
                                setState(() {
                                  radioValue = value;
                                  print(radioValue);
                                });
                              }),
                          Text("Girls")
                        ])),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: (image == null)
                          ? Text(
                              "No Image is Selected",
                              textAlign: TextAlign.center,
                            )
                          : Image.file(
                              image,
                              fit: BoxFit.fitWidth,
                              height: 400,
                            ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Text(
                    "Enter an Instagram id of model",
                    style: TextStyle(fontSize: 18),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: instaIdController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                          filled: true,
                          focusColor: Colors.black,
                          fillColor: Colors.grey.withOpacity(0.2),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.vertical(),
                            borderSide: BorderSide(width: 1.5),
                          ),
                          hintText: "Ex: @xx_xx_xx",
                          labelStyle: TextStyle(color: Colors.black)),
                      validator: (value) {
                        if (!value.startsWith('@')) {
                          return "Please Enter a valid ID";
                        }
                      },
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: "#",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Tags",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            )
                          ]),
                    ),
                  ),
                  Container(
                      color: Colors.grey.shade200,
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
                                  value: selectedTags.contains(
                                      hashTags[index].data['hashtag']),
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
  }

  Future<List<DocumentSnapshot>> getHashTags() async {
    return firestore.collection('hashtags').getDocuments().then((snaps) {
      return snaps.documents;
    });
  }

  changeSelectedTag(String hashTag) {
    if (selectedTags.contains(hashTag)) {
      setState(() {
        selectedTags.remove(hashTag);
      });
    } else {
      setState(() {
        selectedTags.insert(0, hashTag);
      });
    }
  }

  selectedImage(Future<File> pickImage) async {
    File tempImg = await pickImage;

    setState(() {
      image = tempImg;
    });
  }

  validateAndUpload() async {
    if (formKey.currentState.validate()) {
      if (image != null) {
        if (selectedTags.isNotEmpty && selectedTags.length > 2) {
          setState(() {
            isloading = true;
          });
          String imageUrl;
          String imageId;
          try {
            final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
            imageId = "${DateTime.now().millisecondsSinceEpoch.toString()}";
            StorageUploadTask uploadTask =
                firebaseStorage.ref().child(imageId).putFile(image);
            await uploadTask.onComplete.then((snapshot) async {
              imageUrl = await snapshot.ref.getDownloadURL();
            });
          } catch (e) {
            print("downloadurl error: " + e.toString());
          }

          if (imageUrl != null) {
            var id = Uuid();
            String productId = id.v1();
            print("imageUrl: " + imageUrl);
            firestore
                .collection("posts")
                .document(startingIdController.text + productId)
                .setData({
              'id': (startingIdController.text + productId),
              'imageId': imageId,
              'imageURL': imageUrl,
              'instagramID': instaIdController.text,
              'hashTags': selectedTags,
              'time&date': DateTime.now().toLocal().toString(),
              'type': radioValue
            });

            formKey.currentState.reset();
            Navigator.pop(
                context,
                MaterialPageRoute(
                    builder: (context) => Home(
                          isSuccessfull: true,
                        )));
            setState(() {
              isloading = false;
            });
          } else {
            print("imageUrl is null ");
          }
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Select atleast 4 HastTags"),
          ));
        }
      } else {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Select Image"),
        ));
      }
    }
  }
}
