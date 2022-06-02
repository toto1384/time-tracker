import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/data/provider_models.dart';
import 'package:time_tracker/objects/todo.dart';
import 'package:time_tracker/objects/type.dart';
import 'package:time_tracker/ui/pages/todo_page.dart';
import 'package:time_tracker/utils/get_popup_and_sheets_utils.dart';
import 'package:time_tracker/utils/get_widget_utils.dart';
import 'package:time_tracker/utils/typedef_and_enums_utils.dart';
import 'package:time_tracker/utils/utils.dart';

class TodoWidget extends StatefulWidget {
  final Todo todo;
  final TodoType todoType;
  final BuildContext buildContext;
  TodoWidget({Key key,@required this.todo,@required this.todoType,@required this.buildContext}) : super(key: key);

  @override
  _TodoWidgetState createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  

  @override
  Widget build(BuildContext context) {
    DataModel dataModel = Provider.of<DataModel>(context);

    int todoIndex = dataModel.todos.indexOf(widget.todo);
    int typeIndex = dataModel.todoTypes.indexOf(widget.todoType);

    bool isPlaying = (dataModel.playing==widget.todo.id)&&(widget.todo.id!=null);

    return ListTile(
      onTap: (){
        launchPage(context, TodoPage(todo: widget.todo,todoType: widget.todoType,todoInd: todoIndex,));
      },
      onLongPress: (){
        showTodoEditBottomSheet(widget.buildContext,todoInd: todoIndex,todoType: typeIndex);
      },
      leading: getFlareCheckbox(
        widget.todo.isChecked(),
        onTap: (){
          widget.todo.toggle();
          dataModel.todo(todoIndex, widget.todo, context, CUD.Update);

          int toadd;

          if(widget.todo.isChecked()){
            toadd = widget.todo.getValueInt()*10;
          }else{
            toadd = 0 - (widget.todo.getValueInt()*10);
          }

          dataModel.setScore(dataModel.todayScore+toadd, context);
        }
      ),
      subtitle: getText(widget.todo.getValueString(),),
      title: getText(widget.todo.name,textType: TextType.textTypeSubNormal),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Visibility(
              visible: widget.todo.childs.length!=0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  getIcon(Icons.child_care),
                  getText(widget.todo.childs.length.toString()),
                ],
              ),
            ),
          ) ,
          IconButton(
            icon: getIcon(isPlaying?Icons.stop:Icons.play_arrow,size: 16), 
            onPressed: (){
              setState(() {
                dataModel.setPlaying(isPlaying?null:widget.todo.id, context);
              });
              
            }
          ),
        ],
      ),
    );
  }


}