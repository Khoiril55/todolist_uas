import 'dart:convert';
import 'package:todolist_uas/screen/add_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan UAS'),
      ),

      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: getData,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                'Catatan Kosong',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['id'];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item['judul']),
                    subtitle: Text(item['deskripsi']),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          editData(item);
                        } else if (value == 'delete') {
                          deleteData(id);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Text('Edit'),
                            value: 'edit',
                          ),
                          PopupMenuItem(
                            child: Text('Delete'),
                            value: 'delete',
                          ),
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => postData(context),
        label: Text('Add Catatan'),
      ),
    );
  }

  Future<void> postData(BuildContext context) async {
    final route = MaterialPageRoute(
      builder: (context) => addcatatan(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    getData();
  }

  void editData(Map item) {
    final route = MaterialPageRoute(
      builder: (context) => addcatatan(todo: item),
    );
    Navigator.push(context, route);
  }

  Future<void> deleteData(String id) async {
    final url = 'https://64c11656fa35860bae9fef75.mockapi.io/api/v1/users/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showErrorMessage('Delete Gagal');
    }
  }

  Future<void> getData() async {
    final url = 'https://64c11656fa35860bae9fef75.mockapi.io/api/v1/users';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        items = json;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
