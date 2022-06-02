
import 'package:flutter/cupertino.dart';

class TodoType{

  int id;
  String name;
  int color;
  int repeatEvery;

  TodoType({this.id,@required this.name, @required this.color,this.repeatEvery});

  isOnDate(DateTime dateTime){
    bool isToday = false;

    if(repeatEvery!=0){
      DateTime startOfMonth = DateTime(dateTime.year,dateTime.month,1);

      while(startOfMonth.add(Duration(days: repeatEvery)).day<30){
        startOfMonth = startOfMonth.add(Duration(days: repeatEvery));

        if(startOfMonth.day==dateTime.day){
          isToday=true;
          break;
        }

      }
    }
    
    return isToday;
  }

  static fromMap(Map map){
    return TodoType(
      id: map['id'],
      color: map['color'],
      name: map['name'],
      repeatEvery: map['repeatEvery']
    );
  }

  toMap(){
    return {
      'id' : id,
      'color' : color,
      'name': name,
      'repeatEvery' : repeatEvery,
    };
  }

}