import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_commerce/presentation/form_add.dart';
import 'package:my_commerce/presentation/form_edit.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: const Color.fromARGB(255, 53, 108, 211),
        title: const Text(
          "BERANDA",
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('barang').snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  maxCrossAxisExtent: 200,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  var documentId = snapshot.data!.docs[index].id;
                  return InkWell(
                    onTap: () {
                      // Tampilkan dialog opsi ketika long-press terdeteksi
                      _showOptionsDialog(documentId);
                    },
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.blue,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: GridTile(
                        footer: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          height: 30,
                          padding: const EdgeInsets.all(6),
                          // color: const Color.fromARGB(255, 33, 149, 243),
                          child: Text(
                            data['nama_barang'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          // Tambahkan logic untuk mengedit atau menghapus data jika diperlukan
                          // ...
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),

                          // ignore: sort_child_properties_last
                          child: Image.network(data['image_path'],
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const FormAdd()),
          );
        },
        hoverColor: Colors.indigo[400],
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showOptionsDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Opsi"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman FormEdit dengan mengirimkan documentId sebagai parameter
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FormEdit(documentId: documentId),
                    ),
                  );
                },
                child: const Text("Edit"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Hapus data dari Firestore berdasarkan documentId
                  final docRef = FirebaseFirestore.instance
                      .collection('barang')
                      .doc(documentId);
                  final docSnapshot = await docRef.get();
                  final data = docSnapshot.data();
                  _deleteData(documentId, data!['image_path']);
                  Navigator.pop(
                      context); // Tutup dialog setelah berhasil menghapus
                },
                child: const Text("Hapus"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteData(String documentId, String imagePath) async {
    void _showSnackBar(String message) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    try {
      // Hapus data dari Firestore
      await FirebaseFirestore.instance
          .collection('barang')
          .doc(documentId)
          .delete();

      // Hapus file dari Firebase Storage berdasarkan URL yang ada di imagePath
      if (imagePath.isNotEmpty) {
        Reference ref = FirebaseStorage.instance.refFromURL(imagePath);
        await ref.delete();
      }

      _showSnackBar("Data berhasil dihapus.");
    } catch (e) {
      _showSnackBar("Gagal menghapus data: $e");
    }
  }
}
