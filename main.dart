import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ============================================================
// MODEL DATA
// Class sederhana untuk menyimpan data satu mahasiswa.
// ============================================================
class Mahasiswa {
  String nim;
  String nama;
  String prodi;
  String kelas;

  Mahasiswa({
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.kelas,
  });
}

// Hasil yang dikirim balik dari halaman Detail ke halaman Daftar
class HasilDetail {
  final String aksi; // 'edit' atau 'hapus'
  final Mahasiswa? data;
  HasilDetail(this.aksi, [this.data]);
}

// ============================================================
// DIALOG KONFIRMASI HAPUS (Tahap 6) - dipakai di 2 tempat
// ============================================================
Future<bool> konfirmasiHapus(BuildContext context) async {
  final hasil = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Konfirmasi'),
      content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return hasil ?? false; // jika dialog ditutup tanpa pilih -> dianggap batal
}

// ============================================================
// APLIKASI UTAMA
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Data Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DataMahasiswaPage(),
    );
  }
}

// ============================================================
// TAHAP 1 + 7 + TANTANGAN: HALAMAN DAFTAR MAHASISWA
// StatefulWidget karena datanya bisa berubah (tambah/edit/hapus/cari)
// ============================================================
class DataMahasiswaPage extends StatefulWidget {
  const DataMahasiswaPage({super.key});

  @override
  State<DataMahasiswaPage> createState() => _DataMahasiswaPageState();
}

class _DataMahasiswaPageState extends State<DataMahasiswaPage> {
  // Penyimpanan sementara: List di memori (hilang saat app ditutup)
  final List<Mahasiswa> _data = [
    Mahasiswa(nim: '231001', nama: 'Andi Saputra', prodi: 'Informatika', kelas: 'TI-3A'),
    Mahasiswa(nim: '231002', nama: 'Budi Santoso', prodi: 'Informatika', kelas: 'TI-3A'),
    Mahasiswa(nim: '231003', nama: 'Citra Lestari', prodi: 'Sistem Informasi', kelas: 'SI-3B'),
    Mahasiswa(nim: '231004', nama: 'Dewi Anggraini', prodi: 'Sistem Informasi', kelas: 'SI-3B'),
    Mahasiswa(nim: '231005', nama: 'Eko Prasetyo', prodi: 'Teknik Komputer', kelas: 'TK-3A'),
    Mahasiswa(nim: '231006', nama: 'Fajar Nugroho', prodi: 'Teknik Komputer', kelas: 'TK-3A'),
    Mahasiswa(nim: '231007', nama: 'Gita Permata', prodi: 'Informatika', kelas: 'TI-3B'),
    Mahasiswa(nim: '231008', nama: 'Hendra Wijaya', prodi: 'Informatika', kelas: 'TI-3B'),
    Mahasiswa(nim: '231009', nama: 'Intan Maharani', prodi: 'Sistem Informasi', kelas: 'SI-3A'),
    Mahasiswa(nim: '231010', nama: 'Joko Susilo', prodi: 'Teknik Komputer', kelas: 'TK-3B'),
  ];

  final TextEditingController _cariController = TextEditingController();
  String _kataCari = '';
  String _filterProdi = 'Semua';
  final List<String> _pilihanProdi = [
    'Semua',
    'Informatika',
    'Sistem Informasi',
    'Teknik Komputer',
  ];

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  // Daftar yang tampil = data yang lolos filter prodi DAN pencarian
  List<Mahasiswa> get _hasil {
    return _data.where((m) {
      final cocokProdi = _filterProdi == 'Semua' || m.prodi == _filterProdi;
      final kata = _kataCari.toLowerCase();
      final cocokCari = m.nama.toLowerCase().contains(kata) ||
          m.nim.toLowerCase().contains(kata);
      return cocokProdi && cocokCari;
    }).toList();
  }

