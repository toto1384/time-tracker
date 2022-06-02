import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/data/provider_models.dart';
import 'package:time_tracker/objects/todo.dart';
import 'package:time_tracker/objects/type.dart';
import 'package:time_tracker/ui/pages/home_page.dart';
import 'package:time_tracker/ui/rosse_radio_group.dart';
import 'package:time_tracker/utils/date_utils.dart';

import '../icon_pack_icons.dart';
import '../main.dart';
import 'get_widget_utils.dart';
import 'typedef_and_enums_utils.dart';
import 'values_utils.dart';

showDistivityPopupMenu(BuildContext context,{@required GlobalKey globalKey,@required ReturnChild popupContentBuilder,bool above}){

  // try not to lose your braincells challenge

  if(above==null){
    above=false;
  }

  Completer<OverlayEntry> future = Completer();

  Offset positionRed = getWidgetPosition(globalKey);

  future.complete(
    OverlayEntry(
      builder: (ctx){
        return getPadding(Stack(
            children: <Widget>[
              Positioned.fill(
                child: GestureDetector(
                  onTap: (){
                    future.future.then((entry){
                      entry.remove();
                    });
                  },
                  child: Container(
                    color: MyColors.color_black_darker.withOpacity(0.7),
                  ),
                ),
              ),
              Positioned(
                top: above?positionRed.dy-30:positionRed.dy,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Card(
                    elevation: 10,
                    color: getOverFlowColor(),
                    shape: getShape(),
                    child: popupContentBuilder(ctx,(){
                      future.future.then((entry){
                        entry.remove();
                      });
                    }),
                  ),
                ),
              ),
            ],
          ),);
      },
    )
  );

  future.future.then((entry){
    Overlay.of(context).insert(entry);
  });
}

showDistivityDialog(BuildContext context,{@required List<Widget> actions ,@required String title,@required StateGetter stateGetter}){

  showDialog(context: context,builder: (ctx){
    return StatefulBuilder(
      builder: (ctx,setState){
        return AlertDialog(
          backgroundColor: MyApp.isDarkMode?MyColors.color_black_darker:Colors.white,
          shape: getShape(),
          actions: [
            getPadding(Row(
                mainAxisSize: MainAxisSize.min,
                children: actions
              ),)
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getPadding(getText(title,textType: TextType.textTypeSubtitle),vertical: 20,horizontal: 0),
              stateGetter(context,(func){
                setState((){
                  func();
                });
              }),
            ],
          ),
        );
      },
    );
  });
}

showDistivityModalBottomSheet(BuildContext context, StateGetter stateGetter,{bool hideHandler}){

  if(hideHandler==null){
    hideHandler=false;
  }

  showModalBottomSheet(
    shape: getShape(bottomSheetShape: true),
    backgroundColor: getOverFlowColor(),
    isScrollControlled: true,context: context,builder: (ctx){
      return StatefulBuilder(
        builder: (ctx,setState){
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Visibility(
                    visible: !hideHandler,
                    child: getPadding(GestureDetector(
                        onTap: (){Navigator.pop(context);},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            getSkeletonView(75, 4)
                          ],
                        ),
                      ),vertical: 15,horizontal: 0),
                  ),
                  stateGetter(context,(func){
                      setState((){
                        func();
                      });
                    }),
                ],
              ),
            ),
          );
        },
      );
  },
  );
}

showDistivityDatePicker(BuildContext context,{@required Function(DateTime) onDateSelected}){

  Future<DateTime> dateTime =showDatePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime(2050),
    initialDate: DateTime.now(),
  );

  dateTime.then((onValue){
    onDateSelected(onValue);
  });

}

