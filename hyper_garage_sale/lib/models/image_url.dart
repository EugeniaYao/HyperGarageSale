import 'package:firebase_database/firebase_database.dart';

class ImageUrl {
  String key;
  String userId;
  String itemTitle;
  String url;

  ImageUrl(this.userId, this.itemTitle, this.url);

  ImageUrl.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        itemTitle = snapshot.value["itemTitle"],
        url = snapshot.value["url"];

  toJson() {
    return {
      "userId": userId,
      "itemTitle": itemTitle,
      "url": url,
    };
  }
}