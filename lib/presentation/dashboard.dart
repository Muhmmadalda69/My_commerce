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
  String _searchQuery = ''; // Teks pencarian
  bool _isSearchActive = false;
  List<Map<String, dynamic>> _searchResults = [];
  TextEditingController _searchTextController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _isSearchActive = value.isNotEmpty;
                  });
                  _performSearch();
                  _sortSearchResults(); // Urutkan hasil pencarian
                },
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _performSearch();
                  _sortSearchResults(); // Urutkan hasil pencarian
                },
                focusNode: _isSearchActive ? _searchFocusNode : null,
                controller: _searchTextController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.all(15),
                  prefixIconColor: Colors.blue,
                  suffixIcon: _isSearchActive
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _isSearchActive = false;
                            });
                            _searchFocusNode.unfocus();
                            _searchTextController.clear();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('barang').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                  if (snapshot.hasData) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        maxCrossAxisExtent: 200,
                      ),
                      itemCount: _isSearchActive
                          ? _searchResults.length
                          : snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data;
                        if (_isSearchActive) {
                          data = _searchResults[index];
                        } else {
                          data = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                        }
                        var documentId = snapshot.data!.docs[index].id;
                        // Filter data berdasarkan teks pencarian
                        if (_searchQuery.isNotEmpty &&
                            !data['nama_barang']
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase())) {
                          return Container(); // Tampilkan Container kosong jika data tidak sesuai dengan pencarian
                        }

                        // Tampilkan data jika sesuai dengan pencarian atau pencarian kosong
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
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
          ],
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

  void _performSearch() {
    _searchResults.clear();

    if (_searchQuery.isNotEmpty) {
      var snapshot =
          FirebaseFirestore.instance.collection('barang').snapshots();
      snapshot.forEach((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['nama_barang']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase())) {
            setState(() {
              _searchResults.add(data);
            });
          }
        });
      });
    }

    setState(() {
      _isSearchActive = _searchQuery.isNotEmpty;
      if (!_isSearchActive) {
        _searchResults
            .clear(); // Menonaktifkan fitur search dan menghapus hasil pencarian
      }
    });
  }

  void _sortSearchResults() {
    _searchResults.sort((a, b) {
      var aContainsQuery =
          a['nama_barang'].toLowerCase().contains(_searchQuery.toLowerCase());
      var bContainsQuery =
          b['nama_barang'].toLowerCase().contains(_searchQuery.toLowerCase());

      if (aContainsQuery && bContainsQuery) {
        return a['nama_barang']
            .toLowerCase()
            .indexOf(_searchQuery.toLowerCase())
            .compareTo(
              b['nama_barang']
                  .toLowerCase()
                  .indexOf(_searchQuery.toLowerCase()),
            );
      } else if (aContainsQuery) {
        return -1;
      } else if (bContainsQuery) {
        return 1;
      } else {
        return 0;
      }
    });
  }
}
