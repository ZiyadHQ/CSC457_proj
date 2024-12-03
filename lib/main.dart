import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            // Card
            // (
            //   color: Colors.green,
            //   child: StreamBuilder(stream: FirebaseFirestore.instance.collection("Record").snapshots(), builder: (context, snapshot) {
            //     if(!snapshot.hasData) return CircularProgressIndicator();

            //     final docs = snapshot.data!.docs;

            //     return ListView.builder 
            //     (
            //       itemBuilder: (context, index) {
            //         final data = docs[index].data() as Map<String, dynamic>;
            //         return ElevatedButton(onPressed: (){}, child: Text(data["description"]));
            //       },
            //       itemCount: docs.length,
            //     );
            //   },)
            // ),
            TextButton(onPressed: () async {await FirebaseFirestore.instance.collection("Record").doc().set({"Name" : FirebaseAuth.instance.currentUser!.email});}, child: Text("add task")),
            Spacer()
          ],
        ),
      ),
    );
  }
}

class newTaskPage extends StatelessWidget
{
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

          ],
        ),
      ),
    );
  }
  
}