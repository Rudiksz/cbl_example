import 'dart:math';

import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CBL Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DocumentTests(),
    );
  }
}

class DocumentTests extends StatefulWidget {
  @override
  _DocumentTestsState createState() => _DocumentTestsState();
}

class _DocumentTestsState extends State<DocumentTests> {
  List<String> messages = [];
  Database db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CBL test")),
      body: Column(
        children: [
          Wrap(
            children: [
              RaisedButton(
                  child: Text("Document tests"), onPressed: documentTests),
              RaisedButton(child: Text("Query tests"), onPressed: queryTests),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (_, i) => Card(
                color: i % 2 == 0 ? Colors.white : Colors.grey[100],
                child: messages[i] == "divider" ? Divider() : Text(messages[i]),
              ),
              itemCount: messages.length,
            ),
          )
        ],
      ),
    );
  }

  queryTests() async {
    messages = [];
    setState(() {});
    await initDatabase();

    Person person1 = await SampleData.person1;
    await db.saveDocument(MutableDocument(id: person1.id, data: person1.json));

    var person2 = person1.copy(id: "person2", name: "Person2");
    await db.saveDocument(MutableDocument(id: person2.id, data: person2.json));

    // Create some random people
    Map<String, Person> people = Map.fromIterable(
      List.generate(5, (index) => SampleData.randomPerson),
      key: (item) => item.id,
      value: (item) => item,
    );

    people.forEach((key, p) async {
      await db.saveDocument(MutableDocument(id: p.id, data: p.json));
    });

    // and some random activities
    Map<String, Activity> activities = Map.fromIterable(
      List<Activity>.generate(5, (index) => SampleData.randomActivity),
      key: (item) => item.id,
      value: (item) => (item as Activity)
        ..personId = (Random().nextBool()
            ? people.keys.toList()[Random().nextInt(people.keys.length)]
            : null),
    );

    activities.forEach((key, p) async {
      await db.saveDocument(MutableDocument(id: p.id, data: p.json));
    });

    setState(() {});

    // Test query
    var query = QueryBuilder.select([
      SelectResult.expression(Expression.property("name")),
      SelectResult.expression(Expression.property("active")),
      SelectResult.expression(Expression.property("height")),
      SelectResult.expression(Expression.property("age")),
    ])
        .from(db.name)
        .where(
            Expression.property("doctype").equalTo(Expression.string("person")))
        .limit(Expression.intValue(10));

    messages.add("Executing query:");
    messages.add(await query.explain());
    var queryResult = await query.execute();

    messages.add("Parsing results:");
    for (Result result in queryResult) {
      messages.add("CBL Result:" + result.toMap().toString());

      messages.add(result.toMap().toString());
      messages.add(result.toList().toString());
      print(result.toList().toString());

      // Old Result object
      //var p = Person.fromJson(result.toMap()["test"]);
      //var p1 = Person.fromJson(result.toList()[0]);

      // New Result Object
      // var p = Person.fromJson(result.map["test"]);
      // var p1 = Person.fromJson(result.list[0]);

      // messages.add("Person (from map):" + p.json.toString());
      // messages.add("Person (from list):" + p1.json.toString());
    }

    var activity = "activity";
    var person = "person";

    var joinQuery = QueryBuilder.select([
      SelectResultFrom(Expression.all().from(activity), activity),
      SelectResultFrom(Expression.all().from(person), person),
    ])
        .from(db.name, as: activity)
        .join(
          Join.leftJoin(db.name, as: person).on(Meta.id
              .from(person)
              .equalTo(Expression.property("personId").from(activity))),
        )
        .where(Expression.property("doctype")
            .from(activity)
            .equalTo(Expression.string("activity")));

    messages.add("Executing query:");
    messages.add(await joinQuery.explain());
    var jsonQueryResult = await joinQuery.execute();

    messages.add("Parsing results:");
    for (Result result in jsonQueryResult) {
      messages.add("CBL Result:" + result.toMap().toString());

      // Old Result object
      //var a = Activity.fromJson(result.toMap()[activity]);
      //a.person = Person.fromJson(result.toMap()[person]);

      //var a1 = Activity.fromJson(result.toList()[1]);
      //a1.person = Person.fromJson(result.toList()[0]);

      // New Result object
      // var a = Activity.fromJson(result.map[activity]);
      // a.person = Person.fromJson(result.map[person]);

      // var a1 = Activity.fromJson(result.list[1]);
      // a1.person = Person.fromJson(result.list[0]);
/*
      messages.add(
        "Activity (from map):" +
            a.json.toString() +
            " - " +
            (a.person.json.toString()),
      );

      messages.add(
        "Activity (from map):" +
            a1.json.toString() +
            " - " +
            (a1.person.json.toString()),
      );

      */
    }

    setState(() {});
  }

  documentTests() async {
    messages = [];
    setState(() {});
    await initDatabase();

    Person person1 = await SampleData.person1;

    MutableDocument doc = MutableDocument(id: person1.id, data: person1.json);
    doc.setBlob("avatar", person1.avatar);

    messages.add("Saving document with the following data:");
    messages.add("    Id: " + person1.id);
    messages.add("    Data: " + person1.json.toString());

    await db.saveDocument(doc);

    messages.add("divider");
    messages.add("Reading back the document: ");

    Document doc1 = await db.document(person1.id);
    messages.add(doc1.toMap().toString());

    var p1 = Person.fromCBLDocument(doc1);
    var p2 = Person.fromJson(doc1.toMap());

    messages.add("Document parsed as json:");
    messages.add(p1.json.toString());

    messages.add("Document parsed as CBL document:");
    messages.add(p2.json.toString());

    messages.add("Equals?:" + (p1 == p2).toString());

    messages.add("The blob data: ");
    // var blobContent = await db.getBlobContent(doc1.getBlob("avatar"));
    //var blobContent = await doc1.getBlob("avatar").contentFromDatabase(db);
    //messages.add(blobContent.toString());

    messages.add("divider");

    messages.add("Saving document");
    Document doc2 = await db.document(person1.id);
    messages.add(doc2.toMap().toString());
    await db.saveDocument(doc2.toMutable());

    Document doc3 = await db.document(person1.id);
    messages.add("Reading back the document again: ");
    messages.add(doc3.toMap().toString());
    messages.add("The blob data: ");

    // var blobContent1 = await db.getBlobContent(doc3.getBlob("avatar"));
    //var blobContent1 = await doc3.getBlob("avatar").contentFromDatabase(db);
    //messages.add(blobContent1.toString());

    messages.add("Deleting the blob");
    var newdoc = doc3.toMutable();
    newdoc.remove("avatar");
    await db.saveDocument(newdoc);

    Document doc4 = await db.document(person1.id);
    messages.add("Reading back document again: ");
    messages.add(doc4.toMap().toString());
    messages.add("The blob data: ");

    // var blobContent2 = await db.getBlobContent(doc4.getBlob("avatar"));
    //var blobContent2 = await doc4.getBlob("avatar")?.contentFromDatabase(db);
    //messages.add(blobContent2.toString());

    setState(() {});
  }

  initDatabase() async {
    // Close, delete and open a new database.
    try {
      await db?.close();
    } catch (e) {
      print(e);
    }
    db = await Database.initWithName("test");
    await db.delete();
    db = await Database.initWithName("test");

    messages.add("DB: " + db.name);
    messages.add("Path: " + db.path);
  }
}

