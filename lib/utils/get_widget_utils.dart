import 'dart:js';
import 'dart:ui';
import 'package:calendar_views/calendar_views.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:time_tracker/data/provider_models.dart';
import 'package:time_tracker/objects/todo.dart';
import 'package:time_tracker/ui/pages/focus_page.dart';
import 'package:time_tracker/ui/pages/home_page.dart';
import 'package:time_tracker/utils/utils.dart';

import '../icon_pack_icons.dart';
import '../main.dart';
import 'date_utils.dart';
import 'get_popup_and_sheets_utils.dart';
import 'typedef_and_enums_utils.dart';
import 'values_utils.dart';


Text getText(String text, { TextType textType, Color color,int maxLines,bool crossed,bool isCentered,bool underline}){

  if(textType==null){
    textType=TextType.textTypeNormal;
  }

  if(color==null){
    color= MyApp.isDarkMode?Colors.white:MyColors.color_black;
  }

  if(crossed==null){
    crossed=false;
  }

  if(isCentered==null){
    isCentered=false;
  }

  if(underline==null){
    underline= false;
  }

  TextDecoration textDecoration = TextDecoration.none;

  if(crossed){
    textDecoration = TextDecoration.lineThrough;
  }
  if(underline){
    textDecoration = TextDecoration.underline;
  }

  return Text(text,maxLines: maxLines??100,style: TextStyle(fontSize: textType.size,
    color: color,
    fontWeight: textType.fontWeight,
    decoration: textDecoration,
  ),textAlign: isCentered?TextAlign.center:null,);

}

getRichText(List<String> strings , List<TextType> textTypes, {List<Color> colors}){
  if(colors==null){
    colors=[];
  }
  return RichText(
    text: TextSpan(
      children: List.generate(strings.length, (index){
        bool existsTextType = textTypes[index]!=null;
        bool existsColor = colors.length>index;

        return TextSpan(
          text: strings[index],
          style: TextStyle(
            color: existsColor?colors[index]:getIconTextColor(),
            fontWeight: existsTextType?textTypes[index].fontWeight:TextType.textTypeNormal.fontWeight,
            fontSize: existsTextType?textTypes[index].size:TextType.textTypeNormal.size,
          ),
        );
      }),
    ),
  );
}

getColorPrimaryContainer(Widget widget){
    return Container(
      decoration: BoxDecoration(
        color: MyColors.color_primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: getPadding(widget),
    );
}


getPadding(Widget child,{double horizontal,double vertical}){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal??8,vertical: vertical??8),
    child: child,
  );
}

getWidgetKey(GlobalKey globalKey, Widget child){
  return Container(key: globalKey,child: child,);
}


getSliderWrapperForSuperTooltip({@required StateGetter getSlider,@required String title}){
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      getPadding(getText(title,textType: TextType.textTypeTitle)),
      Container(
        height: 70,
        child: Card(
            elevation: 0,
            color: getOverFlowColor(),
            child: StatefulBuilder(
              builder: (ctx,ss){
                return getSlider(ctx,(function){
                  ss((){
                    function();
                  });
                });
              },
          ),
        ),
      ),
    ],
  );
}

getSliderThemeData(){
  return SliderThemeData(
    activeTrackColor: MyColors.color_primary,
    inactiveTrackColor: MyColors.color_primary.withOpacity(0.3),
    thumbColor: MyColors.color_secondary,
    trackHeight: 8,
    overlayColor: MyColors.color_secondary.withOpacity(0.3),
    valueIndicatorColor: MyColors.color_primary,
    activeTickMarkColor: Colors.transparent,
    inactiveTickMarkColor: Colors.transparent,
  );
}

getAppTheme(){
  return ThemeData(
    fontFamily: 'Montserrat',
    accentColor: MyColors.color_secondary,
    primaryColor: MyColors.color_primary,
    cursorColor: MyColors.color_primary,
    primaryColorDark: MyColors.color_primary,
    scaffoldBackgroundColor: Colors.white,
    bottomAppBarColor:Colors.white,
    sliderTheme: getSliderThemeData(),
    popupMenuTheme: PopupMenuThemeData(
      shape: getShape(),
    ),

  );
}

