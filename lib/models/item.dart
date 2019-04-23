import 'package:firebase_database/firebase_database.dart';

class Item {
  String key;
  String title;
  String price;
  String description;
  String userId;

  Item(this.title, this.price, this.description, this.userId);

  Item.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    title = snapshot.value["title"],
    price = snapshot.value["price"],
    description = snapshot.value["description"];


  toJson() {
    return {
      "userId": userId,
      "title": title,
      "price": price,
      "description": description,
    };
  }
}