import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_items.dart';
import 'package:shopping_list/screens/new_items.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> myList = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _isLoading = false;
  }
  
  
  
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItems(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      myList.add(newItem);
    });
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-perp-e481a-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);
    print(response.body);
    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later.';
      });
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    print(listData);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      myList = loadedItems;
    });
    print(myList.length);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
      itemCount: myList.length,
      itemBuilder: (BuildContext context, int index) => Dismissible(
        direction: DismissDirection.endToStart,
        key: ValueKey(myList[index]),
        onDismissed: (direction) {
          myList.remove(myList[index]);
        },
        child: ListTile(
          title: Text(myList[index].name),
          trailing: Text(
            myList[index].quantity.toString(),
          ),
          leading: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(color: myList[index].category.color),
          ),
        ),
      ),
    );
    if (myList.isEmpty) {
      content = const Center(child: Text('No items added yet!'));
    }
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(
          _error!,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
        ],
      ),
      body: content,
    );
  }
}
