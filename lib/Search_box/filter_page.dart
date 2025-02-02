import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_bloc.dart'; // Import your BLoC file
import 'report_search.dart'; // Import the SearchPage

class FilterPage extends StatelessWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the values to pass
    const String companyCode = '101'; // company code
    const String userCode = '1'; // user code
    const String str =
        'eTFKdGFqMG5ibWN0NGJ4ekIxUG8zaHVzOCtsZ1ozMjVOazZMNWJoZmNrcHVVQ0dWSnM0d0RFS1VxUk5ZQThKdnNGM3RpR1QrZll1dWRNODFJMlFWaXc9PQ==';

    return BlocProvider(
      // Provide the BLoC to the widget tree and pass userCode
      create: (context) => UserGroupBloc(companyCode)..add(FetchUserGroups()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Filter Page'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Group Label and Dropdown
              Row(
                children: [
                  const Text(
                    'User Group:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                      width: 10), // Spacing between label and dropdown
                  Expanded(
                    // Dropdown takes remaining width
                    child: BlocBuilder<UserGroupBloc, UserGroupState>(
                      builder: (context, state) {
                        if (state is UserGroupLoading) {
                          return const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          ); // Custom loader
                        } else if (state is UserGroupLoaded) {
                          return DropdownButton<String>(
                            hint: const Text('Select User Group'),
                            value:
                                state.selectedUserGroup, // Show selected value
                            isExpanded:
                                true, // Ensure dropdown takes full width
                            items: state.userGroups.map((group) {
                              return DropdownMenuItem<String>(
                                value: group['FieldName'], // Display FieldName
                                child: Text(group['FieldName']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              // Handle dropdown selection
                              final selectedGroup = state.userGroups.firstWhere(
                                (group) => group['FieldName'] == value,
                              );
                              context.read<UserGroupBloc>().add(
                                    SelectUserGroup(
                                      selectedGroup['FieldName'],
                                      selectedGroup['FieldId'], // Pass FieldId
                                    ),
                                  );
                              print('Selected: $value');
                            },
                          );
                        } else if (state is UserGroupError) {
                          return Text(state.message); // Show error message
                        }
                        return Container(); // Default empty container
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: 20), // Spacing between dropdown and search button
              // Search button aligned to the right corner
              Align(
                alignment: Alignment.centerRight, // Align to the right
                child: BlocBuilder<UserGroupBloc, UserGroupState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: () {
                        if (state is UserGroupLoaded &&
                            state.selectedUserGroup != null) {
                          // Navigate to SearchPage and pass companyCode, userCode, str, and FieldId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(
                                companyCode: companyCode,
                                userCode: userCode,
                                str: str,
                                fieldId: state
                                    .selectedFieldId!, // Pass selected FieldId
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a user group.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700], // Darker blue color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min, // Minimize row width
                        children: [
                          Icon(Icons.search,
                              color: Colors.white), // Search icon
                          SizedBox(width: 8), // Spacing between icon and text
                          Text(
                            'Search',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
