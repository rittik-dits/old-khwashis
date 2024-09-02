import 'package:flutter/material.dart';
import 'package:khwahish_provider/Screens/Profile/MyProduct/addProduct.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class MyProducts extends StatelessWidget {
  const MyProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Products'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddProduct()));
            },
            child: Text('Add Product'),
          ),
          SizedBox(width: 5.0),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                  decoration: roundedShadedDesign(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: kSubTextColor,
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/4/45/GuitareClassique5.png')
                          )
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Guitar'),
                            Row(
                              children: [
                                Text('₹5000.00',
                                  style: kSmallText().copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                SizedBox(width: 5.0),
                                Text('₹2000.00'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(onPressed: (){}, child: Text('Edit'),),
                                TextButton(onPressed: (){}, child: Text('Delete'),),
                              ],
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
                Positioned(
                  top: 10.0,
                  right: 0.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: k4Color,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5.0),
                      ),
                    ),
                    child: Text('-57% OFF', style: k10Text().copyWith(
                      color: kWhiteColor,
                    ),),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