showTodoEditBottomSheet(BuildContext context,{int todoInd,int todoType,Function onUpdate}){

  Todo todo;
  DataModel dataModel = Provider.of<DataModel>(context,listen: false);

  if(todoInd==null){
    todo = Todo(name: '', value: Value.Nothing, typeId: todoType,startTimes: [],endTimes: [],timeEstimated: Duration.zero,);
  }else{
    todo = dataModel.todos[todoInd];
  }

  TextEditingController textEditingController = TextEditingController(text: todo.name);
  TextEditingController repeatEveryTEC = TextEditingController(text: todo.repeatEvery!=null?todo.repeatEvery.toString():null);

  showDistivityModalBottomSheet(context, (ctx,ss){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              getTextField(textEditingController, width: 300,focus: true,hint: 'Your todo goes here'),
              getButton('Save', onPressed: (){
                todo.name=textEditingController.text;
                todo.repeatEvery = int.parse(repeatEveryTEC.text==''?'0':repeatEveryTEC.text);
                if(todoInd==null){
                  dataModel.todo(0, todo, context, CUD.Create);
                }else{
                  dataModel.todo(todoInd, todo, context, CUD.Update);
                }
                if(onUpdate!=null){onUpdate();}
                Navigator.pop(context);
              }),
            ],
          ),
        ),

        Row(
          children: <Widget>[
            getPadding(getRichText(['Time estimated:  ','${todo.timeEstimated.inMinutes} minutes'], [TextType.textTypeSubtitle,TextType.textTypeNormal])),
            getButton('Edit', onPressed: ()=>showPickDurationBottomSheet(context, (dur){
              ss((){
                todo.timeEstimated=dur;
              });
            }),variant: 2),
          ],
        ),

        getText('Value',textType: TextType.textTypeSubtitle),

        Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: RosseRadioGroup(
              items: {
                'Negative':todo.value==Value.Negative,
                'Nothing':todo.value==Value.Nothing,
                'Medium':todo.value==Value.Medium,
                'Large':todo.value==Value.Large,
                'XtraLarge':todo.value==Value.XtraLarge,
              },
              isBig: false, 
              onSelected: (i,s){
                ss((){
                  switch(i){
                    case 0:todo.value=Value.Negative;break;
                    case 1:todo.value=Value.Nothing; break;
                    case 2:todo.value=Value.Medium; break;
                    case 3:todo.value=Value.Large; break;
                    case 4:todo.value=Value.XtraLarge; break;
                  }
                });
              }
            ),
          ),
        ),

        getPadding(getTextField(repeatEveryTEC, width: 250,hint: 'Repeat every',variant: 2,textInputType: TextInputType.number)),

        getPadding(getButton('Delete todo', onPressed: (){dataModel.todo(todoInd, todo, context, CUD.Delete,pop: true);if(onUpdate!=null){onUpdate();}}),vertical: 15),





      ],
    );
  });
}

showSubtaskEditBottomSheet(BuildContext context,{Subtask subtask,@required Todo todo}){

  DataModel dataModel = Provider.of<DataModel>(context,listen: false);
  int todoIndex = dataModel.todos.indexOf(todo);

  TextEditingController textEditingController = TextEditingController(text: subtask==null?'':subtask.name);
  showDistivityModalBottomSheet(context, (ctx,ss){
    return getPadding(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        getTextField(textEditingController, width: 300,focus: true),
        IconButton(icon: getIcon(IconPack.send), onPressed: (){
          ss(() {
            if(subtask==null){
              todo.childs.add(Subtask(false, textEditingController.text));
              textEditingController.text='';
              dataModel.todo(todoIndex, todo, context, CUD.Update);
            }else{
              todo.childs.add(subtask..name=textEditingController.text);
              dataModel.todo(todoIndex, todo, context, CUD.Update,pop: true);
            }
            
          });
        }),
      ],
    ));
  });
}

showTypeEditBottomSheet(BuildContext context,{int typeInd}){

  DataModel dataModel = Provider.of<DataModel>(context,listen: false);

  TodoType todoType ;

  if(typeInd==null){
    todoType = TodoType(name: '', color: MyColors.color_secondary.value);
  }else{
    todoType = dataModel.todoTypes[typeInd];
  }
  TextEditingController textEditingController = TextEditingController(text: todoType.name);
  TextEditingController repeatEveryTEC = TextEditingController();

  showDistivityModalBottomSheet(context, (ctx,ss){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            getTextField(textEditingController, width: 300,hint: 'Your type goes here',focus: true),
            getButton(
              'Save', 
              onPressed: (){
                todoType.name=textEditingController.text;
                todoType.repeatEvery = int.parse(repeatEveryTEC.text==''?'0':repeatEveryTEC.text);
                dataModel.type(typeInd, todoType, context, typeInd==null?CUD.Create:CUD.Update);
                Navigator.pop(context);
              }
            )
          ],
        ),

        getPadding(Container(
          width: 300,
          height: 200,
          child: MaterialColorPicker(
              allowShades: true,
              onColorChange: (Color color) {
                  ss((){todoType.color=color.value;});
              },
              selectedColor: Color(todoType.color)
          ),
        ),vertical: 15),
        getPadding(getTextField(repeatEveryTEC, width: 250,hint: 'Repeat every',variant: 2,textInputType: TextInputType.number)),
        getPadding(getButton(
          'Delete', 
          onPressed: (){
            dataModel.type(typeInd, todoType, context, CUD.Delete);
            Navigator.pop(context);
          },
          variant: 2
        ),vertical: 15),
      ],
    );
  });
}


showPickDurationBottomSheet(BuildContext context,Function(Duration) onDurationPick){
  Duration _duration = Duration(hours: 0, minutes: 0);

  showDistivityDialog(
    context, 
    actions: [
      getButton('Save', onPressed: (){
        onDurationPick(_duration);
        Navigator.pop(context);
      }),
    ], 
    title: 'Pick Estimated Time', 
    stateGetter: (ctx,ss){
      return Center(
        child: DurationPicker(
          duration: _duration,
          onChange: (val) {
            ss(() => _duration = val);
          },
          snapToMins: 5.0,
        ),
      );
    }
  );
}

