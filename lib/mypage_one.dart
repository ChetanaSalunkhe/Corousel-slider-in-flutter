import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'database.dart';
import 'mycustom_appbar.dart';
import 'package:http/http.dart' as http;
import 'myhomepage.dart';

Future<List<Users>> fetchUsers() async{
  final response = await http.get(Uri.parse('https://randomuser.me/api/'));

  var respdatalist = json.decode(response.body);
  //print(respdatalist);

  return parseData(respdatalist);

}

parseData(respdatalist){

  List responseDataList = respdatalist['results'];
  //print(responseDataList);

  var fullname;
  List<Users> userList = new List<Users>();

  for(int i=0; i<responseDataList.length;i++){

    Users users = new Users(responseDataList[i]['name']['title'].toString()
        +" "+responseDataList[i]['name']['first'].toString()
        +" "+responseDataList[i]['name']['last'].toString(),
        responseDataList[i]['email'].toString(),
        responseDataList[i]['dob']['date'].toString(),
        responseDataList[i]['location']['street']['number'].toString()
           // +" "+responseDataList[i]['location']['street']['name'].toString()
            +" "+responseDataList[i]['location']['city'].toString()
            +" "+responseDataList[i]['location']['state'].toString()
            +" "+responseDataList[i]['location']['country'].toString(),
        responseDataList[i]['phone'].toString(),
        responseDataList[i]['cell'].toString(),
        responseDataList[i]['login']['password'].toString(),
        responseDataList[i]['picture']['large'].toString());

    userList.add(users);

  }

  return userList;

}

SQLiteDbProvider con = new SQLiteDbProvider();

Future<int> saveUser(Users user) async {
  var dbClient = await SQLiteDbProvider.db;
  //print(dbClient);
  var dbOBJ = await dbClient.initDB();

 // print(dbOBJ);
  //int res = await dbClient.insertTODB(user.fullname, user.email,user.dob,user.fulladdress,user.phone,user.password);
  int id1 = await dbOBJ.rawInsert(
      'INSERT INTO Users(Name, Email, DOB,Address,Mobile,Password) VALUES('
          '${'"'+user.fullname+'"'},${'"'+user.email+'"'},${'"'+user.dob+'"'},${'"'+user.fulladdress+'"'},'
          '${'"'+user.phone+'"'},${'"'+user.password+'"'})');
  print('inserted1: $id1');
  //return res;
}

Future<List<Users>> getAllUsers() async {
  final dbClient = await SQLiteDbProvider.db;
  var db = await dbClient.initDB();

  List<Map> result = await db.query("Users");

  final response = await db.rawQuery(
    "SELECT DISTINCT * FROM Users ",
  );

  print(response);
  List<Users> usrs = new List();
  response.forEach((row) => print(row));
  
  for(int i=0; i<result.length;i++){
   // Users users = new Users(result[i].fullname, email, dob, fulladdress, phone, cell, password, picture)
    Users users = Users.fromMap(result[i]);

    usrs.add(users);

  }

  return usrs;
}

Future<int> getAllUsersCount() async {
  final dbClient = await SQLiteDbProvider.db;
  var db = await dbClient.initDB();

  List<Map> result = await db.query("Users");

  return result.length;
}

class MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar('Tinder'),

      body: Container(
        child: FutureBuilder<List<Users>>(
          future: fetchUsers(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.data == null){
              //load data from local db if present
              return Center(child:CircularProgressIndicator());

             /* if(getAllUsersCount()!=0){
                print(getAllUsersCount());

                return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,colors: [Color(0x00f2f7f8),
                        Colors.grey.withAlpha(5)],)
                  ),
                  child: Column(
                    children: [
                      //SizedBox(height: 5,),
                 //     UserList_(user: getAllUsers())
                    ],
                  ),
                );

              }else{
                return Center(child:CircularProgressIndicator());
              }*/

            }else if(snapshot.hasError){
              return Text("${snapshot.error}");
            }else{
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,colors: [Color(0x00f2f7f8),
                    Colors.grey.withAlpha(5)],)
                ),
                child: Column(
                  children: [
                    //SizedBox(height: 5,),
                    UserList_(user: snapshot.data)
                  ],
                ),
              );
            }
          }
        ),
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Users{
  String email,password,dob,date,phone,cell,picture;
  String fullname;  //name(title,first,last)
  String fulladdress; //location(street(number,name_l,city,state,country,postcode))

  Users(this.fullname,this.email, this.dob,this.fulladdress,this.phone, this.cell, this.password,this.picture);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["Name"] = fullname;
    map["Email"] = email;
    map["DOB"] = dob;
    map["Address"] = fulladdress;
    map["Mobile"] = phone;
    map["Password"] = password;
    map["Image"] = picture;
    return map;
  }

  factory Users.fromMap(Map<String, dynamic> data) {
    return Users(data['Name'], data['Email'], data['DOB'], data['Address'], data['Mobile'],data['Mobile'], data['Password'], data['Image'],);
  }
}

class UserList_ extends StatefulWidget{

  final List<Users> user;

  const UserList_({Key key,this.user}):super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UsersList(user: user);
  }

}

class UsersList extends State{
  final List<Users> user;

  String textval1="";
  String textval2="";

  var color = Colors.grey;
  var name =0, addr=0, cal=0, email=0, phone=0, lock =0;
  
