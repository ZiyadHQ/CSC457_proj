import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp
  (
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(MaterialApp
  (
    home: MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  String displayMessage = "TEST TEXT";

  @override
  void initState()
  {
    displayMessage = (FirebaseAuth.instance.currentUser == null)? "no user" : "user found";
    setState(() {
      
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column
          (
            children: 
            [
              Spacer(),
              Text(displayMessage),
              Spacer(),
              Text("Register"),
              ElevatedButton(onPressed: () {showDialog(context: context, builder: (context) => registerPage(),);}, child: SizedBox(),),
              Spacer(),
              Text("Sign in"),
              ElevatedButton(onPressed: () {showDialog(context: context, builder: (context) => loginPage(),);}, child: SizedBox(width: 80,)),
              Spacer(),
              Text("send record to DB(must sign in)"),
              ElevatedButton(onPressed: () async 
              {
                print("sending record");
                await FirebaseFirestore.instance.collection("Record").doc().set
                (
                  {
                    "Name" : "Ahmad",
                    "ID" : FirebaseAuth.instance.currentUser!.uid
                  }
                );
                setState(() {});
              }, child: SizedBox(width: 80,)),
              Spacer()
            ],
          ),
        ),
      ),
    );
  }
}


class registerPage extends StatelessWidget
{

  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Center
      (
        child: Column
        (
          children: 
          [
            Spacer(),
            Text("register"),
            Spacer(),
            Text("Email:"),
            TextField
            (
              controller: _nameController,
            ),
            Spacer(),
            Text("Password:"),
            TextField
            (
              controller: _passwordController,
            ),
            Spacer(),
            ElevatedButton(onPressed: () async
            {
              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _nameController.text, password: _passwordController.text);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل التسجيل")));
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("نجح التسجيل")));
              Navigator.pop(context);
            }, child: SizedBox()),
            Spacer()
          ],
        ),
      ),
    );
  }
  
}

class loginPage extends StatelessWidget
{

  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center
      (
        child: Column
        (
          children: 
          [
            Spacer(),
            Text("sign"),
            Spacer(),
            Text("Email:"),
            TextField
            (
              controller: _nameController,
            ),
            Spacer(),
            Text("Password:"),
            TextField
            (
              controller: _passwordController,
            ),
            Spacer(),
            ElevatedButton(onPressed: () async
            {
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(email: _nameController.text, password: _passwordController.text);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل التسجيل")));
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("نجح التسجيل")));
              showDialog(context: context, builder: (context) => userPage());
            }, child: SizedBox()),
            Spacer()
          ],
        ),
      ),
    ); 

  }
  
}

class userPage extends StatefulWidget
{
  @override
  State<userPage> createState() => _userPageState();
}

class _userPageState extends State<userPage> {
  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (

      appBar: AppBar
      (
       automaticallyImplyLeading: false, 
        title: Text("name: ${FirebaseAuth.instance.currentUser!.email}, uid: ${FirebaseAuth.instance.currentUser!.uid}"),
        leading: TextButton(onPressed: ()
        async 
        {
          showDialog(context: context, builder: (context) => CircularProgressIndicator(),);
          await FirebaseAuth.instance.signOut();
          Navigator.pop(context);
          Navigator.pop(context);
        }, child: Icon(Icons.keyboard_backspace_rounded, color: Colors.red,)),
      ),
      body: Center(
        child: Column
        (
          children: 
          [
            Spacer(),
            TextButton(onPressed: ()
            {
              showDialog(context: context, builder: (context) => newTaskPage(),);
            }, child: Text("create new task")),
            SizedBox
            (
              height: 500,              
              child: StreamBuilder(stream: FirebaseFirestore.instance.collection("Record").snapshots(), builder: (context, snapshot) {
                if(!snapshot.hasData) return CircularProgressIndicator();

                final docs = snapshot.data!.docs;

                return ListView.builder 
                (
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ElevatedButton(onPressed: ()
                    {
                      showDialog(context: context, builder: (context) => taskPage(data: docs[index],));
                    }, child: Text(data["desc"]));
                  },
                  itemCount: docs.length,
                );
              },)
            ),
            // TextButton(onPressed: () async {await FirebaseFirestore.instance.collection("Record").doc().set({"Name" : FirebaseAuth.instance.currentUser!.email});}, child: Text("add task")),
            Spacer()
          ],
        ),
      ),
    );
  }
}

