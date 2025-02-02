import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'report_search_bloc.dart'; // Import your BLoC file

class SearchPage extends StatefulWidget {
  final String companyCode;
  final String userCode;
  final String str;
  final String fieldId; // Add FieldId

  const SearchPage({
    Key? key,
    required this.companyCode,
    required this.userCode,
    required this.str,
    required this.fieldId,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _localData = [];
  List<Map<String, dynamic>> _originalData = [];
  List<Map<String, bool>> _checkboxVisibility = [];
  Map<String, List<int>> _parentChildMap = {}; // Parent-Child Relationship Map

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc()
        ..add(FetchSearchData(
            companyCode: widget.companyCode,
            userCode: widget.userCode,
            str: widget.str,
            fieldId: widget.fieldId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Page'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SearchError) {
                return Center(child: Text(state.message));
              } else if (state is SearchLoaded) {
                if (_localData.isEmpty) {
                  _localData = List.from(state.data);
                  _originalData = List.from(state.data);
                  _buildParentChildMap(); // Build Parent-Child Relationship Map

                  _checkboxVisibility = _localData.map((item) {
                    return {
                      'ShowMenu': item['ShowMenu'] == 'Y',
                      'CanAdd': item['CanAdd'] == 'Y',
                      'CanEdit': item['CanEdit'] == 'Y',
                      'CanDelete': item['CanDelete'] == 'Y',
                      'CanPrint': item['CanPrint'] == 'Y',
                      'CanExport': item['CanExport'] == 'Y',
                    };
                  }).toList();
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection:
                              Axis.horizontal, // Allows horizontal scrolling
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: DataTable(
                              columnSpacing: 20,
                              dataRowHeight: 50,
                              headingRowHeight: 60,
                              border: TableBorder.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Menu Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Menu Options',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Show Menu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Add',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Print',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Export',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                              rows: _localData.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                final viewLevel = int.parse(item['ViewLevel']);

                                final showShowMenu =
                                    _checkboxVisibility[index]['ShowMenu']!;
                                final showCanAdd =
                                    _checkboxVisibility[index]['CanAdd']!;
                                final showCanEdit =
                                    _checkboxVisibility[index]['CanEdit']!;
                                final showCanDelete =
                                    _checkboxVisibility[index]['CanDelete']!;
                                final showCanPrint =
                                    _checkboxVisibility[index]['CanPrint']!;
                                final showCanExport =
                                    _checkboxVisibility[index]['CanExport']!;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: viewLevel * 16.0),
                                        child: Text(
                                          item['MenuName'],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        item[
                                            'MenuOptions'], // Display MenuOptions directly
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    DataCell(
                                      showShowMenu
                                          ? Checkbox(
                                              value: item['ShowMenu'] == 'Y',
                                              onChanged: (value) {
                                                setState(() {
                                                  _updateCheckboxState(
                                                      index, value!);
                                                });
                                              },
                                            )
                                          : Container(),
                                    ),
                                    DataCell(showCanAdd
                                        ? Checkbox(
                                            value: item['CanAdd'] == 'Y',
                                            onChanged: (value) {
                                              setState(() {
                                                _localData[index]['CanAdd'] =
                                                    value! ? 'Y' : 'N';
                                              });
                                            },
                                          )
                                        : Container()),
                                    DataCell(showCanEdit
                                        ? Checkbox(
                                            value: item['CanEdit'] == 'Y',
                                            onChanged: (value) {
                                              setState(() {
                                                _localData[index]['CanEdit'] =
                                                    value! ? 'Y' : 'N';
                                              });
                                            },
                                          )
                                        : Container()),
                                    DataCell(showCanDelete
                                        ? Checkbox(
                                            value: item['CanDelete'] == 'Y',
                                            onChanged: (value) {
                                              setState(() {
                                                _localData[index]['CanDelete'] =
                                                    value! ? 'Y' : 'N';
                                              });
                                            },
                                          )
                                        : Container()),
                                    DataCell(showCanPrint
                                        ? Checkbox(
                                            value: item['CanPrint'] == 'Y',
                                            onChanged: (value) {
                                              setState(() {
                                                _localData[index]['CanPrint'] =
                                                    value! ? 'Y' : 'N';
                                              });
                                            },
                                          )
                                        : Container()),
                                    DataCell(showCanExport
                                        ? Checkbox(
                                            value: item['CanExport'] == 'Y',
                                            onChanged: (value) {
                                              setState(() {
                                                _localData[index]['CanExport'] =
                                                    value! ? 'Y' : 'N';
                                              });
                                            },
                                          )
                                        : Container()),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Add Save, Cancel, and Delete buttons here
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Save changes
                            context.read<SearchBloc>().add(
                                  SaveChanges(
                                    updatedData: _localData,
                                    str: widget.str,
                                    companyCode: widget.companyCode,
                                    userCode: widget.userCode,
                                    fieldId: widget.fieldId,
                                  ),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Cancel changes
                            setState(() {
                              _localData = List.from(_originalData);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Delete functionality
                            // Add your delete logic here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  /// Build Parent-Child Relationship Map
  void _buildParentChildMap() {
    _parentChildMap.clear();
    for (int i = 0; i < _localData.length; i++) {
      String parentCode = _localData[i]['ParentMenuCode'];
      if (parentCode != '0.0') {
        _parentChildMap.putIfAbsent(parentCode, () => []).add(i);
      }
    }
  }

  /// Update Parent-Child Checkbox Behavior
  void _updateCheckboxState(int index, bool newValue) {
    String menuCode = _localData[index]['MenuCode'];
    _localData[index]['ShowMenu'] = newValue ? 'Y' : 'N';

    if (_parentChildMap.containsKey(menuCode)) {
      for (int childIndex in _parentChildMap[menuCode]!) {
        _updateCheckboxState(childIndex, newValue);
      }
    }
  }
}
