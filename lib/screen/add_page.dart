import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;

class addcatatan extends StatefulWidget {
  final Map? todo;
  const addcatatan({super.key, this.todo});

  @override
  State<addcatatan> createState() => _addcatatanState();
}

class _addcatatanState extends State<addcatatan> {
  TextEditingController judulController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final judul = todo['judul'];
      final deskripsi = todo['deskripsi'];
      judulController.text = judul;
      deskripsiController.text = deskripsi;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Catatan' : 'Tambahkan Catatan'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: judulController,
            decoration: InputDecoration(hintText: 'Judul'),
          ),
          SizedBox(height: 20),
          TextField(
            controller: deskripsiController,
            decoration: InputDecoration(hintText: 'Deskripsi'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 10,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isEdit ? UpdateData : submitCatatan,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(isEdit ? 'Update' : 'Tambahkan'),
            ),
          ),
        ],
      ),
    );
  }

  void UpdateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print('Tidak bisa memanggil data');
      return;
    }
    final id = todo['id'];
    final judul = judulController.text;
    final deskripsi = deskripsiController.text;

     if (judul.isEmpty || deskripsi.isEmpty) {
      showErrorMessage("Judul dan Deskripsi harus diisi");
      return;
    }
    
    final body = {
      "judul": judul,
      "deskripsi": deskripsi,
    };
    final url = 'https://64c11656fa35860bae9fef75.mockapi.io/api/v1/users/$id';
    try {
      final response = await http.put(Uri.parse(url),
          body: json.encode(body),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        judulController.text = '';
        deskripsiController.text = '';
        showSuccessMessage("Berhasil Update!");
      } else {
        showErrorMessage("Gagal Update!");
      }
    } catch (e) {
      print(e.toString());
      showErrorMessage("Terjadi kesalahan: ${e.toString()}");
    }
  }

  void submitCatatan() async {
    final judul = judulController.text;
    final deskripsi = deskripsiController.text;
    final body = {
      "judul": judul,
      "deskripsi": deskripsi,
    };
    final url = 'https://64c11656fa35860bae9fef75.mockapi.io/api/v1/users';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 201) {
        judulController.text = '';
        deskripsiController.text = '';
        showSuccessMessage("Catatan berhasil ditambahkan!");
      } else {
        showErrorMessage("Gagal menambahkan catatan!");
      }
    } catch (e) {
      print(e.toString());
      showErrorMessage("Terjadi kesalahan: ${e.toString()}");
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
