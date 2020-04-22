import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";
final String isMan = "isMan";
final String isWoman = "isWoman";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  var db2 = Firestore.instance;

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
    }
    return _db;
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT, $isMan TEXT, $isWoman TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    // Salvando no sqlite
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());

    // Salvando no firebase
    Firestore.instance
        .collection("contatos")
        .document(contact.id.toString())
        .setData({
      "idColumn": contact.id.toString(),
      "nameColumn": contact.name,
      "emailColumn": contact.email,
      "phoneColumn": contact.phone,
      "imgColumn": contact.img,
      "isMan": contact.man,
      "isWoman": contact.woman
    });

    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [
          idColumn,
          nameColumn,
          emailColumn,
          phoneColumn,
          imgColumn,
          isMan,
          isWoman
        ],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;

    Firestore.instance
        .collection("contatos")
        .document(id.toString())
        .delete();

    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;

    Firestore.instance
        .collection("contatos")
        .document(contact.id.toString())
        .updateData({
          "nameColumn": contact.name, 
          "emailColumn": contact.email,
          "phoneColumn": contact.phone,
          "imgColumn": contact.img,
          "isMan": contact.man,
          "isWoman": contact.woman
        });

    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }



  Future<List> getAllContacts() async {
    // Database dbContact = await db;
    // List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    // for (Map m in listMap) {
    //   listContact.add(Contact.fromMap(m));
    // }


    QuerySnapshot res =
        await db2.collection("contatos").getDocuments();

    res.documents.forEach((value){


      
      // listContactFirebase.add({
      //   'idColumn': value.data['idColumn'],
      // });

      Contact con = new Contact();
      con.name = value.data['nameColumn'];
      con.id = int.parse(value.data['idColumn']);
      con.email = value.data['emailColumn'];
      con.phone = value.data['phoneColumn'];
      con.img = value.data['imgColumn'];
      con.man = value.data['isMan'];
      con.woman = value.data['isWoman'];

      //var print = value.data['isWoman'];
      listContact.add(con);

    });

    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;
  String man;
  String woman;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
    man = map[isMan];
    woman = map[isWoman];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
      isMan: man,
      isWoman: woman
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img, man: $man, woman: $woman)";
  }
}
