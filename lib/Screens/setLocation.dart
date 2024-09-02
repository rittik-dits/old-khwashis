import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/location.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class SetLocation extends StatefulWidget {
  const SetLocation({super.key});

  @override
  State<SetLocation> createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
          ),
          titleSpacing: 0.0,
          title: Text('Set Location'),
        ),
        body: StreamBuilder(
          stream: _firestore.collection('city').snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              var docs = snapshot.data!.docs;
              List cities = [];
              List otherCities = [];
              for(var item in docs){
                if(item['majorCity'] != false){
                  cities.add(item);
                } else {
                  otherCities.add(item);
                }
              }
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   decoration: containerDesign(context),
                    //   child: profileButton(
                    //     Icons.location_on_outlined,
                    //     'Auto Detect My Location',
                    //         (){
                    //       setState(() {
                    //         // LocationService.appServiceLocation = 'Near Me';
                    //       });
                    //       Navigator.pop(context);
                    //     },
                    //   ),
                    // ),
                    // kSpace(),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Popular City'.toUpperCase(), style: kBoldStyle()),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: cities.length,
                      itemBuilder: (context, index){
                        return GestureDetector(
                          onTap: (){
                            setState(() {
                              LocationService.pickedCity = '${cities[index]['name']}';
                              LocationService.pickedCityID = '${cities[index].reference.id}';
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            // color: Colors.white,
                            decoration: containerDesign(context),
                            child: Column(
                              children: [
                                if(cities[index]['image'] != '')
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: k4Color.withOpacity(0.4),
                                        image: DecorationImage(
                                          image: NetworkImage('${cities[index]['image']}'),
                                          fit: BoxFit.cover,
                                        )
                                    ),
                                  ),
                                ),
                                // Expanded(
                                //   child: Image.network('${cities[index]['image']}'),
                                // ),
                                SizedBox(height: 3),
                                Text('${cities[index]['name']}', style: kSmallText().copyWith(
                                  // color: kDarkColor
                                )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    kSpace(),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Other City'.toUpperCase(), style: kBoldStyle()),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: otherCities.length,
                      itemBuilder: (context, index){
                        return Container(
                          decoration: containerDesign(context),
                          child: profileButton(Icons.location_on, '${otherCities[index]['name']}', (){
                            setState(() {
                              LocationService.pickedCity = '${otherCities[index]['name']}';
                            });
                            Navigator.pop(context);
                          }),
                        );
                      },
                    ),
                    kSpace(),
                  ],
                ),
              );
            }
            return LoadingIcon();
          }
        ),
      ),
    );
  }
}
