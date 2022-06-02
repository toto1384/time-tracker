
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_tracker/ui/pages/home_page.dart';

DateFormat _getDateFormat(){
  
  return DateFormat('HH:mm:ss : dd-MM-yy');
}

DateTime getDateFromString(String string){
  if(string==null||string.trim()==''){
    return null;
  }

  return _getDateFormat().parse(string);
}

String getStringFromDate(DateTime dateTime){
  if(dateTime==null){
    return '';
  }else{
    return _getDateFormat().format(dateTime);
  }
  
}

getTextFromDuration(Duration duration){

  return '$duration'.split('.')[0];
}

String minuteOfDayToHourMinuteString(int minuteOfDay) {
  return "${(minuteOfDay ~/ 60).toString().padLeft(2, "0")}"
      ":"
      "${(minuteOfDay % 60).toString().padLeft(2, "0")}";
}

getHours(int duration){
    double inh = duration/60;

    List<String> l =  inh.toString().split('.');
    String toreturn = l[0];
    if(l.length!=1){
      toreturn = toreturn +'.'+ l[1][0];
    }
    return toreturn;
  }

DateTime getTodayFormated(){
  return getDateFromString(getStringFromDate(DateTime.now()));
}

addDuration(Duration d1,Duration d2){
  return Duration(seconds: d1.inSeconds+d2.inSeconds);
}
subtractDuration(Duration d1,Duration d2){
  return Duration(seconds: d1.inSeconds-d2.inSeconds);
}

String getDateName(DateTime dateTime) {

  if(dateTime.day==DateTime.now().day){
    return 'Today';
  }else if(dateTime.day-1==DateTime.now().day){
    return 'Tommorow';
  }else if(dateTime.day+1==DateTime.now().day){
    return 'Yesterday';
  }else{
    return '${dateTime.day} : ${dateTime.month}';
  }
}

List<Event> getEventsPlusUnTracked(List<Event> allEvents,DateTime dateTime){
  List<Event> toShowEvent = List();

  int totalMinutesTracked = 0;

  allEvents.forEach((item){
    totalMinutesTracked = item.duration;
    bool add = true;
    toShowEvent.forEach((item1){
      if(item.title==item1.title){
        add=false;
        item1.duration = item1.duration+item.duration;
      }
    });
    if(add){
      toShowEvent.add(item);
    }
  });

  toShowEvent.add(Event.raw(dateTime.year,dateTime.month, dateTime.day, (24*60)-totalMinutesTracked,));

  return toShowEvent;
}

Duration getTimeLeft(Duration timeEstimated,List<DateTime> startTimes,List<DateTime> endTimes){
  Duration taken = Duration.zero;

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

    taken = addDuration(taken, endTime.difference(startTime));

  }

  return subtractDuration(timeEstimated, taken);
}


int getMinutesTaken(List<DateTime> startTimes,List<DateTime> endTimes) {
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

//  static isChecked(DateTime lastChecked,int resetTime){
//    if(lastChecked==null){
//      return false;
//    }else{
//      bool checked =  !lastChecked.isBefore(getDateFromString(getStringFromDate(DateTime.now())).subtract(getResetDuration(resetTime)));
//      return checked;
//    }
//  }



//value

int getValueInt(Value value){
  switch(value){
    case Value.Negative:
      return -1;
    case Value.Nothing:
      return 0;
    case Value.Medium:
      return 1;
    case Value.Large:
      return 2;
    case Value.XtraLarge:
      return 3;
    default:return 4;
  }
}


String getValueString(Value value){
  switch(value){
    case Value.Negative:return 'Negative';
    case Value.Nothing:
      return 'Nothing';
    case Value.Medium:
      return 'Medium';
    case Value.Large:
      return 'Large!';
    case Value.XtraLarge:
      return 'XTRA-LARGE!!';
    default:return '';
  }
}

Value getIntValue(int val){
  switch(val){
    case -1: return Value.Negative;
    case 0:return Value.Nothing;
    case 1:return Value.Medium;
    case 2:return Value.Large;
    case 3:return Value.XtraLarge;
    default :return null;
  }
}

enum Value{
  Negative,
  Nothing,
  Medium,
  Large,
  XtraLarge,
}

//For this project 