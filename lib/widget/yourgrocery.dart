import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoping_list/data/categories.dart';
import 'package:shoping_list/models/grocery_item.dart';
import 'package:shoping_list/widget/new_item.dart';
import 'dart:convert';

class YourGrocery extends StatefulWidget {
  const YourGrocery({super.key});

  @override
  State<YourGrocery> createState() => _YourGroceryState();
}

class _YourGroceryState extends State<YourGrocery> {
  List<GroceryItem> groceries = [];
  bool _iserror = false;
  bool _isloading = false;
  void _fetchdata() async {
    _isloading = true;
    final List<GroceryItem> templist = [];
    final url = Uri.https('practice-project-635f6-default-rtdb.firebaseio.com',
        'shoping_list.json');
    final response = await http.get(url);
    if (response.body == 'null') {
      setState(() {
        _isloading = false;
      });
      return;
    }
    if (response.statusCode >= 400) {
      setState(() {
        _iserror = true;
        _isloading = false;
      });
      return;
    }
    Map<String, dynamic> data = json.decode(response.body);
    for (final item in data.entries) {
      final categoryy = categories.entries
          .firstWhere(
            (element) => (element.value.title == item.value['category']),
          )
          .value;
      templist.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          category: categoryy,
          quantity: item.value['quantity']));
    }
    setState(() {
      _isloading = false;
      groceries = templist;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchdata();
  }

  void remove(GroceryItem i) async {
    final url = Uri.https('practice-project-635f6-default-rtdb.firebaseio.com',
        'shoping_list/${i.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Someting went wrong'),
        ),
      );
    }
  }

  void addItem() async {
    var gitem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),

    );
    if(gitem != null){
      setState(() {
        groceries.add(gitem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Grocery!!'),
          actions: [
            IconButton(
              onPressed: () {
                addItem();
              },
              icon: const Icon(Icons.add),
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: _isloading
            ? const Center(child: CircularProgressIndicator())
            : _iserror
                ? const Text('Something went wrong')
                : ListView.builder(
                    itemCount: groceries.length,
                    itemBuilder: (context, index) {
                      GroceryItem g = groceries[index];
                      return Dismissible(
                        key: ValueKey(g.id),
                        onDismissed: (direction) {
                          remove(g);
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.square,
                            color: g.category.color,
                          ),
                          title: Row(
                            children: [
                              Text(g.name),
                              const Spacer(),
                              Text('${g.quantity}')
                            ],
                          ),
                        ),
                      );
                    }));
  }
}
