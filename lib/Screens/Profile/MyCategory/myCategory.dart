import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class MyCategory extends StatefulWidget {
  const MyCategory({super.key});

  @override
  State<MyCategory> createState() => _MyCategoryState();
}

class _MyCategoryState extends State<MyCategory> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List selectedCategories = [];
  List selectedCategoryName = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Category'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              decoration: containerDesign(context),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text('Categories', style: kBoldStyle()),
                  ),
                  StreamBuilder(
                    stream: _firestore.collection('category').snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.hasData) {
                        var docs = snapshot.data!.docs;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            height: 240.0,
                            decoration: roundedContainerDesign(context).copyWith(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              physics: BouncingScrollPhysics(),
                              itemCount: docs.length,
                              itemBuilder: (context, index){
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                                  child: GestureDetector(
                                    onTap: (){
                                      if(selectedCategories.contains(docs[index].reference.id)){
                                        setState(() {
                                          selectedCategories.remove(docs[index].reference.id);
                                          selectedCategoryName.remove('${docs[index]['name']}');
                                        });
                                      } else {
                                        setState(() {
                                          selectedCategories.add(docs[index].reference.id);
                                          selectedCategoryName.remove('${docs[index]['name']}');
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: k4Color.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(10.0)
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Container(
                                              height: 45,
                                              width: 45,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                image: DecorationImage(
                                                  image: NetworkImage('${docs[index]['serverPath']}'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(child: Text('${docs[index]['name']}')),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Icon(selectedCategories.contains(docs[index].reference.id) ?
                                            Icons.check_box_rounded : Icons.check_box_outline_blank),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                      return LoadingIcon();
                    },
                  ),
                  kSpace(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text('Sub Categories', style: kBoldStyle()),
                  ),
                  StreamBuilder(
                    stream: _firestore.collection('category').snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.hasData) {
                        var docs = snapshot.data!.docs;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            height: 240.0,
                            decoration: roundedContainerDesign(context).copyWith(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              physics: BouncingScrollPhysics(),
                              itemCount: docs.length,
                              itemBuilder: (context, index){
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                                  child: GestureDetector(
                                    onTap: (){
                                      if(selectedCategories.contains(docs[index].reference.id)){
                                        setState(() {
                                          selectedCategories.remove(docs[index].reference.id);
                                          selectedCategoryName.remove('${docs[index]['name']}');
                                        });
                                      } else {
                                        setState(() {
                                          selectedCategories.add(docs[index].reference.id);
                                          selectedCategoryName.remove('${docs[index]['name']}');
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: k4Color.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(10.0)
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Container(
                                              height: 45,
                                              width: 45,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                image: DecorationImage(
                                                  image: NetworkImage('${docs[index]['serverPath']}'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(child: Text('${docs[index]['name']}')),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Icon(selectedCategories.contains(docs[index].reference.id) ?
                                            Icons.check_box_rounded : Icons.check_box_outline_blank),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                      return LoadingIcon();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
