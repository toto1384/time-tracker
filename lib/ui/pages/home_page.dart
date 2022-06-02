import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';
import 'package:time_tracker/data/provider_models.dart';
import 'package:time_tracker/icon_pack_icons.dart';
import 'package:time_tracker/objects/todo.dart';
import 'package:time_tracker/objects/type.dart';
import 'package:time_tracker/ui/pages/focus_page.dart';
import 'package:time_tracker/ui/pages/type_page.dart';
import 'package:time_tracker/ui/rosse_radio_group.dart';
import 'package:time_tracker/ui/todo_widget.dart';
import 'package:time_tracker/utils/date_utils.dart';
import 'package:time_tracker/utils/get_popup_and_sheets_utils.dart';
import 'package:time_tracker/utils/get_widget_utils.dart';
import 'package:time_tracker/utils/typedef_and_enums_utils.dart';
import 'package:time_tracker/utils/utils.dart';
import 'package:time_tracker/utils/values_utils.dart';

import '../rosse_scaffold.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {



  int _selectedIndex = 0;
  PageController _pageController;

  DataModel dataModel;
  Soundpool pool = Soundpool(streamType: StreamType.alarm);

  Color activeColor = MyColors.color_secondary;

  @override
  void initState() {
    super.initState();
    if(_pageController==null)_pageController = PageController(initialPage: 0,);
  }

  @override
  void dispose()async {
    _pageController.dispose();
    super.dispose();
  }

  playTick(Soundpool pool) async{
    pool.play(await rootBundle.load(AssetsPath.tick).then((ByteData soundData) {
      return pool.load(soundData);
    }),repeat: 7);
  }


  @override
  Widget build(BuildContext buildContext) {
    dataModel = Provider.of<DataModel>(context);
    if(dataModel.currentFocus!=null)activeColor = Color(dataModel.currentFocus.color);
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(onPressed: (){},child: getText('${dataModel.todayScore}'),backgroundColor: activeColor,),
        body: PageView(
          controller: _pageController,
          children: <Widget>[
            if(dataModel.currentFocus!=null)
              TypePage(todoType: dataModel.currentFocus,secItem: getSecondaryItem(),),
            getTasksScreen(),
            getTimelineScreen(),
            getStatsScreen(),
          ],
          onPageChanged: (i){
            setState(() {
              _selectedIndex=i;
            });
          },
        ),
        bottomNavigationBar: BubbleBottomBar(
          opacity: .2,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() {
                      _selectedIndex = index;
                      _pageController.animateToPage(index,
                          duration: Duration(milliseconds: 300), curve: Curves.ease);
          }),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          elevation: 8,
          fabLocation: BubbleBottomBarFabLocation.end,
          hasNotch: true, //new
          hasInk: true, 
          backgroundColor: MyColors.color_black, //new
          items: <BubbleBottomBarItem>[
            
            if (dataModel.currentFocus!=null)
              BubbleBottomBarItem(
                icon: getIcon(Icons.slideshow,color: activeColor),
                title: getText(dataModel.currentFocus.name,color: activeColor
                ),
                backgroundColor: activeColor
              ),
            
            BubbleBottomBarItem(
                icon: getIcon(Icons.check_circle_outline),
                title: getText('Tasks'),
                backgroundColor: activeColor
            ),
            BubbleBottomBarItem(
                icon: getIcon(Icons.calendar_view_day),
                title: getText('Timeline'),
                backgroundColor: activeColor
            ),
            BubbleBottomBarItem(
                icon: getIcon(Icons.pie_chart_outlined),
                title: getText('Stats'),
                backgroundColor: activeColor
            ),
          ],
        ),
      );
  }

  int selectedTab = 0;

  getTasksScreen(){


    List<TodoType> todoTypes = dataModel.findTypesByDate(getTodayFormated().add(Duration(days: selectedTab)));
    List<TodoType> notByDate = dataModel.findTypesByDate(getTodayFormated().add(Duration(days: selectedTab)),notByDate: true);

    return RosseScaffold(
      'Todos', 
      color: activeColor,
      primaryItems: todoTypes.length!=0?List<Widget>.generate(todoTypes.length, (ind){

        if(todoTypes[ind].repeatEvery!=0){
          List<Todo> filteredTodos = dataModel.filterTodos(todoTypes[ind],hideChecked: true);

          return Card(
            color: Color(todoTypes[ind].color).withOpacity(.08),
            shape: getShape(),
            child: GestureDetector(
              onTap: (){
                launchPage(context, TypePage(todoType: todoTypes[ind],));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  getPadding(getText(todoTypes[ind].name,textType: TextType.textTypeSubtitle),vertical: 12)
                ]+List<Widget>.generate(filteredTodos.length, (i){
                  return TodoWidget(
                    todo: filteredTodos[i],
                    todoType: todoTypes[ind], 
                    buildContext: context,
                  );
                }),
              ),
            ),
          );
        }else{
          return Container();
        }
      })+<Widget>[
        Padding(padding: EdgeInsets.only(top: 30,bottom: 10),child: getText('Other types',textType: TextType.textTypeTitle),)
      ]+List<Widget>.generate(notByDate.length, (ind){
        TodoType thisItem = notByDate[ind];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onLongPress: (){
              showTypeEditBottomSheet(context,typeInd: dataModel.todoTypes.indexOf(thisItem));
            },
            leading: CircleAvatar(maxRadius: 15,backgroundColor: Color(thisItem.color),),
            title: getText(thisItem.name),
            onTap: (){
              launchPage(context, TypePage(todoType:thisItem,));
            },
          ),
        );
      })
      :[Card()], 
      secondaryItems: [
        Container(
          width: MediaQuery.of(context).size.width-30,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: RosseRadioGroup(
              items: Map.fromIterable(List.generate(7, (i){return i;}),
                key: (item) => getAppBarName(item),
                value: (item) => item==selectedTab,
              ), 
              isBig: false, 
              onSelected: (i,s){
                setState(() {
                  selectedTab=i;
                });
              }
            ),
          ),
        )
      ],
      fab: getSecondaryItem(),
      isTitleCentered: true,
      secondaryBodyAlwaysRed: true,
      onMorePressed: (){
        showDistivityModalBottomSheet(context, (ctx,ss){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: getText('Add Type'),
                leading: getIcon(IconPack.add),
                onTap: (){
                  Navigator.pop(context);
                  showTypeEditBottomSheet(context);
                },
              ),
              ListTile(
                leading: getIcon(Icons.slideshow),
                title: getText('Set current focus'),
                onTap: (){
                  Navigator.pop(context);
                  showDistivityModalBottomSheet(context, (ctx,ss){
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(dataModel.todoTypes.length, (ind){
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: CircleAvatar(maxRadius: 15,backgroundColor: Color(dataModel.todoTypes[ind].color),),
                            title: getText(dataModel.todoTypes[ind].name),
                            onTap: (){
                              showDistivityDialog(
                                context, 
                                actions: [
                                  getButton('Populate More', onPressed: ()=>Navigator.pop(context),variant: 2),
                                  getButton('I\'ve done it', onPressed: (){
                                    Navigator.pop(context);
                                    dataModel.setCurrentFocusId(dataModel.todoTypes[ind], context);
                                  }),
                                ], title: 'Are you sure you are done populating the tasks to set this as your current focus', stateGetter: (ctx,ss){return Container();});
                            },
                          ),
                        );
                      }),
                    );
                  });
                },
              )
            ],
          );
        });
      },
    );
  }

  List<DateTime> days = [getDateFromString(getStringFromDate(DateTime.now()))];

  getTimelineScreen(){
    return RosseScaffold(
      "${days[0].day}:${days[0].month}", 
      color: activeColor,
      primaryItems: [
        getCalendar(dataModel, days),
      ], 
      secondaryItems: [],
      onMorePressed: (){
        showDistivityDatePicker(context, onDateSelected: (d){
          setState(() {
            if(d!=null){
              days.add(getDateFromString(getStringFromDate(d)));
            }else{
              days = [getDateFromString(getStringFromDate(DateTime.now()))];
            }
          });
        });
      },
    );
  }

  getStatsScreen(){

    List<Event> events = dataModel.getDataSource(year: days.last.year, month: days.last.month, day: days.last.day);



    return RosseScaffold(
      'Stats', 
      primaryItems: List<Widget>.generate(toShowEvent.length, (i){
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            trailing: Card(
              color: toShowEvent[i].color,
              shape: getShape(),
              child: getPadding(getText(dataModel.findTypeById(dataModel.findTodoByName(toShowEvent[i].title).typeId).name),vertical: 5,horizontal: 5),
            ),
            title: getText(toShowEvent[i].title,textType: TextType.textTypeSubNormal),
            subtitle: getText('${getHours(toShowEvent[i].duration)} hours'),
          ),
        );
      }), 
      secondaryItems: [Container(
        width: MediaQuery.of(context).size.width,
        child: getPieChart(context, events),
      )],
      expandedHeight: 350,
      secondaryBodyAlwaysRed: true,
      color: activeColor.withOpacity(0.5),
      onMorePressed: (){
        showDistivityDatePicker(context, onDateSelected: (d){
          setState(() {
            if(d!=null){
              days.add(getDateFromString(getStringFromDate(d)));
            }else{
              days = [getDateFromString(getStringFromDate(DateTime.now()))];
            }
          });
        });
      },

    );


  }
}

