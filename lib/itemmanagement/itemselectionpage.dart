import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'itembloc.dart'; // Import the BLoC
import 'reportpage.dart'; // Import the ReportPage

class ItemSelectionPage extends StatefulWidget {
  @override
  _ItemSelectionPageState createState() => _ItemSelectionPageState();
}

class _ItemSelectionPageState extends State<ItemSelectionPage> {
  String? selectedItemCode; // Store the selected item's code
  String quantity = '1'; // Initialize quantity with '1'
  final TextEditingController _itemController = TextEditingController(); // Controller for the item field
  final TextEditingController _quantityController = TextEditingController(); // Controller for the quantity field

  @override
  void initState() {
    super.initState();
    context.read<ItemManagementBloc>().add(FetchItemNames());
    _quantityController.text = quantity; // Set default value of quantity to '1'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Selection'),
        backgroundColor: Colors.blue,
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
        child: BlocBuilder<ItemManagementBloc, ItemManagementState>(
          builder: (context, state) {
            if (state is ItemManagementLoading) {
              // Show only a loading indicator while the API is loading
              return Center(child: CircularProgressIndicator());
            } else if (state is ItemManagementError) {
              // Show an error message if the API fails
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ItemManagementBloc>().add(FetchItemNames()); // Retry fetching items
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is ItemManagementLoaded) {
              // Show the full UI (autocomplete field, quantity field, and buttons) when the API is loaded
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Autocomplete Field for Item Name
                  _buildAutocompleteField(
                    controller: _itemController,
                    label: 'Item Name',
                    options: state.items,
                    onSelected: (code) {
                      setState(() {
                        selectedItemCode = code; // Store the selected item's code
                      });
                      print('Selected Item Code: $code');
                    },
                  ),
                  SizedBox(height: 20),
                  // Quantity TextField with Padding
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding to match the Item Name field
                    child: TextField(
                      controller: _quantityController, // Use the controller for the quantity field
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          quantity = value;
                        });
                      },
                    ),
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
                            selectedItemCode = null;
                            quantity = '1'; // Reset quantity to '1'
                            _itemController.clear(); // Clear the item field
                            _quantityController.text = quantity; // Reset the quantity field to '1'
                          });
                        },
                        icon: Icon(Icons.close, color: Colors.white),
                        label: Text('Reset', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      SizedBox(width: 10),
                      // Show Button (Blue)
                      ElevatedButton(
                        onPressed: () {
                          if (selectedItemCode != null && quantity.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportPage(
                                  itemCode: selectedItemCode!, // Pass the item code
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
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('< Show', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              );
            }
            // Default fallback UI
            return Center(child: Text('No items available'));
          },
        ),
      ),
    );
  }

  // Reusable Autocomplete Field Widget
  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required String label,
    required List<Map<String, String>> options,
    required Function(String?) onSelected,
  }) {
    if (options.isEmpty) {
      return Text('No $label available'); // Fallback UI if options are empty
    }

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((Map<String, String> option) {
          return option['name']?.toLowerCase().contains(textEditingValue.text.toLowerCase()) ?? false;
        }).map((option) => option['name'] ?? '');
      },
      onSelected: (String? selection) {
        final selectedItem = options.firstWhere((item) => item['name'] == selection, orElse: () => {'name': '', 'code': ''});
        onSelected(selectedItem['code']); // Pass the code to the callback
        setState(() {
          controller.text = selection ?? ''; // Set the displayed name
        });
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.black),
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
      },
    );
  }
}