getAppDarkTheme(){
  return ThemeData(
    fontFamily: 'Montserrat',
    accentColor: MyColors.color_secondary,
    cursorColor: MyColors.color_secondary,
    sliderTheme: getSliderThemeData(),
    primaryColor: MyColors.color_primary,
    primaryColorDark: MyColors.color_primary,
    scaffoldBackgroundColor: MyColors.color_black,
    bottomAppBarColor: MyColors.color_black_darker,
    popupMenuTheme: PopupMenuThemeData(
      shape: getShape(),
      color: MyColors.color_black_darker,
    ),
  );
}

getFloatingActionButton(FABAction fabAction,{bool extended,@required Function onPressed}){

  IconData iconData;
  String text;

  if(extended==null){
    extended=true;
  }

  if(fabAction==FABAction.AddTask){
    iconData=IconPack.add;
    text = 'Add task';
  }

  if(extended){
    return FloatingActionButton.extended(
      label: getText(text,color: MyColors.color_black),
      icon: getIcon(iconData,color: MyColors.color_black),
      onPressed: onPressed,
    );
  }else{
    return FloatingActionButton(
      child: getIcon(iconData,color: MyColors.color_black),
      onPressed: onPressed,
    );
  }
}

getBottomAppBar({@required Function onPressed,Function onPressed1,IconData icon1, IconData icon2}){
  return BottomAppBar(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        getPadding(
            IconButton(
            icon: getIcon(icon1??IconPack.menu_line),
            onPressed: onPressed,
          ),
        ),
        Visibility(
          visible: onPressed1!=null,
          child: getPadding(IconButton(
            icon: getIcon(icon2??IconPack.dots_vertical),
            onPressed: onPressed1,
          ),
        ),
        )
      ],
    ),
    elevation: 10,
  );
}

getInfoIcon(String info){
  return PopupMenuButton(
    child: getIcon(IconPack.info,color: MyColors.getHelpColor(),size: 16),
    itemBuilder: (ctx){
      return [
        PopupMenuItem(child: getPadding(getText(info)))
      ];
    },
  );
}

getTabBar({@required List<String> items,@required List<int> selected, Function(int,bool) onSelected}){
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    shrinkWrap: true,
    itemCount: items.length,
    itemBuilder: (ctx,index){
      bool isSelected = selected.contains(index);
      return getPadding(
        getButton(
          items[index],
          variant: isSelected?1:2,
          onPressed: (){
            onSelected(index,!isSelected);
          },
        ),
      );
    },
  );
}

getIcon(IconData iconData,{Color color, double size}){


  if(color==null){
    color=getIconTextColor();
  }
  return Icon(iconData,size: size??18,color: color,);
}

getPopupMenuItem({@required int value,@required String name, @required IconData iconData,String description}){
  return PopupMenuItem(
    value: value,
    child: ListTile(
      trailing: getIcon(iconData),
      title: getText(name),
      subtitle: description!=null?getText(description,textType: TextType.textTypeSubNormal):null,
    ),
  );
}

Widget getFlareCheckbox(bool enabled,{Function(bool) onCallbackCompleted,Function() onTap}){
    return Container(
      width: 30,
      height: 30,
      child: GestureDetector(
        onTap: (){
          MyApp.snapToEnd=false;
          onTap();
        },
        child: FlareActor(AssetsPath.checkboxAnimation,snapToEnd: MyApp.snapToEnd,
          animation: enabled?'onCheck':'onUncheck',
          callback: (name){
            if(onCallbackCompleted!=null)onCallbackCompleted(name=='onCheck');
          },
        ),
      ),
    );
  }




