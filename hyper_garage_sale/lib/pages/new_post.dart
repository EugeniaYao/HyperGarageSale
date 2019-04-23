import 'package:HyperGarageSale/models/item.dart';
import 'package:HyperGarageSale/models/image_url.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/*
  Create a new Post including title, price, description and photos
  Upload new item information to firebase realtime database
*/

class NewPost extends StatefulWidget {
  NewPost({Key key, this.db, this.userId})
      : super(key: key);
  final db;
  final userId;
  @override
  _NewPostState createState() {
    return new _NewPostState();
  }
}

class _NewPostState extends State<NewPost> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  var _imgPath;
  // Selected images list
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';

  final TextEditingController _titleController = new TextEditingController();
  final TextEditingController _priceController = new TextEditingController();
  final TextEditingController _descriptionController = new TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  Widget _editNewPost(BuildContext context) {
    return new Column(
      children: <Widget>[
        new TextField(
          controller: _titleController,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              icon: Icon(Icons.title),
              helperText: 'Enter title of the item'
          ),
        ),

        new TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              icon: Icon(Icons.attach_money),
              helperText: 'Enter price'
          ),
        ),

        new TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              icon: Icon(Icons.description),
              helperText: 'Enter description of the item'
          ),
        ),

        new RaisedButton(
          child: new Text('Select the photo'),
          onPressed: loadAssets,
        ),

        // Photos thumbnail
        Expanded(
          child: buildGridView(),
        )
      ],
    );
  }

  _addNewItem(String newItem) {
    if (newItem.length > 0) {
      // add title, price, description
      Item item = new Item(newItem.toString(), _priceController.text,
          _descriptionController.text, widget.userId);
      widget.db.reference().child("item").push().set(item.toJson());
    }
  }

  _addNewImg(String newImg) {
    if (newImg.length > 0) {
      // add image url into database
      ImageUrl img = new ImageUrl(widget.userId, _titleController.text, newImg);
      widget.db.reference().child("imageUrl").push().set(img.toJson());
    }
  }

  // Img thumbnail
  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> deleteAssets() async {
    await MultiImagePicker.deleteImages(assets: images);
    setState(() {
      images = List<Asset>();
    });
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        // up to 4 images
          maxImages: 4,
          enableCamera: true,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            actionBarColor: "#ff075E54",
            actionBarTitle: "Select Photos",
            allViewTitle: "All Photos",
            selectCircleStrokeColor: "#000000",
          ));
    } on PlatformException catch (e) {
      error = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  Future saveImage(Asset asset) async {
    ByteData byteData = await asset.requestOriginal();
    List<int> imageData = byteData.buffer.asUint8List();
    StorageReference ref =
    FirebaseStorage.instance.ref().child(widget.userId).child(_titleController.text).child(asset.name);
    StorageUploadTask uploadTask = ref.putData(imageData);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    _addNewImg(url);
    return await (await uploadTask.onComplete).ref.getDownloadURL();
  }

  Widget _saveitem(BuildContext context) {
      _addNewItem(_titleController.text.toString());
      for (Asset a in images) {
        saveImage(a);
        // Show SnackBar after adding
        var snackBar = SnackBar(
          content: new Text("Added new post successfully!"),
          duration: Duration(minutes: 2),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("HyperGarageSale"),
        actions: <Widget>[
          // Reset
          new IconButton(
              icon: Icon(Icons.refresh),
              onPressed: (){
                setState(() {
                  _titleController.clear();
                  _priceController.clear();
                  _descriptionController.clear();
                  images = new List();
                });
              }
          ),

          new IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                _saveitem(context);
              }
          ),
        ],
      ),
      body: _editNewPost(context),
    );
  }

}
