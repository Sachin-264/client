import 'package:client/itemmanagement/reportpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'itemrealbloc.dart'; // Adjust the import path as needed
// Import the dummy page

class ItemDraftPage extends StatefulWidget {
  const ItemDraftPage({super.key});

  @override
  _ItemDraftPageState createState() => _ItemDraftPageState();
}

class _ItemDraftPageState extends State<ItemDraftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  Key _itemAutocompleteKey = UniqueKey();

  String? _selectedBranch;
  String? _selectedItemCode;
  String? _quantity = '1';
  dynamic userID;
  String? branch;
  String? str;

  @override
  void initState() {
    super.initState();
    userID = Provider.of<Auth>(context, listen: false).userId;
    str = Provider.of<Auth>(context, listen: false).str;
    branch = Provider.of<Auth>(context, listen: false).userBranch;
    context.read<ItemDraftPageBloc>().add(FetchData(
          userID: userID,
          str: str,
          selectedBranch: branch,
        ));
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<ItemDraftPageBloc, ItemDraftPageState>(
        listener: (context, state) {
          if (state is ItemDraftPageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ItemDraftPageLoaded) {
            if (_selectedBranch == null && state.branches.isNotEmpty) {
              setState(() {
                _selectedBranch = branch;
              });
              // Fetch data only if the branch has changed
              context.read<ItemDraftPageBloc>().add(
                    FetchData(
                        userID: userID,
                        str: str,
                        selectedBranch: _selectedBranch),
                  );
            }
          }
        },
        builder: (context, state) {
          if (state is ItemDraftPageLoading) {
            return _buildLoader();
          } else if (state is ItemDraftPageLoaded) {
            return _buildForm(state);
          } else if (state is ItemDraftPageError) {
            return _buildErrorState(state.message);
          }
          return Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Item Report ', style: TextStyle(color: Colors.white)),
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

  Widget _buildForm(ItemDraftPageLoaded state) {
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
              _buildItemAutocomplete(state.items),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: UnderlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                keyboardType: TextInputType.number,
                initialValue: _quantity, // Set initial value to 1
                onChanged: (value) {
                  setState(() {
                    _quantity = value; // Store the quantity
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  return null;
                },
              ),
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
          _selectedItemCode = null;
          _itemNameController.clear();
        });
        context.read<ItemDraftPageBloc>().add(
              FetchData(selectedBranch: code),
            );
      },
    );
  }

  Widget _buildItemAutocomplete(List<Map<String, String>> items) {
    return _buildAutocompleteField(
      key: _itemAutocompleteKey,
      controller: _itemNameController,
      label: 'Item Name',
      options: items,
      onSelected: (code) {
        setState(() {
          _selectedItemCode = code;
          _itemNameController.text =
              items.firstWhere((item) => item['code'] == code)['name'] ?? '';
        });
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
            onPressed: _navigateToSaleOrderPage,
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
      hint: items.isEmpty ? Text('No data available') : null,
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
          Text(label, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _itemNameController.clear();
      _selectedBranch = null;
      _selectedItemCode = null;
      _quantity = null;
      _itemAutocompleteKey = UniqueKey();
    });
    context.read<ItemDraftPageBloc>().add(FetchData());
  }

  void _navigateToSaleOrderPage() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_selectedItemCode == null || _quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an item and enter a quantity')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportPage(
          itemCode: _selectedItemCode!,
          quantity: _quantity!,
          str: str,
          userID: userID,
        ),
      ),
    );
  }
}
