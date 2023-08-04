import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FormEdit extends StatefulWidget {
  final String documentId;

  const FormEdit({required this.documentId, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FormEditState createState() => _FormEditState();
}

class _FormEditState extends State<FormEdit> {
  XFile? image;
  final ImagePicker picker = ImagePicker();
  String _namaBarang = '';
  // ignore: unused_field
  String _imagePath = '';

  //we can upload image from camera or from gallery based on parameter
  Future getImage(ImageSource media) async {
    XFile? img = await picker.pickImage(source: media);

    setState(() {
      image = img;
    });
  }

  // Method ini akan dijalankan saat halaman dibuka
  // Mengambil data dari Firestore sesuai documentId dan mengisi nilai _namaBarang dan _imagePath
  Future<void> _fetchData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('barang')
          .doc(widget.documentId)
          .get();
      if (documentSnapshot.exists) {
        setState(() {
          _namaBarang = documentSnapshot['nama_barang'];
          _imagePath = documentSnapshot['image_path'];
        });
      }
    } catch (e) {
      _showSnackBar("Gagal mengambil data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fungsi untuk menampilkan notifikasi menggunakan SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String> _getImageUrl(String imagePath) async {
    Reference ref = FirebaseStorage.instance.ref().child(imagePath);
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              child: _imagePath.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imagePath,
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
                // Isi teks dari Firestore
                controller: TextEditingController(text: _namaBarang),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                  hintText: 'MASUKAN NAMA BARANG',
                ),
              ),
            ),
            // ignore: avoid_unnecessary_containers
            Container(
              child: ElevatedButton(
                onPressed: () {
                  // Panggil fungsi untuk mengirim data ke Firestore
                  _uploadData(widget.documentId, _namaBarang, image);
                  Navigator.of(context).pop();
                },
                child: const Text('EDIT'),
              ),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _uploadData(
      String documentId, String namaBarang, XFile? image) async {
    if (image == null) {
      _showSnackBar("Please select an image.");
      return;
    }

    // Hapus gambar lama dari Firebase Storage
    if (_imagePath.isNotEmpty) {
      try {
        Reference oldImageRef = FirebaseStorage.instance.refFromURL(_imagePath);
        await oldImageRef.delete();
      } catch (e) {
        print("Gagal menghapus gambar lama: $e");
      }
    }

    // Update gambar ke Firebase Storage
    String imagePath = await _uploadImage(image);

    // Simpan data nama barang ke Firestore
    try {
      await FirebaseFirestore.instance
          .collection('barang')
          .doc(documentId)
          .update({
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
}
