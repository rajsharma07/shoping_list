import 'package:flutter/material.dart';
import 'package:shoping_list/data/categories.dart';
import 'package:shoping_list/models/category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shoping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _loading = false;
  String _title = '';
  int _quantity = 1;
  var _selecterCategory = categories[Categories.fruit]!;
  void savesItem() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
      _loading = true;
      });
      _formkey.currentState!.save();
      final url = Uri.https(
          'practice-project-635f6-default-rtdb.firebaseio.com',
          'shoping_list.json');
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
        body: json.encode({
          'name': _title,
          'category': _selecterCategory.title,
          'quantity': _quantity
        }),
      );
      
      if (response.statusCode == 200) {
        if (!context.mounted) {
          return;
        }
        final data = json.decode(response.body);
        Navigator.of(context).pop(GroceryItem(id: data['name'], name: _title, category: _selecterCategory, quantity: _quantity));
      } else {
        showAboutDialog(
            context: context, children: [const Text('data not send')]);
      }
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 2 ||
                      value.trim().length > 50) {
                    return "Invalid Input";
                  }
                  return null;
                },
                onSaved: (v) {
                  _title = v!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Invalid Input";
                        }
                        return null;
                      },
                      onSaved: (v) {
                        _quantity = int.parse(v!);
                      },
                      initialValue: '1',
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: _selecterCategory,
                        onSaved: (val) {
                          _selecterCategory = val!;
                        },
                        items: [
                          for (final i in categories.entries)
                            DropdownMenuItem(
                              value: i.value,
                              child: Row(
                                children: [
                                  Container(
                                    decoration:
                                        BoxDecoration(color: i.value.color),
                                    width: 15,
                                    height: 15,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(i.value.title)
                                ],
                              ),
                            )
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selecterCategory = val!;
                          });
                        }),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        _formkey.currentState!.reset();
                      },
                      child: const Text('Reset')),
                  ElevatedButton(
                      onPressed: _loading? null: savesItem, child: _loading? const CircularProgressIndicator(): const Text('Submit'),
                      )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
