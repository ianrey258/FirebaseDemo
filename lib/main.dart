import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String id;
  final db = Firestore.instance;

  TextEditingController eventTitle = TextEditingController();
  TextEditingController activity = TextEditingController();
  TextEditingController date = TextEditingController();
  ScrollController _sc = ScrollController();

  Widget build(context){
    return Scaffold(
      appBar: AppBar(title: Text("FireBase_Sample")),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(3),
                      child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Title Event',
                        fillColor: Colors.grey[300],
                        filled: true,
                      ),
                      controller: eventTitle,
                    ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(3),
                      child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Activity',
                        fillColor: Colors.grey[300],
                        filled: true,
                      ),
                      controller: activity,
                    ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'YYYY-MM-DD',
                        fillColor: Colors.grey[300],
                        filled: true,
                      ),
                      controller: date,
                    ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(3),
                      child: FlatButton(
                        color: Colors.green,
                        onPressed: clearController,
                        child: Text("Clear"),
                      ),
                    )
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(3),
                      child: FlatButton(
                        color: Colors.blue,
                        onPressed: createData,
                        child: Text("Submit"),
                      ),
                    )
                  ),
                ],
              ),
              Container(
                child: ListView(
                  controller: _sc,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.0),
                  children: <Widget>[
                    StreamBuilder<QuerySnapshot>(
                      stream: db.collection('task').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                              children: snapshot.data.documents
                                  .map((doc) => buildItem(doc))
                                  .toList());
                        } else {
                          return SizedBox();
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
void createData() async {
    final evt = eventTitle.text;
    final act = activity.text;
    final dt = date.text;
    DocumentReference ref = await db.collection('task').add({'Title': '$evt','Activity': '$act','Date': '$dt'});
    setState(() => id = ref.documentID);
    print(ref.documentID);
    clearController();
  }

  void updateData(DocumentSnapshot doc) async {
    final evt = eventTitle.text;
    final act = activity.text;
    final dt = date.text;
    await db
        .collection('task')
        .document(doc.documentID)
        .updateData({'Title': '$evt','Activity': '$act','Date': '$dt'});
  }

  void deleteData(DocumentSnapshot doc) async {
    await db.collection('task').document(doc.documentID).delete();
    setState(() => id = null);
  }
  void clearController(){
    setState(() {
      eventTitle.text ="";
      activity.text ="";
      date.text ="";
    });
  }

Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Title: ${doc.data['Title']}',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Activity: ${doc.data['Activity']}',
              style: TextStyle(fontSize : 15),
            ),
            Text(
              'Date: ${doc.data['Date']}',
              style: TextStyle(fontSize : 20),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => updateData(doc),
                  child: Text('Update',
                      style: TextStyle(color: Colors.white)),
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                FlatButton(
                  color: Colors.red,
                  onPressed: () => deleteData(doc),
                  child: Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

