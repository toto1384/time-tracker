import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracker/utils/date_utils.dart';

class Prefs{

  static Prefs _instance;
  static Future<Prefs> getInstance()async{

    if(_instance==null){
      _instance = Prefs();
    }

    if(_instance.sharedPreferences==null){
      _instance.sharedPreferences= await SharedPreferences.getInstance();
    }

    return _instance;

  }


  SharedPreferences sharedPreferences;

  getCurrentActionId(){
    return sharedPreferences.getInt(_PrefsValues.currentActionId);
  }

  setCurrentActionId(int id)async{
    await sharedPreferences.setInt(_PrefsValues.currentActionId, id);
  }


  int getScoreForToday(){

    return sharedPreferences.getInt(getStringFromDate(DateTime.now()).split(' ').last)??0;
  }

  setScoreForToday(int score)async{
    await sharedPreferences.setInt(getStringFromDate(DateTime.now()).split(' ').last, score);
  }

  int getCurrentFocusId(){
    return sharedPreferences.getInt(_PrefsValues.currentFocusId);
  }

  setCurrentFocusId(int id)async{
    await sharedPreferences.setInt(_PrefsValues.currentFocusId, id);
  }


}

class _PrefsValues{
  static final currentActionId = 'cai';
  static final currentFocusId = 'cfi';
}