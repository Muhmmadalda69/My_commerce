import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_commerce/presentation/form_add.dart';

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
                  return Card(
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
}
