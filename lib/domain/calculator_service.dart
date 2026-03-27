class CalculatorService {
  
  // Данные для справочника культур (можно вынести в БД, но для конкурса хардкод ок)
  // [Вынос N, Вынос P, Вынос K] на 1 тонну урожая
  final Map<String, List<double>> cropsData = {
    'Пшеница озимая': [30.0, 12.0, 25.0],
    'Кукуруза': [25.0, 10.0, 30.0],
    'Подсолнечник': [40.0, 15.0, 100.0],
  };

  // Метод расчета
  // Возвращает текст рекомендации
  String calculateFertilizer(
      String cropName, 
      double targetYield, // Урожайность (т/га)
      double soilP,       // Фосфор в почве (мг/кг)
      ) {
    
    // 1. Получаем норматив выноса для культуры
    final cropStats = cropsData[cropName];
    if (cropStats == null) return "Культура не найдена";
    
    double removalP = cropStats[1]; // Вынос фосфора (кг/т)

    // 2. Коэффициенты (как в Главе 4)
    double Kp = 0.5; // Коэффициент использования из почвы (средний для суглинка)
    double Ku = 0.52; // Коэффициент усвоения из удобрения (для Аммофоса 52%)
    double conversion = 10.0; // Пересчет мг/кг в кг/га

    // 3. Формула: D = (B * Y - H * Kp) / (Ku * 10)
    // D - доза, B - removalP, Y - targetYield, H - soilP
    
    double nutrientNeed = (removalP * targetYield) - (soilP * Kp * conversion);
    
    if (nutrientNeed <= 0) {
      return "Почва обеспечена фосфором. Внесение не требуется.";
    }

    // Рассчитываем физический вес удобрения (Аммофос)
    // В Аммофосе 52% P2O5, значит делим потребность на 0.52
    double fertilizerDose = nutrientNeed / Ku; 

    return "Рекомендуется внести Аммофос: ${fertilizerDose.toStringAsFixed(1)} кг/га";
  }
}