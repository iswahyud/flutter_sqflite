import 'package:flutter/material.dart';
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter SQFLite',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _artikel = [];

  bool _isLoading = true;
  void _refreshArtikel() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _artikel = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshArtikel(); 
  }

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingData =
          _artikel.firstWhere((element) => element['id'] == id);
      _judulController.text = existingData['judul'];
      _deskripsiController.text = existingData['deskripsi'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _judulController,
                    decoration: const InputDecoration(hintText: 'Judul'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _deskripsiController,
                    decoration: const InputDecoration(hintText: 'Deskripsi'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Simpan Data
                      if (id == null) {
                        await _addData();
                      }

                      if (id != null) {
                        await _updateData(id);
                      }

                      // clear text
                      _judulController.text = '';
                      _deskripsiController.text = '';

                      // tutup pop up
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  Future<void> _addData() async {
    await SQLHelper.simpanData(
        _judulController.text, _deskripsiController.text);
    _refreshArtikel();
  }

  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(
        id, _judulController.text, _deskripsiController.text);
    _refreshArtikel();
  }

  void _hapusData(int id) async {
    await SQLHelper.hapusData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Berhasil hapus artikel!'),
    ));
    _refreshArtikel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter SQFLite'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _artikel.length,
              itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_artikel[index]['judul']),
                    subtitle: Text(_artikel[index]['deskripsi']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_artikel[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _hapusData(_artikel[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}