import 'dart:developer';
import 'package:client/invoice/invoice%20bloc.dart';
import 'package:client/invoice/invoice_draft_bloc.dart';
import 'package:client/invoice/invoicepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceDraft extends StatefulWidget {
  @override
  _PPSDraftPageState createState() => _PPSDraftPageState();
}

class _PPSDraftPageState extends State<InvoiceDraft> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _salesmanNameController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _saleOrderNoController = TextEditingController();

  // Keys for Autocomplete widgets
  Key _customerAutocompleteKey = UniqueKey();
  Key _salesmanAutocompleteKey = UniqueKey();
  Key _itemAutocompleteKey = UniqueKey();

  String? _selectedBranch;
  String? _selectedCategory;
  String? _selectedCustomerCode; // Store customer code
  String? _selectedItemCode; // Store item code

  @override
  void initState() {
    super.initState();
    // Set default From Date to the 1st day of the current month
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    _fromDateController.text = _formatDate(firstDayOfMonth);

    // Set default To Date to the current date
    _toDateController.text = _formatDate(now);

    // Fetch data
    context.read<InvoiceDraftPageBloc>().add(FetchData());
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _salesmanNameController.dispose();
    _itemNameController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _saleOrderNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<InvoiceDraftPageBloc, InvoiceDraftPageState>(
        listener: (context, state) {
          if (state is InvoiceDraftPageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is InvoiceDraftPageLoading) {
            return _buildLoader();
          } else if (state is InvoiceDraftPageLoaded) {
            return _buildForm(state);
          } else if (state is InvoiceDraftPageError) {
            return _buildErrorState(state.message);
          }
          return Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title:
          Text('Invoice Report Filter', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blue,
      iconTheme: IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: Colors.white),
          onPressed: () {
            // Handle + icon action
          },
        ),
      ],
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

  Widget _buildForm(InvoiceDraftPageLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBranchDropdown(state.branches),
              SizedBox(height: 20),
              _buildCategoryDropdown(state.categories),
              SizedBox(height: 20),
              _buildCustomerAutocomplete(state.customers),
              SizedBox(height: 20),
              // _buildSalesmanAutocomplete(state.salesmanNames),
              SizedBox(height: 20),
              // _buildItemAutocomplete(state.items),
              SizedBox(height: 20),
              _buildDateRangeFields(),
              SizedBox(height: 30),
              Center(
                  child: Text("OR",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))),
              SizedBox(height: 20),
              _buildSaleOrderTextField(),
              SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchDropdown(List<Map<String, String>> branches) {
    return _buildDropdown(
      label: 'Select Branch',
      value: _selectedBranch,
      items: branches,
      onChanged: (code) {
        setState(() {
          _selectedBranch = code;
          _saleOrderNoController.clear();
        });
      },
    );
  }

  Widget _buildCategoryDropdown(List<Map<String, String>> categories) {
    return _buildDropdown(
      label: 'Select Category',
      value: _selectedCategory,
      items: categories,
      onChanged: (code) {
        setState(() {
          _selectedCategory = code;
          _saleOrderNoController.clear();
        });
      },
      validator: (value) {
        if (_saleOrderNoController.text.isNotEmpty) {
          return null;
        }
        return value == null ? 'Please select Select Category' : null;
      },
    );
  }

  Widget _buildCustomerAutocomplete(List<Map<String, String>> customers) {
    return _buildAutocompleteField(
      key: _customerAutocompleteKey, // Pass the key
      controller: _customerNameController,
      label: 'Customer Name',
      options: customers,
      onSelected: (code) {
        setState(() {
          _selectedCustomerCode = code;
          _customerNameController.text =
              customers.firstWhere((item) => item['code'] == code)['name'] ??
                  '';
          _saleOrderNoController.clear();
        });
      },
    );
  }

  // Widget _buildSalesmanAutocomplete(List<String> salesmanNames) {
  //   return _buildAutocompleteField(
  //     key: _salesmanAutocompleteKey, // Pass the key
  //     controller: _salesmanNameController,
  //     label: 'Salesman Name',
  //     options:
  //         salesmanNames.map((name) => {'name': name, 'code': name}).toList(),
  //     onSelected: (code) {
  //       setState(() {
  //         _salesmanNameController.text = code ?? '';
  //         _saleOrderNoController.clear();
  //       });
  //     },
  //   );
  // }

  // Widget _buildItemAutocomplete(List<Map<String, String>> items) {
  //   return _buildAutocompleteField(
  //     key: _itemAutocompleteKey, // Pass the key
  //     controller: _itemNameController,
  //     label: 'Item Name',
  //     options: items,
  //     onSelected: (code) {
  //       setState(() {
  //         _selectedItemCode = code;
  //         _itemNameController.text =
  //             items.firstWhere((item) => item['code'] == code)['name'] ?? '';
  //         _saleOrderNoController.clear();
  //       });
  //     },
  //   );
  // }

  Widget _buildDateRangeFields() {
    return Row(
      children: [
        Expanded(
            child: _buildDateField(
                controller: _fromDateController, label: 'From Date')),
        SizedBox(width: 20),
        Expanded(
            child: _buildDateField(
                controller: _toDateController, label: 'To Date')),
      ],
    );
  }

  Widget _buildSaleOrderTextField() {
    return TextFormField(
      controller: _saleOrderNoController,
      style: TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: 'P. Invoice NO.(Last 4 digits)',
        labelStyle: TextStyle(color: Colors.grey),
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          _clearOtherFieldsExceptBranchAndDates(); // Clear other fields and reset Autocomplete widgets
        }
      },
    );
  }

  Widget _buildActionButtons() {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildActionButton(
              label: 'Reset',
              color: Colors.red,
              icon: Icons.close,
              onPressed: _resetForm),
          SizedBox(width: 10),
          _buildActionButton(
              label: 'Show',
              color: Colors.blue,
              icon: Icons.arrow_forward,
              onPressed: _navigateToSaleOrderPage),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['code'],
          child: Text(item['name']!,
              style: TextStyle(fontWeight: FontWeight.bold)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      validator: validator,
    );
  }

  Widget _buildAutocompleteField({
    Key? key,
    required TextEditingController controller,
    required String label,
    required List<Map<String, String>> options,
    required Function(String?) onSelected,
  }) {
    return Autocomplete<String>(
      key: key, // Use the provided key
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty)
          return const Iterable<String>.empty();
        return options
            .where((option) =>
                option['name']
                    ?.toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()) ??
                false)
            .map((option) => option['name'] ?? '');
      },
      onSelected: (String? selection) {
        final selectedItem = options.firstWhere(
            (item) => item['name'] == selection,
            orElse: () => {'name': '', 'code': ''});
        onSelected(selectedItem['code']);
        controller.text = selection ?? '';
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
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
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            await _selectDate(controller);
            _saleOrderNoController.clear();
          },
        ),
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      readOnly: true,
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        controller.text = _formatDate(picked);
      }
    } catch (e) {
      log('Error selecting date: $e');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${_getMonthAbbreviation(date.month)}-${date.year}";
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
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
      // Clear all text fields
      _customerNameController.clear();
      _salesmanNameController.clear();
      _itemNameController.clear();
      _fromDateController.clear();
      _toDateController.clear();
      _saleOrderNoController.clear();

      // Clear all selected values
      _selectedBranch = null;
      _selectedCategory = null;
      _selectedCustomerCode = null;
      _selectedItemCode = null;

      // Update keys to force Autocomplete widgets to rebuild
      _customerAutocompleteKey = UniqueKey();
      _salesmanAutocompleteKey = UniqueKey();
      _itemAutocompleteKey = UniqueKey();

      // Debug logs to verify keys are updated
      log('Customer Autocomplete Key: $_customerAutocompleteKey');
      log('Salesman Autocomplete Key: $_salesmanAutocompleteKey');
      log('Item Autocomplete Key: $_itemAutocompleteKey');
    });

    // Debug logs for controllers
    log('Customer Name Controller: ${_customerNameController.text}');
    log('Salesman Name Controller: ${_salesmanNameController.text}');
    log('Item Name Controller: ${_itemNameController.text}');
  }

  void _navigateToSaleOrderPage() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final Map<String, String> filters = {
      'userId': '157.0',
      'branchCode': _selectedBranch ?? '',
      'addUser': '',
      'fromDate': _fromDateController.text, // Already in "01-Jan-2025" format
      'toDate': _toDateController.text, // Already in "01-Jan-2025" format
      'customerCode': _selectedCustomerCode ?? '',
      'soNoRecNo': _selectedCategory ?? '',
      'saleOrderNo': _saleOrderNoController.text,
      'accountTypeCode': '',
      'groupName': 'Project',
      'itemCode': _selectedItemCode ?? '',
    };

    print('Filter Data:');
    filters.forEach((key, value) {
      print('$key: $value');
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<InvoiceBloc>(),
          child: InvoicePage(filters: filters),
        ),
      ),
    );
  }

  void _clearOtherFieldsExceptBranchAndDates() {
    setState(() {
      // Clear text fields
      _customerNameController.clear();
      _salesmanNameController.clear();
      _itemNameController.clear();

      // Clear selected values
      _selectedCategory = null;
      _selectedCustomerCode = null;
      _selectedItemCode = null;

      // Update keys to force Autocomplete widgets to rebuild
      _customerAutocompleteKey = UniqueKey();
      _salesmanAutocompleteKey = UniqueKey();
      _itemAutocompleteKey = UniqueKey();

      // Debug logs to verify keys are updated
      log('Customer Autocomplete Key: $_customerAutocompleteKey');
      log('Salesman Autocomplete Key: $_salesmanAutocompleteKey');
      log('Item Autocomplete Key: $_itemAutocompleteKey');
    });

    // Debug logs for controllers
    log('Customer Name Controller: ${_customerNameController.text}');
    log('Salesman Name Controller: ${_salesmanNameController.text}');
    log('Item Name Controller: ${_itemNameController.text}');
  }
}