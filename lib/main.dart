import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const QuickTeamApp());

class QuickTeamApp extends StatelessWidget {
  const QuickTeamApp({super.key});

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
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

double computeCircleRadius(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return min(size.width, size.height) / 12;
}

List<Color> teamColors = [
  Colors.blueGrey,
  Colors.redAccent,
  Colors.lightGreen,
  Colors.purpleAccent,
  Colors.amber,
];

class _HomePageState extends State<HomePage> {
  List<PersonData>? _persons;
  int? _nextIdentifier;
  double _circleRadius = 10;
  int? _teamAmount;

  @override
  void initState() {
    super.initState();
    _persons = [];
    _nextIdentifier = 1;
    _teamAmount = 2;
  }

  Offset? _getFinalPositionOrNull(Offset position) {
    double minDistance = 2.1 * _circleRadius;
    for (PersonData person in _persons!) {
      Offset difference = position - person.position;
      double distance = difference.distance;
      if (distance < minDistance) {
        if (distance == 0) {
          return null;
        }
        Offset normalizedDirection = difference / distance;
        position = person.position + normalizedDirection * minDistance;
      }
    }
    for (PersonData person in _persons!) {
      if ((person.position - position).distance < minDistance) {
        return null;
      }
    }
    return position;
  }

  void _onTapDown(TapDownDetails details) {
    Offset? newPosition = _getFinalPositionOrNull(details.localPosition);
    if (newPosition == null) {
      return;
    }

    setState(() {
      _persons!.add(PersonData(
          newPosition, _nextIdentifier.toString(), Colors.blue, GlobalKey()));
      _nextIdentifier = _nextIdentifier! + 1;
    });
  }

  void _makeTeams() {
    setState(() {
      var rng = Random();
      List<PersonData> personsCopy = List<PersonData>.from(_persons!);
      personsCopy.shuffle(rng);

      personsCopy.asMap().forEach((index, person) {
        Color color = teamColors[index % _teamAmount!];
        person.color = color;
      });
    });
  }

  void _reset() {
    setState(() {
      _persons!.clear();
      _nextIdentifier = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    _circleRadius = computeCircleRadius(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _makeTeams,
                child: const Text('Divide'),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _teamAmount = min(_teamAmount! + 1, teamColors.length);
                  });
                },
              ),
              Text("$_teamAmount Teams"),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    _teamAmount = max(_teamAmount! - 1, 2);
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _reset,
                child: const Text('Reset'),
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
                constraints: const BoxConstraints.expand(),
                color: Colors.lightBlueAccent,
                child: CustomPaint(
                  foregroundPainter: QuickTeamPainter(_persons!, _circleRadius),
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

class QuickTeamPainter extends CustomPainter {
  final List<PersonData> _persons;
  final double _circleRadius;

  QuickTeamPainter(this._persons, this._circleRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.style = PaintingStyle.fill;

    for (PersonData person in _persons) {
      paint.color = person.color;
      canvas.drawCircle(
          person.position + Offset(_circleRadius / 10, _circleRadius / 10),
          _circleRadius,
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.black12);
      canvas.drawCircle(person.position, _circleRadius, paint);

      final textPainter = TextPainter(
          text: TextSpan(
              text: person.identifier,
              style: TextStyle(
                  color: Colors.white, fontSize: _circleRadius * 0.75)),
          textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: _circleRadius * 2);
      textPainter.paint(
          canvas,
          person.position -
              Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
