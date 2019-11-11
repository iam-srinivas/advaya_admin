import 'package:advaya_admin/screens/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  bool isSignedIn = false;
  Firestore db = Firestore.instance;

  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
      }
    });
  }

  getUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    await firebaseUser?.reload();
    firebaseUser = await _auth.currentUser();

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isSignedIn = true;
      });
    }
  }

  signOut() async {
    _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    this.getUser();
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Text(document['Name'] + ' (' + document['Usn'] + ')'),
      subtitle:
          Text('Year:' + document['Year'] + '    ' + document['Department']),
      trailing: MaterialButton(
        onPressed: () {
          addToNextRound(document);
        },
        child: Icon(Icons.person_add),
      ),
    );
  }

  Widget getData(BuildContext context, String checker) {
    return StreamBuilder(
      stream: db
          .collection('users')
          .where('Status', isEqualTo: checker)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (BuildContext context, index) =>
              _buildListItem(context, snapshot.data.documents[index]),
        );
      },
    );
  }

  addToNextRound(DocumentSnapshot document) async {
    switch (document['Status']) {
      case 'New':
        await document.reference.updateData({'Status': 'Round1'});
        break;
      case 'Round1Completed':
        await document.reference.updateData({'Status': 'Round2'});
        break;
      case 'Round2Completed':
        await document.reference.updateData({'Status': 'Round3'});
        break;
      case 'Round3Completed':
        await document.reference.updateData({'Status': 'Final'});
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
          bottom: TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(
                icon: Text('Registered'),
                text: 'Participants',
              ),
              Tab(
                icon: Text('Round 1'),
                text: 'Participants',
              ),
              Tab(
                icon: Text('Round 1'),
                text: 'Completed',
              ),
              Tab(
                icon: Text('Round 2'),
                text: 'Participants',
              ),
              Tab(
                icon: Text(' Round 2'),
                text: 'Completed',
              ),
              Tab(
                icon: Text('Round 3'),
                text: 'Participants',
              ),
              Tab(
                icon: Text('Round 3'),
                text: 'Completed',
              ),
              Tab(
                icon: Text('Final'),
                text: 'Results',
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          getData(context, 'New'),
          getData(context, 'Round1'),
          getData(context, 'Round1Completed'),
          getData(context, 'Round2'),
          getData(context, 'Round2Completed'),
          getData(context, 'Round3'),
          getData(context, 'Round3Completed'),
          getData(context, 'Final'),
        ]),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('Name'),
                accountEmail: user != null ? Text(user.email) : Text('Loading'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.purple,
                ),
              ),
              ListTile(
                title: Text('Log Out'),
                onTap: signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
