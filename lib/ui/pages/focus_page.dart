import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/data/provider_models.dart';
import 'package:time_tracker/main.dart';
import 'package:time_tracker/objects/todo.dart';
import 'package:time_tracker/objects/type.dart';
import 'package:time_tracker/utils/date_utils.dart';
import 'package:time_tracker/utils/get_popup_and_sheets_utils.dart';
import 'package:time_tracker/utils/get_widget_utils.dart';
import 'package:time_tracker/utils/typedef_and_enums_utils.dart';

class FocusPage extends StatefulWidget {
  final TodoType todoType;
  final Todo todo;
  FocusPage({Key key,@required this.todo,@required this.todoType}) : super(key: key);

  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {


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
    return Scaffold(
      backgroundColor: Color(widget.todoType.color),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(onPressed: (){dataModel.setPlaying(null, context);Navigator.pop(context);}, label: getText('Stop'),icon: getIcon(Icons.stop),),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            getText(widget.todo.name,textType: TextType.textTypeSubtitle),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ((widget.todo.timeEstimated.inMinutes==0)||(widget.todo.timeEstimated.inMinutes<=widget.todo.getMinutesTaken()))?Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: dataModel.timerService, // listen to ChangeNotifier
                        builder: (context, child) {
                          return getText(getTextFromDuration(dataModel.timerService.currentDuration),textType: TextType.textTypeGigant);
                        },
                      ),
                    ],
                  ),
                ):CountdownFormatted(
                  duration: Duration(minutes: widget.todo.timeEstimated.inMinutes-widget.todo.getMinutesTaken()),
                  builder: (BuildContext ctx, String remaining) {
                    return getText(remaining,textType: TextType.textTypeGigant);
                  },
                  onFinish: (){
                    showDistivityDialog(
                      context,title: 'Task done',actions: [getButton('Close', onPressed: ()=>Navigator.pop(context))],stateGetter: (ctx,ss){return Container();}
                    );
                    setState(() {
                      
                    });
                  },
                ),
                getPadding(IconButton(icon: getIcon(Icons.remove_red_eye), onPressed: (){
                  setState(() {
                    hideChecked=!hideChecked;
                  });
                })),
              ],
            ),
            getPadding(Container(
              height: 500,
              child: ListView.builder(itemCount: items.length,itemBuilder: (ctx,ind){
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
                      dataModel.todo(dataModel.todos.indexOf(widget.todo), widget.todo, context, CUD.Update);
                    }
                  ),
                  title: getText(subtask.name),
                  );
              }),
            ),vertical: 10),
          ],
        ),
      ),
    );
  }
}