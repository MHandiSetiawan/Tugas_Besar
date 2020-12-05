import 'package:crud/helpers/dbhelper.dart';
import 'package:crud/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'entryform.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DbHelper _dbHelper = DbHelper();
  int _count = 0;
  List<Contact> _contactList;
  @override
  Widget build(BuildContext context) {
    if (_contactList == null) {
      _contactList = List<Contact>();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('CATATAN'),
      ),
      body: createListView(),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: 'Tambah Contact',
          onPressed: () async {
            var contact = await navigateToEntryForm(context, null);
            if (contact != null) addContact(contact);
          }),
    );
  }

  Future<Contact> navigateToEntryForm(
      BuildContext context, Contact contact) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return EntryForm(contact);
        },
      ),
    );
    return result;
  }

  ListView createListView() {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: _count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.note),
            ),
            title: Text(
              this._contactList[index].name,
              style: textStyle,
            ),
            subtitle: Text(
              this._contactList[index].phone,
            ),
            trailing: GestureDetector(
              child: Icon(Icons.delete),
              onTap: () {
                deleteContact(_contactList[index]);
              },
            ),
            onTap: () async {
              var contact =
                  await navigateToEntryForm(context, this._contactList[index]);
              if (contact != null) editContact(contact);
            },
          ),
        );
      },
    );
  }

  void addContact(Contact object) async {
    int result = await _dbHelper.insert(object);
    if (result > 0) {
      updateListView();
    }
  }

  void editContact(Contact object) async {
    int result = await _dbHelper.update(object);
    if (result > 0) {
      updateListView();
    }
  }

  void deleteContact(Contact object) async {
    int result = await _dbHelper.delete(object.id);
    if (result > 0) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = _dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<Contact>> contactListFuture = _dbHelper.getContactList();
      contactListFuture.then((contactList) {
        setState(() {
          this._contactList = contactList;
          this._count = contactList.length;
        });
      });
    });
  }
}