  UsersList({Key key,this.user});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
        itemCount: user.length,
        itemBuilder: (context,index){

        return  CarouselSlider(
          items: [
            //1st Image of Slider
            Container(
              width: 300,
              margin: EdgeInsets.all(5.0),
              child: Card(
                //clipBehavior: Clip.antiAlias,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)
                ),
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20,),
                    Container(

                      child: Container(
                        width: 170,
                        height: 170,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            //borderRadius: BorderRadius.circular(30.0),
                            image: DecorationImage(
                                image: NetworkImage(user[index].picture), fit: BoxFit.cover)
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),
                    Text('$textval1',style: TextStyle(fontSize: 14,color: Colors.grey,fontWeight: FontWeight.normal,),
                      textAlign: TextAlign.center,),

                    SizedBox(height: 10,),
                    Text('$textval2',style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.normal,),
                      textAlign: TextAlign.center,),

                    SizedBox(height: 30,),

                    /*ToggleSwitch(
                      minWidth: 100,
                      initialLabelIndex: 1,
                      //cornerRadius: 2.0,
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      //labels: ['', ''],
                      icons: [Icons.person,Icons.email,Icons.calendar_today,Icons.location_on,Icons.call,Icons.lock],
                      activeBgColors: [Colors.indigo,Colors.pink],
                      onToggle: (index) {
                        print('switched to: $index');
                      },
                    ),*/

                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: InkWell(
                            focusColor: Colors.indigo,
                            hoverColor: Colors.indigo,
                            highlightColor: Colors.indigo,
                            splashColor: Colors.indigo,
                            borderRadius: BorderRadius.circular(30),
                            onTap: (){
                              setState(() {
                                textval1 = 'Hi, My name is';
                                textval2 = user[index].fullname.toString();
                                Image( height:28, image: AssetImage("assets/user.png"),color: Colors.indigo,);
                              });
                            },
                              child: Image( height:28, image: AssetImage("assets/user.png"),),),
                        ),

                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: InkWell(
                            focusColor: Colors.indigo,
                            hoverColor: Colors.indigo,
                            highlightColor: Colors.indigo,
                            splashColor: Colors.indigo,
                            borderRadius: BorderRadius.circular(30),
                            onTap: (){
                              setState(() {
                                textval1 = 'My email address is';
                                textval2 = user[index].email.toString();
                              });
                            },
                            child: Image(height:30,image: AssetImage("assets/mail.png")),),
                        ),

                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child:InkWell(
                            focusColor: Colors.indigo,
                            hoverColor: Colors.indigo,
                            highlightColor: Colors.indigo,
                            splashColor: Colors.indigo,
                            borderRadius: BorderRadius.circular(30),
                            onTap: (){

                              setState(() {
                                textval1 = 'My birthday is';
                                textval2 = user[index].dob.toString();
                                print(user[index].dob.toString());

                                //converted date
                                DateTime dt = DateTime.parse(user[index].dob.toString());

                                //convert date to string
                                final DateTime now = DateTime.now();
                                final DateFormat formatter = DateFormat('dd MMM yyyy');
                                final String formatted = formatter.format(dt);
                                print(formatted);

                                textval2 = formatted;

                              });
                            },
                            child: Image.asset("assets/cal.png",height:35,color: color,)),),

                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: InkWell(
                            focusColor: Colors.indigo,
                            hoverColor: Colors.indigo,
                            highlightColor: Colors.indigo,
                            splashColor: Colors.indigo,
                            borderRadius: BorderRadius.circular(30),
                            onTap: (){
                              setState(() {
                                textval1 = 'My address is';
                                textval2 = user[index].fulladdress.toString();
                              });
                            },
                            child: Image(
                                height:30,image: AssetImage("assets/locdef.png",)),),),

                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: InkWell(
                            focusColor: Colors.indigo,
                            hoverColor: Colors.indigo,
                            highlightColor: Colors.indigo,
                            splashColor: Colors.indigo,
                            borderRadius: BorderRadius.circular(30),
                            onTap: (){
                              setState(() {
                                textval1 = 'My phone number is';
                                textval2 = user[index].phone.toString();
                              });
                            },
                            child: Image(
                                height:30,image: AssetImage("assets/call.png",)),),),

                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: InkWell(
                            focusColor: Colors.indigo,
                            hoverColor: Colors.indigo,
                            highlightColor: Colors.indigo,
                            splashColor: Colors.indigo,
                            borderRadius: BorderRadius.circular(30),
                            onTap: (){
                              setState(() {
                                textval1 = 'My password is';
                                textval2 = user[index].password.toString();
                              });
                            },
                            child: Image(
                                height:28,image: AssetImage("assets/lockdef.png",)),),),
                      ],
                    )
                  ],
                ),
              ),
            ),

          ],

          //Slider Container properties
          options: CarouselOptions(
            height: 400.0,
            enlargeCenterPage: true,
            autoPlay: false,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            viewportFraction: 0.8,
            onPageChanged: (index,reason){
              setState(() {

                //print(index);

                Fluttertoast.showToast(
                    msg: "Add to favourites",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 16.0
                );

                GestureDetector(onPanUpdate: (details) {

                  String swipeDirection = details.delta.dx < 0 ? 'left' : 'right';
                  print(swipeDirection);

                  if (details.delta.dx > 0){
                    print("Dragging in right direction");
                  }else{
                    print("Dragging in left direction");
                  }

                  if (details.delta.dy > 0)
                    print("Dragging in +Y direction");
                  else
                    print("Dragging in -Y direction");
                });

                getAllUsers();

                //saveUser(user[index]);

              });
            }

          ),
        );
      }
    );

  }

}