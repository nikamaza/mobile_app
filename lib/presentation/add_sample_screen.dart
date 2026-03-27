import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../domain/calculator_service.dart';

class AddSampleScreen extends StatefulWidget {
  const AddSampleScreen({super.key});
  @override
  State<AddSampleScreen> createState() => _AddSampleScreenState();
}

class _AddSampleScreenState extends State<AddSampleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Контроллеры (сюда пользователь вводит текст)
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _pController = TextEditingController(); // Фосфор
  final TextEditingController _yieldController = TextEditingController(); // Урожайность

  String _selectedCrop = 'Пшеница озимая'; // Значение по умолчанию

  void _calculateAndSave() async {
    if (_formKey.currentState!.validate()) {
      
      // 1. Берем данные из полей ввода
      double pValue = double.parse(_pController.text);
      double yieldValue = double.parse(_yieldController.text);
      double phValue = double.parse(_phController.text);

      // 2. Считаем (Логика из Главы 4)
      final calcService = CalculatorService();
      String recommendation = calcService.calculateFertilizer(_selectedCrop, yieldValue, pValue);

      // 3. Сохраняем в БД (Логика из Главы 2-3)
      await DatabaseHelper.instance.createSample({
        'field_id': 1, // Пока заглушка (ID поля = 1)
        'date': DateTime.now().toString(),
        'ph_value': phValue,
        'nitrogen': 0.0, 
        'phosphorus': pValue,
        'potassium': 0.0,
        'crop_name': _selectedCrop,
      });

      // 4. Показываем результат во всплывающем окне
      if (!mounted) return;
      showDialog(
        context: context, 
        builder: (ctx) => AlertDialog(
          title: const Text("Рекомендация готова"),
          content: Text(recommendation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Закрыть диалог
                Navigator.pop(context); // Вернуться на главный экран
              },
              child: const Text("ОК, Спасибо"),
            )
          ],
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая проба')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Выбор культуры
              DropdownButtonFormField(
                value: _selectedCrop,
                items: ['Пшеница озимая', 'Кукуруза', 'Подсолнечник']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCrop = val as String),
                decoration: const InputDecoration(labelText: 'Выберите культуру'),
              ),
              const SizedBox(height: 10),
              
              // Ввод урожайности
              TextFormField(
                controller: _yieldController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'План урожайности (т/га)', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Введите число' : null,
              ),
              const SizedBox(height: 10),
              
              // Ввод Фосфора
              TextFormField(
                controller: _pController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Содержание Фосфора (мг/кг)', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Введите число' : null,
              ),
              const SizedBox(height: 10),
              
              // Ввод pH
              TextFormField(
                controller: _phController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Уровень pH', border: OutlineInputBorder()),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Введите pH';
                  double? v = double.tryParse(val);
                  if (v == null || v < 1 || v > 14) return 'pH должен быть от 1 до 14';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Кнопка расчета
              ElevatedButton(
                onPressed: _calculateAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15)
                ),
                child: const Text('РАССЧИТАТЬ И СОХРАНИТЬ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}