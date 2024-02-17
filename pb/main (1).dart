import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UAS PB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _namaController = TextEditingController();
  TextEditingController _nimController = TextEditingController();
  TextEditingController _nilaiTugasController = TextEditingController();
  TextEditingController _nilaiUTSController = TextEditingController();
  TextEditingController _nilaiUASController = TextEditingController();
  String? _selectedProdi = "Teknik Informatika";

  Future<List<Map<String, dynamic>>>? _dataList;
  Map<String, dynamic>? _dataEdit;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _dataList = _getData();
    });
  }

  Future<List<Map<String, dynamic>>> _getData() async {
    return await _databaseHelper.getMahasiswaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tugas 2 Naufal'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama:'),
              TextField(
                controller: _namaController,
              ),
              SizedBox(height: 10),
              Text('NIM:'),
              TextField(
                controller: _nimController,
              ),
              SizedBox(height: 10),
              Text('Prodi:'),
              Row(
                children: [
                  Radio(
                    value: "Teknik Informatika",
                    groupValue: _selectedProdi,
                    onChanged: (value) {
                      setState(() {
                        _selectedProdi = value as String?;
                      });
                    },
                  ),
                  Text('Ekonomi'),
                  Radio(
                    value: "Sistem Informasi",
                    groupValue: _selectedProdi,
                    onChanged: (value) {
                      setState(() {
                        _selectedProdi = value as String?;
                      });
                    },
                  ),
                  Text('Sistem Informasi'),
                ],
              ),
              SizedBox(height: 10),
              Text('Nilai Tugas/Praktikum:'),
              TextField(
                controller: _nilaiTugasController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Text('Nilai UTS:'),
              TextField(
                controller: _nilaiUTSController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Text('Nilai UAS:'),
              TextField(
                controller: _nilaiUASController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _dataEdit != null ? _simpanEdit : _hitungNilai,
                    child: Text(_dataEdit != null ? 'Simpan Edit' : 'Hitung'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _dataEdit != null ? _batalEdit : _bersihkanForm,
                    child: Text(_dataEdit != null ? 'Batal Edit' : 'Bersihkan'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _dataList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Container(
                      height: 300,
                      child: ListView.builder(
                        itemCount:
                            (snapshot.data as List<Map<String, dynamic>>?)
                                    ?.length ??
                                0,
                        itemBuilder: (context, index) {
                          var data = (snapshot.data
                              as List<Map<String, dynamic>>)[index];
                          return Card(
                            child: ListTile(
                              title: Text('Nama: ${data['nama']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('NIM: ${data['nim']}'),
                                  Text('Prodi: ${data['prodi']}'),
                                  Text('Nilai Tugas: ${data['nilaiTugas']}'),
                                  Text('Nilai UTS: ${data['nilaiUTS']}'),
                                  Text('Nilai UAS: ${data['nilaiUAS']}'),
                                  Text('Nilai Akhir: ${data['nilaiAkhir']}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _editData(index),
                                    child: Text('Edit'),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _hapusData(data['id']),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.red),
                                    child: Text('Hapus'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _hitungNilai() async {
    String nama = _namaController.text;
    String nim = _nimController.text;
    double nilaiTugas = double.parse(_nilaiTugasController.text);
    double nilaiUTS = double.parse(_nilaiUTSController.text);
    double nilaiUAS = double.parse(_nilaiUASController.text);

    double nilaiAkhir = (nilaiTugas + nilaiUTS + nilaiUAS) / 3;

    await _databaseHelper.insertMahasiswa({
      'nama': nama,
      'nim': nim,
      'prodi': _selectedProdi,
      'nilaiTugas': nilaiTugas,
      'nilaiUTS': nilaiUTS,
      'nilaiUAS': nilaiUAS,
      'nilaiAkhir': nilaiAkhir,
    });

    _bersihkanForm();
    _loadData();
  }

  void _simpanEdit() async {
    if (_dataEdit != null) {
      String nama = _namaController.text;
      String nim = _nimController.text;
      double nilaiTugas = double.parse(_nilaiTugasController.text);
      double nilaiUTS = double.parse(_nilaiUTSController.text);
      double nilaiUAS = double.parse(_nilaiUASController.text);

      double nilaiAkhir = (nilaiTugas + nilaiUTS + nilaiUAS) / 3;

      await _databaseHelper.updateMahasiswa({
        'nama': nama,
        'nim': nim,
        'prodi': _selectedProdi,
        'nilaiTugas': nilaiTugas,
        'nilaiUTS': nilaiUTS,
        'nilaiUAS': nilaiUAS,
        'nilaiAkhir': nilaiAkhir,
      }, _dataEdit!['id']);

      _batalEdit();
      _loadData();
    }
  }

  void _hapusData(int id) async {
    await _databaseHelper.deleteMahasiswa(id);
    _loadData();
  }

  void _batalEdit() {
    setState(() {
      _dataEdit = null;
      _bersihkanForm();
    });
  }

  void _editData(int index) {
    var data = (_dataList as List<Map<String, dynamic>>)[index];
    setState(() {
      _dataEdit = data;
      _namaController.text = data['nama'];
      _nimController.text = data['nim'];
      _selectedProdi = data['prodi'];
      _nilaiTugasController.text = data['nilaiTugas'].toString();
      _nilaiUTSController.text = data['nilaiUTS'].toString();
      _nilaiUASController.text = data['nilaiUAS'].toString();
    });
  }

  void _bersihkanForm() {
    _namaController.clear();
    _nimController.clear();
    _nilaiTugasController.clear();
    _nilaiUTSController.clear();
    _nilaiUASController.clear();
    _selectedProdi = "Teknik Informatika";
  }
}