getTextField(TextEditingController textEditingController,{String hint,@required int width,
  TextInputType textInputType,bool focus,int variant,Function(String) onChanged}){

    if(focus==null){
      focus = false;
    }

    if(textInputType==null){
      textInputType = TextInputType.text;
    }

    if(variant==null){
      variant=1;
    }

  return Container(
    width: width.toDouble(),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: variant==1?getGrayBackground():Colors.transparent),
    child: Center(
      child: Container(
        width: (width.toDouble()-30),
        child: TextFormField(
          onChanged: (str){onChanged(str);},
          autofocus: focus,
          keyboardType: textInputType,
          controller: textEditingController,
          style: TextStyle(fontSize: TextType.textTypeNormal.size,color: MyApp.isDarkMode?Colors.white:MyColors.color_black,fontWeight: TextType.textTypeNormal.fontWeight),
          decoration: InputDecoration.collapsed(
            hintText: hint??'',
            hintStyle: TextStyle(fontSize: TextType.textTypeNormal.size,color: MyApp.isDarkMode||(!MyApp.isDarkMode&&variant==1)?MyColors.color_gray_darker:MyColors.color_gray_lighter,fontWeight: TextType.textTypeNormal.fontWeight),
          ),
        ),
      ),
    ),
  );

}

getSkeletonView(int width,int height,{int radius}){
  return Container(
    height: height.toDouble(),
    width: width.toDouble(),
    decoration: BoxDecoration( color: MyColors.color_gray_darker,borderRadius: BorderRadius.circular(radius??7)),
  );
}



getButton(String text,{int variant,@required Function onPressed}){
  if(variant==null||variant>2){
    variant=1;
  }

  return FlatButton(
    child: getPadding(getText("$text",color: variant==1?Colors.white:MyApp.isDarkMode?MyColors.color_secondary:MyColors.color_primary),
      horizontal: 7,vertical: 9),
    onPressed: onPressed,
    shape: getShape(),
    color: variant==1?MyColors.color_secondary:Colors.transparent,
  );
}



getSwitchable({@required String text,@required bool checked,@required Function(bool) onCheckedChanged, @required bool isCheckboxOrSwitch}){
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      getPadding(isCheckboxOrSwitch?
        Checkbox(
          onChanged: onCheckedChanged,
          value: checked,
        ):
        Switch(
          onChanged: onCheckedChanged,
          value: checked,
        ),),
      getPadding(getText(text)),
    ],

  );
}

RoundedRectangleBorder getShape({bool bottomSheetShape,bool smallRadius, bool webCardShape,bool subtleBorder}){

  if(bottomSheetShape==null){
    bottomSheetShape=false;
  }
  if(smallRadius==null){
    smallRadius=false;
  }

  if(webCardShape==null){
    webCardShape=false;
  }

  if(subtleBorder==null){
    subtleBorder=false;
  }

  if(bottomSheetShape){
    return RoundedRectangleBorder(
      side: subtleBorder?BorderSide(
        width: 1,
        color: MyColors.getIconTextGray(),
      ):BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )
    );
  }else if(webCardShape){
    return RoundedRectangleBorder(
      side: subtleBorder?BorderSide(
        width: 1,
        color: MyColors.getIconTextGray(),
      ):BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
    );
  }else{
    return RoundedRectangleBorder(
      side: subtleBorder?BorderSide(
        width: 1,
        color: MyColors.getIconTextGray(),
      ):BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(15)
    );
  }
}

Offset getWidgetPosition(GlobalKey key){

  final RenderBox renderBoxRed = key.currentContext.findRenderObject();
  final Offset positionRed = renderBoxRed.localToGlobal(Offset.zero);

  return positionRed;
}

getInfoButton(String name, Function onPress){
  return GestureDetector(
    onTap: onPress,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          getIcon(IconPack.info,color: MyColors.getHelpColor(),size: 16),
          getText(name,color: MyColors.getHelpColor(),textType: TextType.textTypeSubNormal)
        ],
      ),
    )
  );
}

