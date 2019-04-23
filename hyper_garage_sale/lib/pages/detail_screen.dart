import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/*
  Full screen photo thumbnail
  Put the image into a stack before appbar to realize the fullscreen effect within a "back" button
*/

class DetailScreen extends StatefulWidget {
  final String tag;
  final String url;

  DetailScreen({Key key, @required this.tag, @required this.url})
      : assert(tag != null),
        assert(url != null),
        super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          child: Center(
            child: Hero(
              tag: widget.tag,
              child: CachedNetworkImage(
                imageUrl: widget.url,
                placeholder: (context, url) => new Center(
                    child: Container(
                        width: 32,
                        height: 32,
                        child: new CircularProgressIndicator()
                    )
                ),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: new AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: new Container(
            color: Colors.transparent,
          ),
        ),
      ],
    );

  }
}