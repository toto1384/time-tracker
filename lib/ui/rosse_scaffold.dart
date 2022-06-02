import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:time_tracker/utils/get_widget_utils.dart';
import 'package:time_tracker/utils/typedef_and_enums_utils.dart';
import 'package:time_tracker/utils/values_utils.dart';

import '../icon_pack_icons.dart';

class RosseScaffold extends StatefulWidget {
  

  final List<Widget> primaryItems;
  final List<Widget> secondaryItems;
  final String title;
  final bool isTitleCentered;
  final bool secondaryBodyAlwaysRed;
  final Function() onMorePressed;
  final bool backEnabled;
  final Color color;
  final Widget fab;
  final Widget bottomAppBar;
  final double expandedHeight;


  RosseScaffold(this.title,{this.bottomAppBar,this.expandedHeight,Key key,this.fab,this.color,@required this.primaryItems,@required this.secondaryItems, this.isTitleCentered, this.secondaryBodyAlwaysRed,this.onMorePressed,this.backEnabled}) : super(key: key);

  @override
  _RosseScaffoldState createState() => _RosseScaffoldState();
}

class _RosseScaffoldState extends State<RosseScaffold> with TickerProviderStateMixin<RosseScaffold> {


  @override
  initState() {
    super.initState();
    _hideFabAnimation = AnimationController(vsync: this, duration: kThemeAnimationDuration,value: 1);
  }

  @override
  void dispose() {
    _hideFabAnimation.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {

    return getSmallScreen();
  }

  bool showFab = true;
  AnimationController _hideFabAnimation;

  getSmallScreen(){
    List<Widget> smallScreenItems = ((widget.secondaryBodyAlwaysRed??false))?widget.primaryItems:widget.primaryItems+widget.secondaryItems;

    return Scaffold(
      backgroundColor: widget.color??MyColors.color_secondary,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ScaleTransition(
          scale: _hideFabAnimation,
          alignment: Alignment.bottomCenter,
          child: widget.fab??Container(),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification){
          if (notification.depth == 0) {
            if (notification is UserScrollNotification) {
              final UserScrollNotification userScroll = notification;
              switch (userScroll.direction) {
                case ScrollDirection.forward:
                  _hideFabAnimation.forward();
                  break;
                case ScrollDirection.reverse:
                  _hideFabAnimation.reverse();
                  break;
                case ScrollDirection.idle:
                  break;
              }
            }
          }
          return false;
        },
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                leading: Visibility(
                  visible: widget.backEnabled??false,
                  child: IconButton(
                    icon: getIcon(IconPack.carret_backward,color: Colors.white),
                    onPressed: ()=>Navigator.pop(context),
                  ),
                ),
                actions: <Widget>[
                  Visibility(
                    visible: widget.onMorePressed!=null&&(!(widget.secondaryBodyAlwaysRed??false)),
                    child: IconButton(
                      icon: getIcon(IconPack.dots_vertical,color: Colors.white),
                      onPressed: widget.onMorePressed,
                    ),
                  ),
                ],
                expandedHeight: widget.expandedHeight??100,
                floating: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: widget.isTitleCentered??false,
                    title: widget.secondaryBodyAlwaysRed??false?Text(''):getText(widget.title,textType: TextType.textTypeSubtitle,color: Colors.white,maxLines: 3,isCentered: true),
                    background: Stack(
                      children: <Widget>[
                        widget.secondaryBodyAlwaysRed??false?Center(child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisSize: MainAxisSize.min,children: widget.secondaryItems,),):Container()
                      ],
                    )
                ),
              ),
            ];
          },
          body: Container(
            decoration: BoxDecoration(color: getBackgroundColor(),borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))),
            child: ListView(
              children: <Widget>[
                  widget.secondaryBodyAlwaysRed??false?Row(
                    crossAxisAlignment: widget.isTitleCentered??false?CrossAxisAlignment.center:CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Visibility(
                            visible: widget.backEnabled??false,
                            child: IconButton(
                              icon: getIcon(IconPack.carret_backward),
                              onPressed: ()=>Navigator.pop(context),
                            ),
                          ),
                          getPadding(getText(widget.title,textType: TextType.textTypeTitle),horizontal: 10),
                        ],
                      ),
                      Visibility(
                        visible: widget.onMorePressed!=null,
                        child: IconButton(
                          icon: getIcon(IconPack.dots_vertical),
                          onPressed: widget.onMorePressed,
                        ),
                      ),
                    ],
                  ):Container(),
                ]+smallScreenItems,
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.bottomAppBar,
    );
  }

}