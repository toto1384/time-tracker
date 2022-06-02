import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/data/provider_models.dart';
import 'package:time_tracker/ui/pages/home_page.dart';
import 'package:time_tracker/utils/get_widget_utils.dart';

void main() {
  final timerService = TimerService();
  runApp(
    TimerServiceProvider( // provide timer service to all widgets of your app
      service: timerService,
      child: MyApp()
    ),
  );
}

class TimerService extends ChangeNotifier {
  Stopwatch _watch;
  Timer _timer;

  Duration currentDuration = Duration.zero;
  Duration offset = Duration.zero;

  bool get isRunning => _timer != null;

  TimerService() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    currentDuration = _watch.elapsed + offset;

    // notify all listening widgets
    notifyListeners();
  }

  void start({Duration duration}) {
    if (_timer != null) return;

    if(duration!=null){
      offset=duration;
    }

    _timer = Timer.periodic(Duration(seconds: 1), _onTick);
    _watch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    currentDuration = _watch.elapsed;
    offset=Duration.zero;

    notifyListeners();
  }

  void reset() {
    stop();
    _watch.reset();
    currentDuration = Duration.zero;
    offset = Duration.zero;

    notifyListeners();
  }

   static TimerService of(BuildContext context) {
    var provider = context.dependOnInheritedWidgetOfExactType<TimerServiceProvider>();
    TimerService timerService =  provider.service;
    return timerService;
  }
}

class TimerServiceProvider extends InheritedWidget {
  const TimerServiceProvider({Key key, this.service, Widget child}) : super(key: key, child: child);

  final TimerService service;

  @override
  bool updateShouldNotify(TimerServiceProvider old) => service != old.service;
}


class MyApp extends StatefulWidget {
  static final bool isDarkMode = true;
  static bool snapToEnd = true;
  MyApp({Key key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  static Function _toRun; 

  static registerPage(Function callSetState){
    _toRun = callSetState;
  }

  static unregisterPage(){
    _toRun=null;
  }

  static ss(BuildContext context){
    final MyAppState state =
        context.findAncestorStateOfType<MyAppState>();
    state.setState((){});
    if(_toRun!=null)_toRun();
  }
  @override
  Widget build(BuildContext context) {
    return FutureProvider<DataModel>(
      create: (c){return DataModel.init(context);},
      initialData: DataModel(TimerService.of(context)),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        darkTheme: getAppDarkTheme(),
        themeMode: ThemeMode.dark,
        home: HomePage(),
      ),
    );
  }
}