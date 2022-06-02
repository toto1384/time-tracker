


import 'package:flutter/material.dart';
import 'package:time_tracker/main.dart';
import 'package:time_tracker/ui/pages/home_page.dart';

launchPage(BuildContext context , Widget page){

  Navigator.push(context, MaterialPageRoute(
    builder: (context){
      return page;
    }
  ));
}

doubleToStringOneDecimal(double dbl){
  List<String> items = dbl.toString().split('.');

  if(items.length>1){
    return items[0]+ '.' + items[1][0];
  }else{
    return items[0];
  }
}