Widget getAppBar(String title,{bool backEnabled,bool centered, BuildContext context,bool drawerEnabled}){
  if(centered==null){
    centered=false;
  }

  if(drawerEnabled==null){
    drawerEnabled=false;
  }
  if(backEnabled==null){
    backEnabled=false;
  }
  return PreferredSize(
    preferredSize: Size.fromHeight(85),
    child: getPadding(Align(
        alignment: centered?Alignment.bottomCenter:Alignment.bottomLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Visibility(
              visible: backEnabled,
              child: IconButton(icon: getIcon(IconPack.carret_backward),onPressed: (){Navigator.pop(context);},),
            ),
            Visibility(
              visible: drawerEnabled,
              child: IconButton(
                icon: getIcon(IconPack.menu_line,),
                onPressed: (){
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            getText(title, textType: TextType.textTypeTitle)
          ],
        ),
      ),horizontal: 10,vertical: 0),
  );
}

getPickDateButton(BuildContext buildContext,{@required DateTime dateTime,@required Function(DateTime) onDateTimeSet}){
  return getButton(
    dateTime==null?'Pick date': getStringFromDate(dateTime),
    variant: 2,
    onPressed: (){
      showDistivityDatePicker(
        buildContext,onDateSelected: (DateTime val){
          onDateTimeSet(val);
        }
      );
    },
  );
}

getOverFlowColor(){
  return MyApp.isDarkMode?MyColors.color_black_darker:Colors.white;
}

getBackgroundColor(){
  return MyApp.isDarkMode?MyColors.color_black:Colors.white;
}

getGrayBackground(){
  return !MyApp.isDarkMode?MyColors.color_gray_lighter:MyColors.color_gray_darker;
}

getIconTextColor(){
    return MyApp.isDarkMode?Colors.white:MyColors.color_black;
}

getWelcomePresentation(BuildContext context,int currentPage,{@required List<String> assetPaths,@required List<String> texts,@required Function(int) onPageChanged}){

  PageController pageController = PageController(initialPage: currentPage);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          height: 450,
          child: PageView(
            onPageChanged: onPageChanged,
            children: List<Widget>.generate(assetPaths.length, (index) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SvgPicture.asset(assetPaths[index],width: 300,height: 300,),
                ),
                getText(texts[index],textType: TextType.textTypeSubtitle,isCentered: true,maxLines: 3),
              ],
            )),
            controller: pageController,
          ),
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List<Widget>.generate(assetPaths.length, (index) => Padding(
          padding: const EdgeInsets.all(5),
          child: CircleAvatar(backgroundColor: index==currentPage?MyColors.color_gray_darker:MyColors.color_gray_lighter,radius: 5,),
        )),
      ),

    ],
  );

}

Widget getCalendar(DataModel dataModel,List<DateTime> days){
  return DayViewEssentials(
      properties: new DayViewProperties(
          days: days,
        ),
    child: DayViewSchedule(
      heightPerMinute: 1.0,
      components: <ScheduleComponent>[
        new TimeIndicationComponent.intervalGenerated(
          generatedTimeIndicatorBuilder:(context,itemPosition,itemSize,minuteOfDay,){
            return new Positioned(
              top: itemPosition.top,
              left: itemPosition.left,
              width: itemSize.width,
              height: itemSize.height,
              child: new Container(
                child: new Center(
                  child: getText(minuteOfDayToHourMinuteString(minuteOfDay)),
                ),
              ),
            );
          },
        ),
        new SupportLineComponent.intervalGenerated(
          generatedSupportLineBuilder: (context,itemPosition,itemWidth,minuteOfDay,){
            return new Positioned(
              top: itemPosition.top,
              left: itemPosition.left,
              width: itemWidth,
              child: new Container(
                height: 0.5,
                color: MyColors.getHelpColor(),
              ),
            );
          },
        ),
        new DaySeparationComponent(
          generatedDaySeparatorBuilder:(
            BuildContext context,
            ItemPosition itemPosition,
            ItemSize itemSize,
            int daySeparatorNumber,
          ) {
            return new Positioned(
              top: itemPosition.top,
              left: itemPosition.left,
              width: itemSize.width,
              height: itemSize.height,
              child: new Center(
                child: new Container(
                  width: 0.5,
                  color: MyColors.getHelpColor(),
                ),
              ),
            );
          }
        ),
        new EventViewComponent(
          getEventsOfDay: (DateTime day) {
            List<Event> events = dataModel.getDataSource(year: day.year, month: day.month, day: day.day);
            return events.map(
                  (event) => new StartDurationItem(
                        startMinuteOfDay: event.startMinuteOfDay,
                        duration: event.duration,
                        builder: (context,itemPosition,itemSize,){
                          return new Positioned(
                            top: itemPosition.top,
                            left: itemPosition.left,
                            width: itemSize.width,
                            height: itemSize.height,
                            child: Card(
                              shape: getShape(),
                              color: event.color,
                              child: Center(child: getText(event.title),),
                            )
                          );
                        }
                      ),
                )
                .toList();
          },
        ),
      ],
    ),
    );
}

