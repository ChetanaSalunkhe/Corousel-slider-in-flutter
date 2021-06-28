import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget{

  @override
  final Size preferredSize;
  final String title;

  //const CustomAppBar({Key key, this.title}) : super(key: key);
  CustomAppBar(this.title, {Key key}): preferredSize = Size.fromHeight(60),super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
        style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),),
      backgroundColor: Colors.indigo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30)
        )
      ),
      automaticallyImplyLeading: true,

    );
  }

}