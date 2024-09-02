import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Theme/style.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            KTextField(title: 'Name'),
            KTextField(
              title: 'Tax',
              textInputType: TextInputType.number,
              suffixButton: IconButton(
                onPressed: (){},
                icon: Icon(Icons.percent),
              ),
            ),
            KTextField(
              title: 'Price',
              textInputType: TextInputType.number,
            ),
            KTextField(
              title: 'Discount Price',
              textInputType: TextInputType.number,
            ),
            KTextField(title: 'Unit'),
            KTextField(
              title: 'Stock (in pcs)',
              textInputType: TextInputType.number,
            ),
            kDivider(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text('Gallery', style: kBoldStyle()),
                ),
              ],
            ),
            KTextField(title: 'Image Url'),
            SizedBox(height: 5.0),
            KButton(
              title: 'Upload Image',
              onClick: (){},
            ),
            kDivider(),
            KTextField(title: 'Description'),
            KTextField(title: 'Preview'),
            kSpace(),
            kBottomSpace(),
          ],
        ),
      ),
      floatingActionButton: KButton(
        title: 'Create New Product',
        onClick: (){

        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
