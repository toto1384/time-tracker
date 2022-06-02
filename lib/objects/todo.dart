

import 'package:flutter/cupertino.dart';
import 'package:time_tracker/utils/date_utils.dart';

class Todo{
  
  Duration timeEstimated;
  List<DateTime> startTimes;
  List<DateTime> endTimes;
  int typeId;
  int id;
  String name;
  List<Subtask> childs;
  Value value;
  DateTime lastCheck;
  int repeatEvery;

  Todo({this.endTimes,this.startTimes, this.timeEstimated, this.typeId,this.id,@required this.name, @required this.value, this.lastCheck,this.repeatEvery,this.childs});

  toggle(){
    if(lastCheck == null){
      lastCheck = getDateFromString(getStringFromDate(DateTime.now()));
    }else{
      lastCheck = null;
    }
  }

  isChecked() {
    if (lastCheck == null) {
      return false;
    } else {
      if (repeatEvery == 0) return true;
      if (getTodayFormated()
          .difference(lastCheck)
          .inDays > repeatEvery) {
        return false;
      } else {
        return true;
      }
    }
  }



  static List<DateTime> dateTimesFromString(String dates){
    List<String> listdates = dates.split(',');

    List<DateTime> dateTimes = List();

    listdates.forEach((item){
      if(item!=null&&item!=''){
        dateTimes.add(getDateFromString(item));
      }
    });

    return dateTimes;
  }


  static String stringFromDateTimes(List<DateTime> dateTimes){
    String dateTimesString = '';

    dateTimes.forEach((item){
      dateTimesString = dateTimesString+ ',${getStringFromDate(item)}';
    });
    return dateTimesString;
  }

  static fromMap(Map map){
    return Todo(
      timeEstimated: Duration(seconds:  map['timeEstimated']),
      startTimes: dateTimesFromString(map['startTime']),
      endTimes: dateTimesFromString(map['endTime']), 
      typeId: map['typeId'], 
      id: map['id'], 
      name: map['name'], 
      value: getIntValue(map['value']),
      lastCheck: getDateFromString(map['lastChecked']),
      childs: getChilds(map['childs']),
      repeatEvery: map['repeatEvery'],
    );
  }

  toMap(){

    if(childs==null){
      childs = List<Subtask>();
    }

    String childsString = '';

    childs.forEach((subtask){
      String valueString = '';

      if(subtask.checked){
        valueString = '•${subtask.name}';
      }else{
        valueString = subtask.name;
      }
      childsString = '$childsString,$valueString';
    });

    return {
      'timeEstimated':timeEstimated.inSeconds,
      'startTime':stringFromDateTimes(startTimes),
      'endTime':stringFromDateTimes(endTimes),
      'typeId':typeId,
      'id':id,
      'name':name,
      "value":getValueInt(),
      'lastChecked':getStringFromDate(lastCheck),
      'childs':childsString,
      'repeatEvery':repeatEvery,
    };
  }

  static List<Subtask> getChilds(String str) {

    if(str == null||str.trim()==''){
      return List<Subtask>();
    }

    List<String> todos = str.split(',');

    List<Subtask> todosMap = List();

    todos.forEach((item){
      if(item!=''){
        List<String> strlist=item.split('•');
        if(strlist.length>1){

          todosMap.add(Subtask(true,strlist.last));
        }else{

          todosMap.add(Subtask(false, item));
        }
      }
    });

  return todosMap;

  }

  int getMinutesTaken() {
    int minutesTaken = 0;

      for(int i = 0 ; i<startTimes.length ; i++){
        DateTime startTime = startTimes[i];
        DateTime endTime;

        if(i+1==startTimes.length){
          //last
          if(startTimes.length!=endTimes.length){
            //isn't finished
            endTime= getDateFromString(getStringFromDate(DateTime.now()));
          }else{
            endTime = endTimes[i];
          }
        }else{
          endTime = endTimes[i];
        }

        minutesTaken = minutesTaken + endTime.difference(startTime).inMinutes;

      }

    return minutesTaken;
  }

}

class Subtask{
  bool checked;
  String name;
  Subtask(this.checked,this.name);
}

enum Value{
  Negative,
  Nothing,
  Medium,
  Large,
  XtraLarge,
}