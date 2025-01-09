import 'dart:developer';

import 'package:client/saleorder/saleorderbloc.dart';
import 'package:client/saleorder/saleorderpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'saleorderdraft_bloc.dart';

class SaleOrderDraftPage extends StatefulWidget {
  @override
  _SaleOrderDraftPageState createState() => _SaleOrderDraftPageState();
}

class _SaleOrderDraftPageState extends State<SaleOrderDraftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _salesmanNameController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  String? _selectedBranch;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<SaleOrderDraftBloc>(context).add(FetchData());
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _salesmanNameController.dispose();
    _itemNameController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sale Order Draft', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Handle + icon action
            },
          ),
        ],
      ),
      body: BlocBuilder<SaleOrderDraftBloc, SaleOrderDraftState>(
        builder: (context, state) {
          if (state is SaleOrderDraftLoading) {
            return _buildLoader();
          } else if (state is SaleOrderDraftLoaded) {
            return _buildForm(state);
          } else if (state is SaleOrderDraftError) {
            return _buildErrorState(state.message);
          }
          return Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildLoader() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text(message, style: TextStyle(color: Colors.red, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildForm(SaleOrderDraftLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                label: 'Select Branch',
                value: _selectedBranch,
                items: state.branches,
                onChanged: (code) => setState(() => _selectedBranch = code),
              ),
              SizedBox(height: 20),
              _buildDropdown(
                label: 'Select Category',
                value: _selectedCategory,
                items: state.categories.map((name) => {'name': name, 'code': name}).toList(),
                onChanged: (code) => setState(() => _selectedCategory = code),
              ),
              SizedBox(height: 20),
              _buildAutocompleteField(
                controller: _customerNameController,
                label: 'Customer Name',
                options: state.customers,
                onSelected: (code) {
                  setState(() {
                    _customerNameController.text = code ?? '';
                  });
                },
              ),
              SizedBox(height: 20),
              _buildAutocompleteField(
                controller: _salesmanNameController,
                label: 'Salesman Name',
                options: state.salesmanNames.map((name) => {'name': name, 'code': name}).toList(),
                onSelected: (code) {
                  setState(() {
                    _salesmanNameController.text = code ?? '';
                  });
                },
              ),
              SizedBox(height: 20),
              _buildAutocompleteField(
                controller: _itemNameController,
                label: 'Item Name',
                options: state.items,
                onSelected: (code) {
                  setState(() {
                    _itemNameController.text = code ?? '';
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      controller: _fromDateController,
                      label: 'From Date',
                      icon: Icons.calendar_today,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildDateField(
                      controller: _toDateController,
                      label: 'To Date',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: Text("OR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              _buildTextField(label: 'Sale Order No (Last 4 digits)'),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      label: 'Reset',
                      color: Colors.red,
                      icon: Icons.close,
                    ),
                    SizedBox(width: 10),
                    _buildActionButton(
                      label: 'Show',
                      color: Colors.blue,
                      icon: Icons.arrow_forward,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Ensure each item has a non-null and unique code
    final validItems = items.map((item) {
      return {
        'name': item['name'] ?? '',
        'code': item['code']?.isNotEmpty == true ? item['code']! : item['name'] ?? '',
      };
    }).toList();

    if (validItems.isEmpty) {
      return Text('No $label available'); // Fallback UI if items are empty
    }

    return DropdownButtonFormField<String>(
      value: value,
      items: validItems.map((Map<String, String> item) {
        return DropdownMenuItem<String>(
          value: item['code'], // Use the code as the value
          child: Text(item['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

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
            labelStyle: TextStyle(color: Colors.grey),
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
      },
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        suffixIcon: GestureDetector(
          onTap: () async {
            try {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                setState(() {
                  controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                });
              }
            } catch (e) {
              // Handle date selection error
            }
          },
          child: Icon(icon),
        ),
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      readOnly: true, // Prevent manual text input
    );
  }

  Widget _buildTextField({required String label}) {
    return TextFormField(
      style: TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildActionButton({required String label, required Color color, required IconData icon}) {
    return ElevatedButton(
      onPressed: () {
        log(label);
        if (label == 'Reset') {
          _resetForm();
        } else if (label == 'Show') {
          // Prepare filter parameters
          final Map<String, String> filters = {
            'userId': '157.0', // Fixed value
            'branchCode': _selectedBranch ?? '', // Selected branch code
            'addUser': '', // Fixed value
            'fromDate': _fromDateController.text, // From date
            'toDate': _toDateController.text, // To date
            'customerCode': _customerNameController.text, // Customer code
            'soNoRecNo': _selectedCategory ?? '', // Selected category
            'qNo': '', // Fixed value
            'accountTypeCode': '', // Fixed value
            'groupName': 'Project', // Fixed value
            'itemCode': _itemNameController.text, // Item code
          };

          // Debugging: Print the filters being passed
          // // print('Filters being passed to SaleOrderPage:');
          // // filters.forEach((key, value) {
          // //   print('$key: $value');
          // });
          print('Navigating to SaleOrderPage with filters: $filters');
          return;
          // Navigate to SaleOrderPage with filters
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: BlocProvider.of<SaleOrderBloc>(context),
                child: SaleOrderPage(filters: filters),
              ),
            ),
          );
        }
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 5),
          Text(label, style: TextStyle(color: Colors.white)),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _customerNameController.clear();
      _salesmanNameController.clear();
      _itemNameController.clear();
      _fromDateController.clear();
      _toDateController.clear();
      _selectedBranch = null;
      _selectedCategory = null;
    });
  }
}