Widget getPieChart(BuildContext context,List<Event> events){

  Map<String,double> items = Map();

  events.forEach((item){
    if(items[item.title]==null){
      items[item.title] = 0.0;
    }
    items[item.title] = items[item.title]+(item.duration.toDouble());
  });


  return events.length==0?getText('Empty') :PieChart(
                  dataMap:items,
                  animationDuration: Duration(milliseconds: 500),
                  chartLegendSpacing: 32.0,
                  chartRadius: MediaQuery.of(context).size.width / 2.7,
                  showChartValuesInPercentage: true,
                  showChartValues: true,
                  showChartValuesOutside: true,
                  chartValueBackgroundColor: Colors.grey[200],
                  colorList: List<Color>.generate(events.length, (i){return events[i].color;}),
                  showLegends: true,
                  legendPosition: LegendPosition.right,
                  decimalPlaces: 1,
                  showChartValueLabel: true,
                  chartValueStyle: defaultChartValueStyle.copyWith(
                    fontSize: TextType.textTypeSubMiniscule.size,
                    fontWeight: TextType.textTypeSubMiniscule.fontWeight,
                    fontFamily: 'Montserrat',
                    color: MyColors.color_black
                  ),
                  chartType: ChartType.ring,
                  legendStyle: getText('',textType: TextType.textTypeSubMiniscule).style,
                );

}


List<Widget> getTimestamp(List<DateTime> startTimes, List<DateTime> endTimes,Color color){
  return List.generate(startTimes.length, (ind){
    bool show = (endTimes.length!=0)&&(endTimes.length>ind);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          Center(child: getIcon(IconPack.carret_foward),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Visibility(
                visible: startTimes.length!=0,
                child: Card(
                  color: color,
                  shape: getShape(),
                  child: getPadding(getText(getStringFromDate(startTimes[ind]))),
                ),
              ),
              Card(
                color: color,
                shape: getShape(),
                child: getPadding(getText(show?getStringFromDate(endTimes[ind]):'None')),
              ),
            ],
          ),
        ],
      ),
    );
  });
}

Widget getSecondaryItem(BuildContext buildContext,DataModel dataModel,){
  Todo currentTodo = dataModel.getCurrentPlaying();
  if(currentTodo==null){
    return Container();
  }else return GestureDetector(
    onTap: (){
      launchPage(buildContext, FocusPage(todo: currentTodo, todoType: dataModel.findTypeById(currentTodo.typeId)));
    },
    child: Card(
      color: Color(dataModel.findTypeById(currentTodo.typeId).color),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            getText(currentTodo.name),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: dataModel.timerService, // listen to ChangeNotifier
                    builder: (context, child) {
                      return getText(getTextFromDuration(dataModel.timerService.currentDuration),textType: TextType.textTypeSubtitle);
                    },
                  ),

                  IconButton(icon: getIcon(Icons.stop), onPressed: (){
                    dataModel.setPlaying(null, buildContext,);
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}

//getYoutubePlayer(String vId){
//  ClipRRect(
//    borderRadius: BorderRadius.circular(10),
//    child: YoutubePlayer(
//      controller: YoutubePlayerController(
//          initialVideoId: 'qh9czFNGDBc',
//          flags: YoutubePlayerFlags(
//            autoPlay: false,
//          )
//      ),
//      showVideoProgressIndicator: true,
//    ),
//  );
//}

//Specific for this app

