import 'package:HyperGarageSale/pages/new_post.dart';
import 'package:HyperGarageSale/pages/browse_post.dart';
import 'package:flutter/material.dart';
import 'package:HyperGarageSale/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:HyperGarageSale/models/item.dart';
import 'dart:async';

/*
  Get logged user and displayed item information in a list
*/

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item> _itemList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  StreamSubscription<Event> _onItemAddedSubscription;
  StreamSubscription<Event> _onItemChangedSubscription;

  Query _itemQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    _itemList = new List();
    _itemQuery = _database
        .reference()
        .child("item")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onItemAddedSubscription = _itemQuery.onChildAdded.listen(_onEntryAdded);
    _onItemChangedSubscription = _itemQuery.onChildChanged.listen(_onEntryChanged);
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail(){
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _onItemAddedSubscription.cancel();
    _onItemChangedSubscription.cancel();
    super.dispose();
  }

  _onEntryChanged(Event event) {
    var oldEntry = _itemList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _itemList[_itemList.indexOf(oldEntry)] = Item.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      _itemList.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  _deleteItem(String itemId, int index) {
    _database.reference().child("item").child(itemId).remove().then((_) {
      print("Delete $itemId successful");
      setState(() {
        _itemList.removeAt(index);
      });
    });
  }

  Widget _showItemList() {
    if (_itemList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _itemList.length,
          itemBuilder: (BuildContext context, int index) {
            String itemId = _itemList[index].key;
            String title = _itemList[index].title;
            String price = "\$" + _itemList[index].price;
            String description = _itemList[index].description;
            //String userId = _itemList[index].userId;
            return Dismissible(
              key: Key(itemId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                _deleteItem(itemId, index);
              },
              child: ListTile(
                /*leading: new CircleAvatar(
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.grey,
                  // add data
                  backgroundImage: new NetworkImage("http://www.usanetwork.com/sites/usanetwork/files/styles/629x720/public/suits_cast_harvey.jpg?itok=fpTOeeBb"),
                ),*/
                title: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(
                      title,
                      style: new TextStyle(fontWeight: FontWeight.bold),
                    ),
                    new Text(
                      price,
                      style: new TextStyle(color: Colors.grey, fontSize: 20.0),
                    ),
                  ],
                ),
                subtitle: new Container(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: new Text(
                    description,
                    style: new TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) =>
                      new BrowsePost(db: _database, userId: widget.userId, item: _itemList[index])),
                  );
                },
              ),
            );
          });
    } else {
      return Center(child: Text("Welcome. Your list is loading...",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),));
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('HyperGarageSale'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('LogOut',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: _showItemList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) =>
                new NewPost(db: _database, userId: widget.userId,)),
            );
          },
          tooltip: 'Create New Post',
          child: Icon(Icons.add),
        )
    );
  }
}
