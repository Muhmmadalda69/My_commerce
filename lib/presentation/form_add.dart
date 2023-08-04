// ignore_for_file: unused_import, library_private_types_in_public_api, unnecessary_import, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class FormAdd extends StatefulWidget {
  const FormAdd({super.key});
  @override
  _FormAdd createState() => _FormAdd();
}

class _FormAdd extends State<FormAdd> {
  XFile? image;

  final ImagePicker picker = ImagePicker();

  String _namaBarang = ''; // Variabel untuk menyimpan teks dari TextField

  //we can upload image from camera or from gallery based on parameter
  Future getImage(ImageSource media) async {
    XFile? img = await picker.pickImage(source: media);

    setState(() {
      image = img;
    });
  }

  //show popup dialog
  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Please choose media to select'),
            // ignore: sized_box_for_whitespace
            content: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Fungsi untuk mengunggah gambar ke Firebase Storage dan menyimpan data ke Firestore
  Future<void> _uploadData(String namaBarang, XFile? image) async {
    if (image == null) {
      _showSnackBar("Please select an image.");
      return;
    }

    // Simpan gambar ke Firebase Storage
    String imagePath = await _uploadImage(image);

    // Simpan data nama barang ke Firestore
    try {
      await FirebaseFirestore.instance.collection('barang').add({
        'nama_barang': namaBarang,
        'image_path': imagePath,
      });

      _showSnackBar("Data berhasil disimpan.");
    } catch (e) {
      _showSnackBar("Gagal menyimpan data: $e");
    }
  }

  // Fungsi untuk mengunggah gambar ke Firebase Storage
  Future<String> _uploadImage(XFile image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(File(image.path));
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Fungsi untuk menampilkan notifikasi menggunakan SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TAMBAH DATA",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //if image not null show the image
            //if image null show text
            image != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        //to show image, you type like this.
                        File(image!.path),
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      ),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 30),
                    color: Colors.blue[100],
                    child: const Text(
                      "No Image",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
            ElevatedButton(
              onPressed: () {
                myAlert();
              },
              child: const Text('UPLOAD GAMBAR'),
            ),
            const SizedBox(
              height: 7,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _namaBarang = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                  hintText: 'MASUKAN NAMA BARANG',
                ),
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () {
                  // Panggil fungsi untuk mengirim data ke Firestore
                  _uploadData(_namaBarang, image);
                  Navigator.of(context).pop();
                },
                child: const Text('SUBMIT'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
