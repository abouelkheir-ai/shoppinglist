import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/categories.dart';
import 'package:shopping_list/models/grocery_items.dart';
import 'package:http/http.dart' as http;

class NewItems extends StatefulWidget {
  const NewItems({super.key});

  @override
  State<NewItems> createState() => _NewItemsState();
}

class _NewItemsState extends State<NewItems> {
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.carbs];
  final _forKey = GlobalKey<FormState>();
  var _isSending = false;

  
  void _saveItem() async {
    if (_forKey.currentState!.validate()) {
      _forKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https('flutter-perp-e481a-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final responese = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory!.title,
          },
        ),
      );

      if (!context.mounted) {
        return;
      }
      final Map<String, dynamic> resData = json.decode(responese.body);
      // response = 404 or 200 or 202
      print('responese.body:' + responese.body);
      Navigator.of(context).pop(
        GroceryItem(
            id: resData['name'],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _forKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value!.isEmpty ||
                      value.trim().length > 50 ||
                      value.trim().isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    _enteredName = value!;
                  });
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value!.length > 10 || value.isEmpty) {
                          return "Please enter a Quantity";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() {
                          _enteredQuantity = int.parse(value!);
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                        color: category.value.color),
                                  ),
                                  const SizedBox(
                                    width: 24,
                                  ),
                                  Text(category.value.title),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          _selectedCategory = value!;
                        }),
                  )
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _forKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('add meal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