class SampleData {
  static Future<Person> get person1 async {
    // A Person document with the basic supported data types...
    var settings = Map();
    settings["a"] = "b";
    settings["x"] = "y";
    settings["list"] = ["1", "2", "3", "4", 5];
    settings["map"] = {"1": "one", "2": "two", "3": "three"};

    var blobData = await rootBundle.load("assets/blobtest.png");

    return Person(
      id: "person1",
      name: "Person1",
      age: 10,
      height: 5.6,
      active: true,
      birthday: DateTime(2000, 02, 02),
      languages: ["en", "es"],
      settings: settings,
      avatar: Blob.data("image/png", blobData.buffer.asUint8List()),
    );
  }

  static get randomPerson {
    var id = Random().nextInt(100000000).toString();
    return Person(
      id: "person_$id",
      name: "Person$id",
      age: Random().nextInt(100),
    );
  }

  static get randomActivity {
    return Activity(
      id: Random().nextInt(100000000).toString(),
      name: Random().nextBool() ? "walking" : "swimming",
    );
  }
}

class Person {
  Person({
    this.id,
    this.name,
    this.birthday,
    this.age,
    this.height,
    this.active,
    this.languages,
    this.settings,
    this.avatar,
  });

  String id;

  String name;
  DateTime birthday;
  int age;
  double height;
  bool active;
  List<String> languages;
  Map<dynamic, dynamic> settings;
  Blob avatar;

