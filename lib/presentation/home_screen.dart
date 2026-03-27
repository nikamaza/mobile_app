import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import 'add_sample_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _samples = [];

  @override
  void initState() {
    super.initState();
    _refreshSamples();
  }

  // Загрузка данных из БД
  void _refreshSamples() async {
    final data = await DatabaseHelper.instance.getAllSamples();
    setState(() {
      _samples = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои поля и пробы')),
      body: _samples.isEmpty 
        ? const Center(child: Text('Нет данных. Добавьте пробу.'))
        : ListView.builder(
            itemCount: _samples.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Культура: ${_samples[index]['crop_name']}"),
                  subtitle: Text("P: ${_samples[index]['phosphorus']} мг/кг | pH: ${_samples[index]['ph_value']}"),
                  trailing: const Icon(Icons.science),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Переход на экран добавления
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSampleScreen()));
          _refreshSamples(); // Обновить список после возврата
        },
      ),
    );
  }
}