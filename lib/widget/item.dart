class Item {
  String nama;
  String gambar;

  Item({required this.nama, required this.gambar});

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'gambar': gambar,
    };
  }
}
