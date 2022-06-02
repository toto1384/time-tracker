import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/data/provider_models.dart';
import 'package:time_tracker/icon_pack_icons.dart';
import 'package:time_tracker/objects/todo.dart';
import 'package:time_tracker/objects/type.dart';
import 'package:time_tracker/ui/rosse_scaffold.dart';
import 'package:time_tracker/ui/todo_widget.dart';
import 'package:time_tracker/utils/get_popup_and_sheets_utils.dart';
import 'package:time_tracker/utils/get_widget_utils.dart';
import 'package:time_tracker/utils/typedef_and_enums_utils.dart';
import 'package:time_tracker/utils/utils.dart';

import '../../main.dart';
import 'home_page.dart';

class TypePage extends StatefulWidget {

  final TodoType todoType;
  final Widget secItem;

  TypePage({Key key,@required this.todoType,this.secItem}) : super(key: key);

  @override
  _TypePageState createState() => _TypePageState();
}

class _TypePageState extends State<TypePage> {

  bool hideChecked = false;

  @override
  void initState() { 
    super.initState();
    MyAppState.registerPage((){
      setState(() {
        
      });
    });
  }

  @override
  void dispose(){
    super.dispose();
    MyAppState.unregisterPage();
  }

  DataModel dataModel;


  @override
  Widget build(BuildContext context) {

    dataModel = Provider.of<DataModel>(context);

    List<Todo> todos= dataModel.filterTodos(widget.todoType,hideChecked: hideChecked);

    return RosseScaffold(
      widget.todoType.name,
      isTitleCentered: true,
      color: Color(widget.todoType.color), 
      backEnabled: true,
      primaryItems: List<Widget>.generate(todos.length, (ind){
        return TodoWidget(
          todoType: widget.todoType,
          todo: todos[ind],
          buildContext: widget.secItem==null?context:context.findAncestorStateOfType<HomePageState>().context,
        );
      }), 
      secondaryItems: <Widget>[
        getPadding(getText('${getPercentDone()}% done',textType: TextType.textTypeGigant),vertical: 10),
        getPadding(getText( getHoursSpend() +' hours spend'),vertical: 5),
        getPadding(getText( getHoursLeft() + ' hours left'),vertical: 5),
        
      ],
      secondaryBodyAlwaysRed: true,
      expandedHeight: 250,
      fab : widget.secItem??FloatingActionButton.extended(
        onPressed: (){
          showTodoEditBottomSheet(context,todoType: widget.todoType.id,onUpdate: (){setState(() {
            
          });});
        }, 
        label: getText('Add todo'),
        icon: getIcon(IconPack.add),
      ),
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
    );
  }

  String getPercentDone(){
    int big = dataModel.filterTodos(widget.todoType).length;
    int small = big-dataModel.filterTodos(widget.todoType,hideChecked: true).length;

    double factor = 100 / big.toDouble();

    double percentDone =  (small.toDouble()*factor);

    return doubleToStringOneDecimal(percentDone);
  }

  String getHoursSpend(){
    List<Todo> allTodos = dataModel.filterTodos(widget.todoType);

    double hoursSpend = 0;

    allTodos.forEach((item){
      hoursSpend= hoursSpend + Duration(minutes: item.getMinutesTaken()).inHours;
    });

    return doubleToStringOneDecimal(hoursSpend);

  }

  String getHoursLeft(){
    double hoursLeft = 0;

    List<Todo> allTodos = dataModel.filterTodos(widget.todoType);

    allTodos.forEach((item){
      hoursLeft = hoursLeft + item.getTimeLeft().inHours;
    });

    return doubleToStringOneDecimal(hoursLeft);
  }
}