import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'oderAllocation_page.dart';
import 'orderAllocation_bloc.dart';
import 'orderAllocation_draft_bloc.dart'; // Import Google Fonts

class orderAllocationDraftPage extends StatefulWidget {
  const orderAllocationDraftPage({super.key});

  @override
  _orderAllocationDraftPageState createState() => _orderAllocationDraftPageState();
}

class _orderAllocationDraftPageState extends State<orderAllocationDraftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _salesmanNameController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _orderAllocationNoController = TextEditingController();

  // Keys for Autocomplete widgets
  Key _customerAutocompleteKey = UniqueKey();
  Key _salesmanAutocompleteKey = UniqueKey();
  Key _itemAutocompleteKey = UniqueKey();

  String? _selectedBranch;
  String? _selectedCategory;
  String? _selectedCustomerCode;
  String? _selectedItemCode;
  String? _selectedSalesmanCode;
  dynamic userID;
  String? str;

  @override
  void initState() {
    super.initState();
    // Set default From Date to the 1st day of the current month
    userID = '157.0';
    str ='eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ0thdjJtQzZ6cDhtMW4zSjIvS0YwUVd1b0RBdnNLWitRbmkwV2w5elZUMkE9PQ==';
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    _fromDateController.text = _formatDate(firstDayOfMonth);

    // Set default To Date to the current date
    _toDateController.text = _formatDate(now);

    // Fetch data only once when the widget is initialized
    context.read<orderAllocationDraftBloc>().add(FetchData(userID: userID, str: str));
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _salesmanNameController.dispose();
    _itemNameController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _orderAllocationNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: BlocConsumer<orderAllocationDraftBloc, orderAllocationDraftState>(
        listener: (context, state) {
          if (state is orderAllocationDraftError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is orderAllocationDraftLoaded) {
            // Set default branch and category when data is loaded
            if (_selectedBranch == null && state.branches.isNotEmpty) {
              _selectedBranch = state.branches.first['code'];
              context.read<orderAllocationDraftBloc>().add(
                FetchData(userID: userID, str: str,selectedBranch: _selectedBranch),
              );
            }
            if (_selectedCategory == null && state.categories.isNotEmpty) {
              setState(() {
                _selectedCategory = state.categories.first['code'];
              });
            }
          }
        },
        builder: (context, state) {
          if (state is orderAllocationDraftLoading) {
            return _buildLoader();
          } else if (state is orderAllocationDraftLoaded) {
            return _buildForm(state);
          } else if (state is orderAllocationDraftError) {
            return _buildErrorState(state.message);
          }
          return Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Order Allocation Page',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
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
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(orderAllocationDraftLoaded state) {
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
              _buildDateRangeFields(),
              SizedBox(height: 30),
              Center(
                child: Text(
                  "OR",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildorderAllocationTextField(),
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
          _orderAllocationNoController.clear();
          // Reset other dropdowns when branch changes
          _selectedCategory = null;
          _selectedCustomerCode = null;
          _selectedItemCode = null;
          _customerNameController.clear();
          _itemNameController.clear();
        });
        // Fetch data with the selected branch
        context.read<orderAllocationDraftBloc>().add(
          FetchData(userID: userID, str: str,selectedBranch: code),
        );
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
          _orderAllocationNoController.clear();
        });
      },
      validator: (value) {
        if (_orderAllocationNoController.text.isNotEmpty) {
          return null;
        }
        return value == null ? 'Please select a category' : null;
      },
    );
  }

  Widget _buildSalesmanAutocomplete(List<Map<String, String>> salesmanNames) {
    return _buildAutocompleteField(
      key: _salesmanAutocompleteKey,
      controller: _salesmanNameController,
      label: 'Salesman Name',
      options: salesmanNames,
      onSelected: (code) {
        setState(() {
          _selectedSalesmanCode = code; // Store the selected salesman code
          _salesmanNameController.text = salesmanNames
              .firstWhere((item) => item['code'] == code)['name'] ??
              '';
          _orderAllocationNoController.clear();
        });
      },
    );
  }

  Widget _buildItemAutocomplete(List<Map<String, String>> items) {
    return _buildAutocompleteField(
      key: _itemAutocompleteKey, // Pass the key
      controller: _itemNameController,
      label: 'Item Name',
      options: items,
      onSelected: (code) {
        setState(() {
          _selectedItemCode = code;
          _itemNameController.text =
              items.firstWhere((item) => item['code'] == code)['name'] ?? '';
          _orderAllocationNoController.clear();
        });
      },
    );
  }

  Widget _buildCustomerAutocomplete(List<Map<String, String>> customers) {
    return _buildAutocompleteField(
      key: _customerAutocompleteKey,
      controller: _customerNameController,
      label: 'Customer Name',
      options: customers,
      onSelected: (code) {
        setState(() {
          _selectedCustomerCode = code;
          _customerNameController.text =
              customers.firstWhere((item) => item['code'] == code)['name'] ??
                  '';
          _orderAllocationNoController.clear();
        });
      },
    );
  }

  Widget _buildDateRangeFields() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
              controller: _fromDateController, label: 'From Date'),
        ),
        SizedBox(width: 20),
        Expanded(
          child:
          _buildDateField(controller: _toDateController, label: 'To Date'),
        ),
      ],
    );
  }

  Widget _buildorderAllocationTextField() {
    return TextFormField(
      controller: _orderAllocationNoController,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'SALES ORDER NO (Last 4 digits)',
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey,
        ),
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          _clearOtherFieldsExceptBranchAndDates();
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
            onPressed: _resetForm,
          ),
          SizedBox(width: 10),
          _buildActionButton(
            label: 'Show',
            color: Colors.blue,
            icon: Icons.arrow_forward,
            onPressed: _navigateToorderAllocationPage,
          ),
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
    // Ensure items are unique by value
    final uniqueItems = items.toSet().toList();

    return DropdownButtonFormField<String>(
      value: value,
      items: uniqueItems.map((item) {
        return DropdownMenuItem<String>(
          value: item['code'],
          child: Text(
            item['name']!,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey,
        ),
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      validator: validator,
      hint: uniqueItems.isEmpty ? Text('No data available') : null,
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
      key: key,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
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
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(
              color: Colors.grey,
            ),
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
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey,
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            await _selectDate(controller);
            _orderAllocationNoController.clear();
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
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    setState(() {
      _customerNameController.clear();
      _salesmanNameController.clear();
      _itemNameController.clear();
      _fromDateController.text = _formatDate(firstDayOfMonth);
      _toDateController.text = _formatDate(now);
      _orderAllocationNoController.clear();
      _selectedBranch = null;
      _selectedCategory = null;
      _selectedCustomerCode = null;
      _selectedItemCode = null;
      _customerAutocompleteKey = UniqueKey();
      _salesmanAutocompleteKey = UniqueKey();
      _itemAutocompleteKey = UniqueKey();

      // Fetch data again to reset the branch and category dropdowns
      context.read<orderAllocationDraftBloc>().add(FetchData(userID: userID, str: str));
    });
  }

  void _navigateToorderAllocationPage() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

final Map<String, String> filters = {
  'UserCode': '1',
  'BranchCode': _selectedBranch ?? '',
  'AddUser': '',
  'FromDate': _fromDateController.text,
  'ToDate': _toDateController.text,
  'AccountCode': _selectedCustomerCode ?? '',
  'SONOMasterRecNo': _selectedCategory ??  '0',
  'ActualQuotationNo': '0',
  'AccountTypeCode':'', // 'orderAllocationNo': _orderAllocationNoController.text,
  'GroupName': '',
  'ItemNo': _selectedItemCode ?? '',
  'SalesManRecNo': _selectedSalesmanCode ?? '0',
  'str': str.toString(),
};

    print('Filter Data:');
    filters.forEach((key, value) {
      print('$key: $value');
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<orderAllocationBloc>(),
          child: orderAllocationPage(filters: filters),
        ),
      ),
    );
  }

  void _clearOtherFieldsExceptBranchAndDates() {
    setState(() {
      _customerNameController.clear();
      _salesmanNameController.clear();
      _itemNameController.clear();
      _selectedCategory = null;
      _selectedCustomerCode = null;
      _selectedItemCode = null;
      _customerAutocompleteKey = UniqueKey();
      _salesmanAutocompleteKey = UniqueKey();
      _itemAutocompleteKey = UniqueKey();
    });
  }
}