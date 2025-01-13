import 'dart:developer';
import 'package:client/PPS%20report/PPSreportbloc.dart';
import 'package:client/PPS%20report/PPSreportpage.dart';
import 'package:client/PPS%20report/ppsdraftbloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/saleorder/saleorderbloc.dart';
import 'package:client/saleorder/saleorderpage.dart';

class PPSDraftPage extends StatefulWidget {
  @override
  _PPSDraftPageState createState() => _PPSDraftPageState();
}

class _PPSDraftPageState extends State<PPSDraftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _salesmanNameController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _saleOrderNoController = TextEditingController();

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
    _fromDateController.text =
        "${firstDayOfMonth.day.toString().padLeft(2, '0')}/${firstDayOfMonth.month.toString().padLeft(2, '0')}/${firstDayOfMonth.year}";

    // Set default To Date to the current date
    _toDateController.text =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    // Fetch data
    context.read<PPSDraftPageBloc>().add(FetchData());
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
      body: BlocConsumer<PPSDraftPageBloc, PPSDraftPageState>(
        listener: (context, state) {
          if (state is PPSDraftPageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PPSDraftPageLoading) {
            return _buildLoader();
          } else if (state is PPSDraftPageLoaded) {
            return _buildForm(state);
          } else if (state is PPSDraftPageError) {
            return _buildErrorState(state.message);
          }
          return Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('PDS Report Filter', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blue,
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

  Widget _buildForm(PPSDraftPageLoaded state) {
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
              _buildSalesmanAutocomplete(state.salesmanNames),
              SizedBox(height: 20),
              _buildItemAutocomplete(state.items),
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
    );
  }

  Widget _buildCustomerAutocomplete(List<Map<String, String>> customers) {
    return _buildAutocompleteField(
      controller: _customerNameController,
      label: 'Customer Name',
      options: customers,
      onSelected: (code) {
        setState(() {
          _selectedCustomerCode = code; // Store the selected customer code
          _customerNameController.text =
              customers.firstWhere((item) => item['code'] == code)['name'] ??
                  '';
          _saleOrderNoController.clear();
        });
      },
    );
  }

  Widget _buildSalesmanAutocomplete(List<String> salesmanNames) {
    return _buildAutocompleteField(
      controller: _salesmanNameController,
      label: 'Salesman Name',
      options:
          salesmanNames.map((name) => {'name': name, 'code': name}).toList(),
      onSelected: (code) {
        _salesmanNameController.text = code ?? '';
        _saleOrderNoController.clear();
      },
    );
  }

  Widget _buildItemAutocomplete(List<Map<String, String>> items) {
    return _buildAutocompleteField(
      controller: _itemNameController,
      label: 'Item Name',
      options: items,
      onSelected: (code) {
        setState(() {
          _selectedItemCode = code; // Store the selected item code
          _itemNameController.text =
              items.firstWhere((item) => item['code'] == code)['name'] ?? '';
          _saleOrderNoController.clear();
        });
      },
    );
  }

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
        labelText: 'Sale Order No (Last 4 digits)',
        labelStyle: TextStyle(color: Colors.grey),
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          _clearOtherFields();
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
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required String label,
    required List<Map<String, String>> options,
    required Function(String?) onSelected,
  }) {
    return Autocomplete<String>(
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
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      }
    } catch (e) {
      log('Error selecting date: $e');
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
      _customerNameController.clear();
      _salesmanNameController.clear();
      _itemNameController.clear();
      _fromDateController.clear();
      _toDateController.clear();
      _saleOrderNoController.clear();
      _selectedBranch = null;
      _selectedCategory = null;
      _selectedCustomerCode = null; // Reset customer code
      _selectedItemCode = null; // Reset item code
    });
  }

  void _clearOtherFields() {
    setState(() {
      _customerNameController.clear();
      _salesmanNameController.clear();
      _itemNameController.clear();
      _fromDateController.clear();
      _toDateController.clear();
      _selectedBranch = null;
      _selectedCategory = null;
      _selectedCustomerCode = null; // Clear customer code
      _selectedItemCode = null; // Clear item code
    });
  }

  void _navigateToSaleOrderPage() {
    // Check if the form is valid
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prepare filter parameters
    final Map<String, String> filters = {
      // 'userId': '157.0',
      'branchCode': _selectedBranch ?? '',
      // 'addUser': '',
      'fromDate': _fromDateController.text,
      'toDate': _toDateController.text,
      // 'customerCode':
      //     _selectedCustomerCode ?? '', // Use the stored customer code
      // 'soNoRecNo': _selectedCategory ?? '1',
      // 'qNo': '',
      // 'accountTypeCode': '',
      // 'groupName': 'Project',
      // 'itemCode': _selectedItemCode ?? '', // Use the stored item code
    };

    // Print the filter data to the console
    print('Filter Data:');
    filters.forEach((key, value) {
      print('$key: $value');
    });

    // Navigate to SaleOrderPage with filters
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<PpsReportBloc>(),
          child: PpsReportPage(filters: filters),
        ),
      ),
    );
  }
}
