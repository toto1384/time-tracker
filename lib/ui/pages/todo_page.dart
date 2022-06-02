import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/data/provider_models.dart';
import 'package:time_tracker/icon_pack_icons.dart';
import 'package:time_tracker/main.dart';
import 'package:time_tracker/objects/todo.dart';
import 'package:time_tracker/objects/type.dart';
import 'package:time_tracker/ui/rosse_scaffold.dart';
import 'package:time_tracker/utils/date_utils.dart';
import 'package:time_tracker/utils/get_popup_and_sheets_utils.dart';
import 'package:time_tracker/utils/get_widget_utils.dart';
import 'package:time_tracker/utils/typedef_and_enums_utils.dart';
import 'package:time_tracker/utils/utils.dart';
import 'package:time_tracker/utils/values_utils.dart';

class TodoPage extends StatefulWidget {
  final Todo todo;
  final int todoInd;
  final TodoType todoType;
  TodoPage({Key key,@required this.todo,@required this.todoType,@required this.todoInd}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {

  int _selectedIndex = 0 ;

  @override
  void initState() {
    super.initState();
    MyAppState.registerPage((){
      setState(() {
        
      });
    });
  }

  @override
  void dispose()async {
    super.dispose();
    MyAppState.unregisterPage();
  }

  List<Widget> getItems(){
    if(_selectedIndex==0){
      return List.generate(items.length, (ind){
                  Subtask subtask = items[ind];
                  return ListTile(
                    leading: getFlareCheckbox(
                      subtask.checked,
                      onTap: (){
                        setState(() {
                          subtask.checked=!subtask.checked;
                        });
                        items[ind]=subtask;
                        dataModel.setScore(subtask.checked?dataModel.todayScore+widget.todo.getValueInt():dataModel.todayScore-widget.todo.getValueInt(), context);
                        dataModel.todo(widget.todoInd, widget.todo, context, CUD.Update);
                      }
                    ),
                    title: getText(subtask.name),
                    onTap: (){
                      showSubtaskEditBottomSheet(context, todo: widget.todo,subtask: subtask);
                    },
                    trailing: IconButton(
                      icon: getIcon(Icons.delete), 
                      onPressed: (){
                        widget.todo.childs.remove(subtask);
                        dataModel.todo(widget.todoInd, widget.todo, context, CUD.Update);
                      }
                    ),
                  );
                });
    }else if(_selectedIndex==1){
      return List.generate(widget.todo.startTimes.length, (ind){
        bool show = (widget.todo.endTimes.length!=0)&&(widget.todo.endTimes.length>ind);


      });
    }else{
      return [getPadding(getText(getPercentDone()+'% done',textType: TextType.textTypeGigant,isCentered: true)),getText('Time estimated: ${widget.todo.timeEstimated.inMinutes} minutes\n\nTime taken: ${widget.todo.getMinutesTaken()} minutes\n\n\n Difference: ${widget.todo.timeEstimated.inMinutes-widget.todo.getMinutesTaken()} minutes',textType: TextType.textTypeTitle,isCentered: true)];
    }
  }

  String getPercentDone(){
    int big = widget.todo.childs.length;

    List<Subtask> uncheckedItems = List();
    widget.todo.childs.forEach((item){
        if(!item.checked){
          uncheckedItems.add(item);
        }
      });

    int small = big-uncheckedItems.length;

    double factor = 100 / big.toDouble();

    double percentDone =  (small.toDouble()*factor);

    return doubleToStringOneDecimal(percentDone);
  }

  DataModel dataModel;

  List<Subtask> items;
  bool hideChecked = false;

  @override
  Widget build(BuildContext context) {
    dataModel = Provider.of<DataModel>(context);

    if(hideChecked){
      items =[];
      widget.todo.childs.forEach((item){
        if(!item.checked){
          items.add(item);
        }
      });
    }else{
      items = widget.todo.childs;
    }

    return RosseScaffold(
      widget.todo.name,
      color: Color(widget.todoType.color),
      primaryItems: getItems(), 
      secondaryItems: [],
      onMorePressed: (){
        showDistivityModalBottomSheet(context, (ctx,ss){
          return getPadding(Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: getIcon(Icons.check_circle_outline),
                title: getText(hideChecked?'Show Checked':'Hide Checked'),
                onTap: (){
                  setState(() {
                    hideChecked=!hideChecked;
                  });
                },
              )
            ],
          ));
        });
      },
      fab: FloatingActionButton.extended(
        label: getText('Add subtask'),
        icon: getIcon(IconPack.add),
        onPressed: (){
          showSubtaskEditBottomSheet(context, todo: widget.todo);
        },
      ),
      bottomAppBar: BubbleBottomBar(
          opacity: .2,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() {
                      _selectedIndex = index; 
          }),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          elevation: 8,
          backgroundColor: MyColors.color_black, //new
          hasInk: true, 
          items: [
            BubbleBottomBarItem(
                icon: getIcon(Icons.check_circle_outline),
                title: Text('Subtasks'),
                backgroundColor: Color(widget.todoType.color)
            ),
            BubbleBottomBarItem(
              icon: getIcon(Icons.timer),
              title: Text('Timestamps'),
              backgroundColor: Color(widget.todoType.color),
            ),
            BubbleBottomBarItem(
                icon: getIcon(Icons.info_outline),
                title: Text('Info'),
                backgroundColor: Color(widget.todoType.color)
            ),
          ],
        ),
      backEnabled: true,
      isTitleCentered: true,
    );
  }
}