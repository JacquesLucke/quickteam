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
      _persons.add(PersonData(
          details.localPosition, _nextIdentifier.toString(), Colors.blue));
      _nextIdentifier++;
    });
  }

  void _makeTeams() {
    setState(() {
      var rng = Random();
      for (PersonData person in _persons) {
        person.color = Color.fromARGB(
            255, rng.nextInt(255), rng.nextInt(255), rng.nextInt(255));
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
        child: FloatingActionButton(
          child: Text(person.identifier),
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
                color: Colors.red,
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

  PersonData(this.position, this.identifier, this.color);
}