  // TAHAP 2: buka form, tunggu hasil, lalu tambahkan ke list
  Future<void> _tambah() async {
    final baru = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(builder: (_) => const FormMahasiswaPage()),
    );
    if (baru != null) {
      setState(() => _data.add(baru));
    }
  }

  // TAHAP 4-5-6: buka detail, lalu proses hasilnya (edit/hapus)
  Future<void> _bukaDetail(Mahasiswa m) async {
    final hasil = await Navigator.push<HasilDetail>(
      context,
      MaterialPageRoute(builder: (_) => DetailMahasiswaPage(mahasiswa: m)),
    );
    if (hasil == null) return;

    setState(() {
      final index = _data.indexOf(m);
      if (hasil.aksi == 'edit' && hasil.data != null) {
        _data[index] = hasil.data!;
      } else if (hasil.aksi == 'hapus') {
        _data.removeAt(index);
      }
    });
  }

  // TAHAP 6: hapus dari daftar (tombol tong sampah)
  Future<void> _hapus(Mahasiswa m) async {
    final yakin = await konfirmasiHapus(context);
    if (yakin) {
      setState(() => _data.remove(m));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _hasil;

    return Scaffold(
      appBar: AppBar(title: const Text('Data Mahasiswa')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mahasiswa'),
      ),
      body: Column(
        children: [
          // TANTANGAN 2: Total mahasiswa (otomatis berubah karena setState)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Mahasiswa: ${_data.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // TAHAP 7: kolom pencarian
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _cariController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari nama atau NIM...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _kataCari = value),
            ),
          ),

          // TANTANGAN 1: filter program studi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Program Studi: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filterProdi,
                  items: _pilihanProdi
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) => setState(() => _filterProdi = value!),
                ),
              ],
            ),
          ),

          // TAHAP 1: ListView.builder + Card
          // TANTANGAN 3: empty state jika tidak ada data
          Expanded(
            child: hasil.isEmpty
                ? Center(
                    child: Text(
                      _data.isEmpty
                          ? 'Belum ada data mahasiswa'
                          : 'Data tidak ditemukan',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: hasil.length,
                    itemBuilder: (context, index) {
                      final m = hasil[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text('${m.nim}  -  ${m.nama}'),
                          subtitle: Text('${m.prodi}\n${m.kelas}'),
                          isThreeLine: true,
                          onTap: () => _bukaDetail(m),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapus(m),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAHAP 2, 3, 5: FORM (dipakai untuk TAMBAH dan EDIT)
// Jika parameter `mahasiswa` diisi -> mode edit (data lama muncul)
// ============================================================
class FormMahasiswaPage extends StatefulWidget {
  final Mahasiswa? mahasiswa;
  const FormMahasiswaPage({super.key, this.mahasiswa});

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nimC;
  late final TextEditingController _namaC;
  late final TextEditingController _prodiC;
  late final TextEditingController _kelasC;

  bool get _modeEdit => widget.mahasiswa != null;

  @override
  void initState() {
    super.initState();
    // Jika edit, controller langsung diisi data lama
    _nimC = TextEditingController(text: widget.mahasiswa?.nim ?? '');
    _namaC = TextEditingController(text: widget.mahasiswa?.nama ?? '');
    _prodiC = TextEditingController(text: widget.mahasiswa?.prodi ?? '');
    _kelasC = TextEditingController(text: widget.mahasiswa?.kelas ?? '');
  }

  @override
  void dispose() {
    _nimC.dispose();
    _namaC.dispose();
    _prodiC.dispose();
    _kelasC.dispose();
    super.dispose();
  }

  void _simpan() {
    // validate() menjalankan semua validator; false jika ada yang gagal
    if (_formKey.currentState!.validate()) {
      final data = Mahasiswa(
        nim: _nimC.text.trim(),
        nama: _namaC.text.trim(),
        prodi: _prodiC.text.trim(),
        kelas: _kelasC.text.trim(),
      );
      Navigator.pop(context, data); // kirim data balik ke halaman sebelumnya
    }
  }

  // Validator: return null = valid, return String = pesan error
  String? _wajibIsi(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Mahasiswa' : 'Form Tambah Mahasiswa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nimC,
                decoration: const InputDecoration(
                    labelText: 'NIM', border: OutlineInputBorder()),
                validator: (v) => _wajibIsi(v, 'NIM'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaC,
                decoration: const InputDecoration(
                    labelText: 'Nama', border: OutlineInputBorder()),
                validator: (v) => _wajibIsi(v, 'Nama'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prodiC,
                decoration: const InputDecoration(
                    labelText: 'Program Studi', border: OutlineInputBorder()),
                validator: (v) => _wajibIsi(v, 'Program Studi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kelasC,
                decoration: const InputDecoration(
                    labelText: 'Kelas', border: OutlineInputBorder()),
                validator: (v) => _wajibIsi(v, 'Kelas'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TAHAP 4, 5, 6: HALAMAN DETAIL (ada tombol Edit & Hapus)
// ============================================================
class DetailMahasiswaPage extends StatelessWidget {
  final Mahasiswa mahasiswa;
  const DetailMahasiswaPage({super.key, required this.mahasiswa});

  Widget _baris(String label, String isi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(isi, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _baris('NIM', mahasiswa.nim),
            _baris('Nama', mahasiswa.nama),
            _baris('Program Studi', mahasiswa.prodi),
            _baris('Kelas', mahasiswa.kelas),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () async {
                    // Buka form dalam mode edit
                    final hasilEdit = await Navigator.push<Mahasiswa>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FormMahasiswaPage(mahasiswa: mahasiswa),
                      ),
                    );
                    if (hasilEdit != null && context.mounted) {
                      // Tutup detail, kirim data baru ke daftar
                      Navigator.pop(context, HasilDetail('edit', hasilEdit));
                    }
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Hapus'),
                  onPressed: () async {
                    final yakin = await konfirmasiHapus(context);
                    if (yakin && context.mounted) {
                      Navigator.pop(context, HasilDetail('hapus'));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}