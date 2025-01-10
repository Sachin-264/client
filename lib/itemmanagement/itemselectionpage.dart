import 'dart:async';
import 'package:client/itemmanagement/reportpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'itembloc.dart'; // Import the BLoC

class ItemSelectionPage extends StatefulWidget {
  @override
  _ItemSelectionPageState createState() => _ItemSelectionPageState();
}

class _ItemSelectionPageState extends State<ItemSelectionPage> {
  String? selectedItem;
  String quantity = '';
  String searchQuery = '';
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    context.read<ItemManagementBloc>().add(FetchItemNames());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Selection'),
        backgroundColor: Colors.blue, // Blue background
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Back button
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Name TextField with Autocomplete
            TextField(
              decoration: InputDecoration(
                labelText: 'Item Name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _debouncer.run(() {
                  setState(() {
                    searchQuery = value;
                  });
                });
              },
            ),
            SizedBox(height: 20),
            // Autocomplete List
            BlocBuilder<ItemManagementBloc, ItemManagementState>(
              builder: (context, state) {
                if (state is ItemManagementLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ItemManagementError) {
                  return Center(child: Text(state.message));
                } else if (state is ItemManagementLoaded) {
                  final filteredItems = state.items.where((item) {
                    return item['name']!
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }).toList();

                  return Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          title: Text(item['name'] ?? ''),
                          onTap: () {
                            setState(() {
                              selectedItem = item['code']; // Store the item code
                              searchQuery = item['name']!; // Auto-fill the search field
                            });
                            // Print name and code to console
                            print('Selected Item Name: ${item['name']}');
                            print('Selected Item Code: ${item['code']}');
                          },
                        );
                      },
                    ),
                  );
                }
                return Center(child: Text('No items available'));
              },
            ),
            SizedBox(height: 20),
            // Quantity TextField
            TextField(
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  quantity = value;
                });
              },
            ),
            SizedBox(height: 20),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Reset Button (Red with Cross Icon)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedItem = null;
                      quantity = '';
                      searchQuery = '';
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.white),
                  label: Text('Reset', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red background
                  ),
                ),
                SizedBox(width: 10),
                // Show Button (Blue)
                ElevatedButton(
                  onPressed: () {
                    if (selectedItem != null && quantity.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportPage(
                            itemCode: selectedItem!, // Pass the item code
                            quantity: quantity, // Pass the quantity
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select an item and enter quantity')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue background
                  ),
                  child: Text('< Show', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Debouncer class to reduce unnecessary UI rebuilds
class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}