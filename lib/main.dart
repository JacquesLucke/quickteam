import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(QuickTeamApp());

class QuickTeamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTeam',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PersonData> _persons;
  int _nextIdentifier;

  @override
  void initState() {
    super.initState();
    _persons = [];
    _nextIdentifier = 1;
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _persons.add(PersonData(details.localPosition, _nextIdentifier.toString(),
          Colors.blue, GlobalKey()));
      _nextIdentifier++;
    });
  }

  void _makeTeams() {
    setState(() {
      var rng = Random();
      List<PersonData> personsCopy = List<PersonData>.from(_persons);
      personsCopy.shuffle(rng);
      int firstTeamSize = _persons.length ~/ 2;

      for (PersonData person in personsCopy.sublist(0, firstTeamSize)) {
        person.color = Colors.blueGrey;
      }
      for (PersonData person in personsCopy.sublist(firstTeamSize)) {
        person.color = Colors.redAccent;
      }
    });
  }

  void _reset() {
    setState(() {
      _persons.clear();
      _nextIdentifier = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (PersonData person in _persons) {
      widgets.add(Positioned(
        key: person.key,
        child: FloatingActionButton(
          child: Text(
            person.identifier,
            textScaleFactor: 1.5,
          ),
          onPressed: () {
            setState(() {
              _persons.remove(person);
            });
          },
          backgroundColor: person.color,
        ),
        left: person.position.dx,
        top: person.position.dy,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RaisedButton(
                child: Text('Make Teams'),
                onPressed: _makeTeams,
              ),
              RaisedButton(
                child: Text('Reset'),
                onPressed: _reset,
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTapDown: _onTapDown,
              child: Container(
                constraints: BoxConstraints.expand(),
                color: Colors.green,
                child: Stack(
                  children: widgets,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonData {
  Offset position;
  String identifier;
  Color color;
  Key key;

  PersonData(this.position, this.identifier, this.color, this.key);
}
