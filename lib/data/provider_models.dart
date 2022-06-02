

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/data/database.dart';
import 'package:time_tracker/data/prefs.dart';
import 'package:time_tracker/objects/todo.dart';
import 'package:time_tracker/objects/type.dart';
import 'package:time_tracker/ui/pages/home_page.dart';
import 'package:time_tracker/utils/date_utils.dart';

import '../main.dart';

class DataModel{

  DatabaseHelper databaseHelper;
  Prefs prefs;

  List<Todo> todos = [];
  List<TodoType> todoTypes = [];
  int playing ;
  int todayScore;
  TodoType currentFocus;

  TimerService timerService;

  DataModel(this.timerService);


  static Future<DataModel> init(BuildContext context)async{
    DataModel dataModel = DataModel(TimerService.of(context));

    dataModel.databaseHelper = await DatabaseHelper.getDatabase();
    dataModel.prefs = await Prefs.getInstance();

    dataModel.todos = await dataModel.databaseHelper.queryAllTodos();
    dataModel.todoTypes = await dataModel.databaseHelper.queryAllTypes();
    dataModel.todayScore = dataModel.prefs.getScoreForToday();
    dataModel.currentFocus = dataModel.findTypeById(dataModel.prefs.getCurrentFocusId());


    dataModel.timerService = TimerService.of(context);

    dataModel.setPlaying(await dataModel.prefs.getCurrentActionId(), context,ad: false);

    return dataModel;
  }

  List<Todo> filterTodos(TodoType todoType,{bool hideChecked}){

    if(hideChecked==null)hideChecked=false;

    List<Todo> filteredTodos = List();

    todos.forEach((item){
      if(item.typeId==todoType.id){
        if((!hideChecked)||(!item.isChecked())){
          
          filteredTodos.add(item);
        }
        
      }
    });

    return filteredTodos;
  }
  Todo getCurrentPlaying(){
    Todo toreturn ;
    todos.forEach((item){
      if((item.id==playing)&&(item.id!=null)){
        toreturn=item;
      }
    });
    return toreturn;
  }

  setPlaying(int playingId,BuildContext context,{bool ad}){

    if(ad??true){

      for(int i = 0 ; i<todos.length ; i++){
        Todo ctodo = todos[i];
        
        if(ctodo.id==(playingId??playing)){

          if(playingId==null){
            ctodo.endTimes.add(getDateFromString(getStringFromDate(DateTime.now())));
          }else{
            if((playing!=playingId)&&(playing!=null)){
              Todo toStop = getCurrentPlaying();
              int index = todos.indexOf(toStop);
              toStop.endTimes.add(getDateFromString(getStringFromDate(DateTime.now())));
              timerService.reset();
              todo(index, toStop, context, CUD.Update);
            }

            ctodo.startTimes.add(getDateFromString(getStringFromDate(DateTime.now())));
          }
          todo(i, ctodo, context, CUD.Update); 
        }
      }

    }
    playing = playingId;

    if(playing!=null){
      timerService.start(duration: getDateFromString(getStringFromDate(DateTime.now())).difference(getCurrentPlaying().startTimes.last));
    }else{
      timerService.reset();
    }

    if(ad??true){
      prefs.setCurrentActionId(playingId);

      MyAppState.ss(context);
    }
  }

  setScore(int newScore,BuildContext context)async{
    todayScore = newScore;
    await prefs.setScoreForToday(newScore);
    MyAppState.ss(context);
  }

  setCurrentFocusId(TodoType newFocusId,BuildContext context)async{
    currentFocus = newFocusId;
    await prefs.setCurrentFocusId(newFocusId.id);
    MyAppState.ss(context);
  }

  todo(int index,Todo todo,BuildContext context,CUD cud,{bool pop})async{
    switch(cud){
      case CUD.Create:
        todos.add(todo);
        todos[todos.length-1].id=await databaseHelper.insertTodo(todo);
        break;
      case CUD.Update:
        todos[index]=todo;
        await databaseHelper.updateTodo(todo);
        break;
      case CUD.Delete:
        todos.remove(todo);
        await databaseHelper.deleteTodo(todo.id);
        break;
    }
    if(pop??false){
      Navigator.pop(context);
      Future.delayed(Duration(seconds: 1)).then((v){
        MyAppState.ss(context);
      });
    }else{
      MyAppState.ss(context);
    }
    
  }

  type(int index,TodoType todoType,BuildContext context,CUD cud)async{
    switch(cud){
      
      case CUD.Create:
        todoTypes.add(todoType);
        todoTypes[todoTypes.length-1].id= await databaseHelper.insertType(todoType);
        break;
      case CUD.Update:
        todoTypes[index]=todoType;
        await databaseHelper.updateType(todoType);
        break;
      case CUD.Delete:
        todoTypes.removeAt(index);
        await databaseHelper.deleteType(todoType.id);
        break;
    }
    MyAppState.ss(context);
  }

  TodoType findTypeById(int id){
    TodoType toreturn = TodoType(name: 'Nothing', color: Colors.transparent.value);
    todoTypes.forEach((item){
      if(item.id==id){
        toreturn=item;
      }
    });
    return toreturn;
  }

  Todo findTodoByName(String name){
    Todo toreturn = Todo(name: 'Nothing', value: Value.Nothing);
    todos.forEach((item){
      if(item.name==name){
        toreturn=item;
      }
    });
    return toreturn;
  }

  List<Event> getDataSource({@required int year,@required int month,@required int day}) {
    final timestamps = <Event>[];

    todos.forEach((item){
      for(int i = 0 ; i<item.startTimes.length ; i++){
        DateTime startTime = item.startTimes[i];
        DateTime endTime;

        if(i+1==item.startTimes.length){
          //last
          if(item.startTimes.length!=item.endTimes.length){
            //isn't finished
            endTime= getDateFromString(getStringFromDate(DateTime.now()));
          }else{
            endTime = item.endTimes[i];
          }
        }else{
          endTime = item.endTimes[i];
        }

        if(startTime.day!=endTime.day){
          startTime = DateTime(endTime.year,endTime.month,endTime.day,0);
        }

        Color color;
        TodoType todoType = findTypeById(item.typeId);
        if(todoType==null){
          color = Colors.transparent;
        }else{
          color = Color(todoType.color);
        }
        if(endTime.year==year&&endTime.month==month&&endTime.day==day){
          timestamps.add(Event(endTime: endTime,startTime: startTime,title: item.name,color: color));
        }

      }
    });
    return timestamps;
  }

  List<TodoType> findTypesByDate(DateTime dateTime,{bool notByDate}) {

    if(notByDate==null){
      notByDate=false;
    }


    List<TodoType> toreturn = List();

    todoTypes.forEach((item){
      if(notByDate){
        if(!item.isOnDate(dateTime)){
          toreturn.add(item);
        }
      }else{
        if(item.isOnDate(dateTime)){
          toreturn.add(item);
        }
      }
    });

    return toreturn;
  }

}

enum CUD{
  Create,Update,Delete,
}