  bool operator ==(o) =>
      o is Person &&
      o.id == id &&
      o.name == name &&
      (o.birthday?.isAtSameMomentAs(birthday ?? DateTime(0)) ??
          (o.birthday == birthday)) &&
      o.age == age &&
      o.height == height &&
      o.active == active &&
      listEquals(o.languages, languages) &&
      o.avatar?.digest == avatar?.digest;

  int get hashCode => id.hashCode;

  copy({
    Person to,
    String id,
    String name,
    DateTime birthday,
    int age,
    double height,
    bool active,
    List<String> languages,
    Map<dynamic, dynamic> settings,
    Blob avatar,
  }) =>
      (to ?? Person())
        ..id = id ?? this.id
        ..name = name ?? this.name
        ..birthday = birthday ?? this.birthday
        ..age = age ?? this.age
        ..height = height ?? this.height
        ..active = active ?? this.active
        ..languages = languages ?? this.languages
        ..settings = settings ?? this.settings
        ..avatar = avatar ?? this.avatar;

  Person.fromDocument(Document doc) {
    id = doc.id;
    name = doc.getString("name");
  }

  Person.fromJson(Map<dynamic, dynamic> json) {
    json ??= {};
    id = json["id"] as String;
    name = json["name"] as String;
    age = json["age"] as int;
    height = json["height"] as double;
    active = json["active"] as bool;
    birthday = JsonUtils.parseDate(json["birthday"]);
    languages = JsonUtils.asList(json["languages"]);
    settings = JsonUtils.asMap(json["settings"]);
    //avatar = JsonUtils.asBlob(json["avatar"]);
  }

  Person.fromCBLDocument(Document doc) {
    id = doc.id;
    name = doc.getString("name");
    age = doc.getInt("age");
    height = doc.getDouble("height");
    active = doc.getBoolean("active");
    birthday = JsonUtils.parseDate(doc.getString("birthday"));
    languages = doc.getList("languages");
    settings = doc.getMap("settings");
    avatar = doc.getBlob("avatar");
  }

  Map<dynamic, dynamic> get json {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      val[key] = value;
      /*
      if (value != null) {
        val[key] = value;
      }*/
    }

    writeNotNull("id", id);
    writeNotNull("doctype", "person");
    writeNotNull('name', name);
    writeNotNull('birthday', birthday?.toIso8601String());
    writeNotNull('age', age);
    writeNotNull('height', height);
    writeNotNull('active', active);
    writeNotNull('languages', languages);
    writeNotNull('settings', settings);
/*
    if (avatar != null) {
      val["avatar"] = avatar.json;
    }*/

    return val;
  }
}

class JsonUtils {
  static List<T> asList<T>(List list) => list?.map((e) => e as T)?.toList();

  static Map<T, V> asMap<T, V>(Map<dynamic, dynamic> json) =>
      json?.map<T, V>((k, e) => MapEntry<T, V>(k as T, e as V));

  static DateTime parseDate(date) =>
      date == null ? null : DateTime.tryParse(date as String);

  //static Blob asBlob(blob) =>
  //    blob == null || !(blob is Map) ? null : Blob.fromJson(blob);
}

class Activity {
  Activity({
    this.id,
    this.name,
    this.personId,
    this.person,
  });

  String id;

  String name;
  String personId;
  Person person;

  bool operator ==(o) =>
      o is Activity && o.id == id && o.name == name && o.personId == personId;

  int get hashCode => id.hashCode;

  copy({
    Activity to,
    String id,
    String name,
    String personId,
    Person person,
  }) =>
      (to ?? Activity())
        ..id = id ?? this.id
        ..name = name ?? this.name
        ..personId = personId ?? this.personId
        ..person = person ?? this.person;

  Activity.fromJson(Map<dynamic, dynamic> json) {
    id = json["id"] as String;
    name = json["name"] as String;
    personId = json["personId"] as String;
  }

  Activity.fromCBLDocument(Document doc) {
    id = doc.id;
    name = doc.getString("name");
    personId = doc.getString("personId");
  }

  Map<dynamic, dynamic> get json {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull("id", id);
    writeNotNull("doctype", "activity");
    writeNotNull('name', name);
    writeNotNull('personId', personId);

    return val;
  }
}