class newTaskPage extends StatelessWidget
{

  TextEditingController _descController = TextEditingController();
  DateTime? deadline;
  int? priority;
  int? type ;

  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      body: Center
      (
        child: Column
        (
          children: 
          [
            Spacer(),
            Text("description:"),
            TextField(controller: _descController,),
            Spacer(),
            TextButton(onPressed: () async {deadline = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(DateTime.now().year + 100));}, child: Text("deadline")),
            Spacer(),
            Text("priotity:"),
            Row
            (
              children: 
              [
                Spacer(),
                TextButton(onPressed: (){priority = 0; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("priority set to low")));}, child: Text("low")),
                Spacer(),
                TextButton(onPressed: (){priority = 1; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("priority set to medium")));}, child: Text("medium")),
                Spacer(),
                TextButton(onPressed: (){priority = 2; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("priority set to high")));}, child: Text("high")),
                Spacer(),
              ],
            ),
            Spacer(),
            Text("Task type:"),
            Row
            (
              children: 
              [
                Spacer(),
                TextButton(onPressed: (){type = 0; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("type set to Project")));}, child: Text("Project")),
                Spacer(),
                TextButton(onPressed: (){type = 1; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("type set to List")));}, child: Text("List")),
                Spacer(),
              ],
            ),
            Spacer(),
            TextButton(onPressed: ()
            {
              String error = "";
              if(priority == null)
              {
                error += "priority not set, ";
              }
              if(type == null)
              {
                error += "type not set, ";
              }
              if(deadline == null)
              {
                error += "deadline not set, ";
              }
              if(_descController.text.isEmpty)
              {
                error += "description not set, ";
              }
              if(error.length > 0)
              {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              showDialog(context: context, builder: (context) => CircularProgressIndicator(),);
              FirebaseFirestore.instance.collection("Record").doc().set
              (
                {
                  "ID" : FirebaseAuth.instance.currentUser!.uid,
                  "desc" : _descController.text,
                  "deadline" : deadline,
                  "priority" : priority,
                  "type" : type
                }
              );
              Navigator.pop(context);
              Navigator.pop(context);
            }, child: Text("Submit")),
            Spacer()
          ],
        ),
      ),
    );
  }
  
}

class taskPage extends StatefulWidget
{

  taskPage({required this.data});

  DocumentSnapshot<Map<String, dynamic>> data;

  @override
  State<taskPage> createState() => _taskPageState();
}

class _taskPageState extends State<taskPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold
    (
      body: Center
      (
        child: Column
        (
          children: 
          [
            ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text("return")),
            Spacer(),
            Text("description:"),
            Text(widget.data.data()!["desc"]),
            Text("deadline:"),
            Text((widget.data.data()!["deadline"] as Timestamp).toDate().toString()),
            Text("priority:"),
            Text(widget.data.data()!["priority"].toString()),
            Text("type:"),
            Text(widget.data.data()!["type"].toString()),
            Spacer(),
            SizedBox
            (
              height: 500,
              child: StreamBuilder(stream: FirebaseFirestore.instance.collection("Record").doc(widget.data.id).snapshots(), builder: (context, snapshot) {
                if(!snapshot.hasData)
                {
                  return CircularProgressIndicator();
                }

                final docs = snapshot.data;

                return SizedBox();
              },),
            ),
            CupertinoTextField(),
            TextButton(onPressed: (){}, child: Text("send comment")),
          ],
        ),
      ),
    );

  }
}