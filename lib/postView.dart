import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class PostView extends StatefulWidget {
  final String id;
  final String instagramID;
  final String photoUrl;
  final String timeAndDate;
  final String type;
  final List hashTags;
  PostView(this.id, this.instagramID, this.photoUrl, this.hashTags,
      this.timeAndDate, this.type);

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Home()));
                    }),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Text(
                    "Hi Rajendra",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "ID: " + widget.id,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Type: " + widget.type,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Stack(children: <Widget>[
                CachedNetworkImage(
                  placeholder: (context, imageUrl) =>
                      Center(child: CircularProgressIndicator()),
                  placeholderFadeInDuration: Duration(milliseconds: 500),
                  fadeInDuration: Duration(milliseconds: 1000),
                  imageUrl: widget.photoUrl,
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                  text: TextSpan(
                      text: "Instagran ID: ",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                      children: [TextSpan(text: widget.instagramID)])),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                  text: "#",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Tags",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    )
                  ]),
            ),
            Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.hashTags.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "#" + widget.hashTags[index].toString(),
                          style: TextStyle(color: Colors.blue),
                        ),
                      );

                      //  ListTile(
                      //   title: Text(widget.hashTags[index].toString()),
                      // );
                    }))
          ],
        ),
      ),
    );
  }
}
