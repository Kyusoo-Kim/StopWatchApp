import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Stop Watch App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: StopWatchPage());
  }
}

class StopWatchPage extends StatefulWidget {

  @override
  _StopWatchPageState createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {

  StopWatchState _currentState;
  void setStopWatchState(StopWatchState state) => this._currentState = state;

  Timer _timer;
  var _time = 0;
  var sec = 0;
  var ms = '00';
  List<String> _lapTimes = [];

  @override
  void initState()
  {
    setStopWatchState(InitState());
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('StopWatch')),
      body: _buildBody(),
      bottomNavigationBar: BottomAppBar(child: Container(height: 50)),
      floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() {
                _currentState.playPause(this);
              }),
          child: _currentState.buildPlayPauseIcon()
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    sec = _time ~/ 100; // sec
    ms = '${_time % 100}'.padLeft(2, '0'); // milliseconds

    return Center(
      child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text('$sec', style: TextStyle(fontSize: 50)),
                      Text('$ms')
                    ],
                  ),
                  Container(
                    width: 100,
                    height: 200,
                    child: ListView(
                      children: _lapTimes.map((time) => Text(time)).toList(),
                    ),
                  )
                ],
              ),
              Positioned(
                  left: 10,
                  bottom: 10,
                  child: FloatingActionButton(
                      backgroundColor: Colors.deepOrange,
                      onPressed: (){
                        setState(() {
                          _currentState.reset(this);
                        });
                      },
                      child: _currentState.buildResetIcon()
                  )
              ),
              Positioned(
                  right: 10,
                  bottom: 10,
                  child: FloatingActionButton(
                      backgroundColor: Colors.green,
                      onPressed: () {
                        setState(() {
                          _currentState.recordLapTime(this);
                        });


                      },
                      child: _currentState.buildRecordLapTime()
                  )
              )
            ],
          )),
    );
  }

  void raiseEvent(StopWatchEvent evt) {
    switch(evt)
    {
      case StopWatchEvent.PLAY_PAUSE:
        _currentState.playPause(this);
        break;
      case StopWatchEvent.RECORD_LAP_TIME:
        _currentState.recordLapTime(this);
        break;
      case StopWatchEvent.RESET:
        _currentState.reset(this);
        break;
      default:
        break;
    }
  }

  void reset() {
    _timer?.cancel();
    _lapTimes.clear();
    _time = 0;
  }

  void recordLapTime() {
    String strTime = '$sec.$ms';
    _lapTimes.insert(0, '${_lapTimes.length + 1} 등 $strTime');
  }

 void startTimer() {
   _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
     setState(() {
       _time++;
     });
   });
 }

 void pause() {
    _timer?.cancel();
 }
}

enum StopWatchEvent {
  PLAY_PAUSE,
  RECORD_LAP_TIME,
  RESET
}

abstract class StopWatchState
{
  void playPause(_StopWatchPageState app);
  void reset(_StopWatchPageState app);
  void recordLapTime(_StopWatchPageState app);

  Widget buildPlayPauseIcon();
  Widget buildResetIcon();
  Widget buildRecordLapTime();
}

class InitState extends StopWatchState
{
  static const stateName = "Init";

  void playPause(_StopWatchPageState app) {
    print("[$stateName] Start");
    app.startTimer();
    app.setStopWatchState(RunningState());
  }
  void reset(_StopWatchPageState app) {}
  void recordLapTime(_StopWatchPageState app) {}

  Widget buildPlayPauseIcon() => Icon(Icons.play_arrow);
  Widget buildResetIcon() => Opacity(opacity: 0.0, child: Icon(Icons.rotate_left));
  Widget buildRecordLapTime() => Opacity(opacity: 0.0, child: Icon(Icons.add_alarm));
}

class RunningState extends StopWatchState
{
  static const stateName = "Running";

  void playPause(_StopWatchPageState app) {
    print("[$stateName] Pause");
    app.pause();
    app.setStopWatchState(PauseState());
  }
  void reset(_StopWatchPageState app) {
    print("[$stateName] Reset");
    app.reset();
    app.setStopWatchState(InitState());
  }
  void recordLapTime(_StopWatchPageState app) {
    print("[$stateName] Record Lap Time");
    app.recordLapTime();
  }

  Widget buildPlayPauseIcon() => Icon(Icons.pause);
  Widget buildResetIcon() => Icon(Icons.rotate_left);
  Widget buildRecordLapTime() => Icon(Icons.add_alarm);
}

class PauseState extends StopWatchState
{
  static const stateName = "Pause";

  void playPause(_StopWatchPageState app) {
    print("[$stateName] ReStart");
    app.startTimer();
    app.setStopWatchState(RunningState());
  }
  void reset(_StopWatchPageState app) {
    print("[$stateName] Reset");
    app.reset();
    app.setStopWatchState(InitState());
  }
  void recordLapTime(_StopWatchPageState app) {}

  Widget buildPlayPauseIcon() => Icon(Icons.play_arrow);
  Widget buildResetIcon() => Icon(Icons.rotate_left);
  Widget buildRecordLapTime() => Opacity(opacity: 0.0, child: Icon(Icons.add_alarm));
}