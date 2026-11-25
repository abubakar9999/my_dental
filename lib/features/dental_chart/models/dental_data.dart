class DentalData {
  // Adult FDI Teeth
  static const List<String> upperRightAdult = [
    '18', '17', '16', '15', '14', '13', '12', '11'
  ];
  static const List<String> upperLeftAdult = [
    '21', '22', '23', '24', '25', '26', '27', '28'
  ];
  static const List<String> lowerRightAdult = [
    '48', '47', '46', '45', '44', '43', '42', '41'
  ];
  static const List<String> lowerLeftAdult = [
    '31', '32', '33', '34', '35', '36', '37', '38'
  ];

  // Pediatric (Deciduous) FDI Teeth
  static const List<String> upperRightChild = [
    '55', '54', '53', '52', '51'
  ];
  static const List<String> upperLeftChild = [
    '61', '62', '63', '64', '65'
  ];
  static const List<String> lowerRightChild = [
    '85', '84', '83', '82', '81'
  ];
  static const List<String> lowerLeftChild = [
    '71', '72', '73', '74', '75'
  ];

  // Map FDI to Universal
  static const Map<String, String> fdiToUniversal = {
    // Upper Right Adult
    '18': '1', '17': '2', '16': '3', '15': '4',
    '14': '5', '13': '6', '12': '7', '11': '8',
    // Upper Left Adult
    '21': '9', '22': '10', '23': '11', '24': '12',
    '25': '13', '26': '14', '27': '15', '28': '16',
    // Lower Left Adult
    '38': '17', '37': '18', '36': '19', '35': '20',
    '34': '21', '33': '22', '32': '23', '31': '24',
    // Lower Right Adult
    '41': '25', '42': '26', '43': '27', '44': '28',
    '45': '29', '46': '30', '47': '31', '48': '32',

    // Pediatric
    '55': 'A', '54': 'B', '53': 'C', '52': 'D', '51': 'E',
    '61': 'F', '62': 'G', '63': 'H', '64': 'I', '65': 'J',
    '75': 'K', '74': 'L', '73': 'M', '72': 'N', '71': 'O',
    '81': 'P', '82': 'Q', '83': 'R', '84': 'S', '85': 'T',
  };

  static String getToothName(String fdiNumber) {
    final names = {
      '11': 'Upper Right Central Incisor (উপরের ডান সেন্ট্রাল ইনসাইজার)',
      '12': 'Upper Right Lateral Incisor (উপরের ডান ল্যাটারাল ইনসাইজার)',
      '13': 'Upper Right Canine (উপরের ডান ক্যানাইন)',
      '14': 'Upper Right 1st Premolar (উপরের ডান ১ম প্রিমোলার)',
      '15': 'Upper Right 2nd Premolar (উপরের ডান ২য় প্রিমোলার)',
      '16': 'Upper Right 1st Molar (উপরের ডান ১ম মোলার)',
      '17': 'Upper Right 2nd Molar (উপরের ডান ২য় মোলার)',
      '18': 'Upper Right 3rd Molar / Wisdom (উপরের ডান আক্কেল দাঁত)',

      '21': 'Upper Left Central Incisor (উপরের বাম সেন্ট্রাল ইনসাইজার)',
      '22': 'Upper Left Lateral Incisor (উপরের বাম ল্যাটারাল ইনসাইজার)',
      '23': 'Upper Left Canine (উপরের বাম ক্যানাইন)',
      '24': 'Upper Left 1st Premolar (উপরের বাম ১ম প্রিমোলার)',
      '25': 'Upper Left 2nd Premolar (উপরের বাম ২য় প্রিমোলার)',
      '26': 'Upper Left 1st Molar (উপরের বাম ১ম মোলার)',
      '27': 'Upper Left 2nd Molar (উপরের বাম ২য় মোলার)',
      '28': 'Upper Left 3rd Molar / Wisdom (উপরের বাম আক্কেল দাঁত)',

      '31': 'Lower Left Central Incisor (নিচের বাম সেন্ট্রাল ইনসাইজার)',
      '32': 'Lower Left Lateral Incisor (নিচের বাম ল্যাটারাল ইনসাইজার)',
      '33': 'Lower Left Canine (নিচের বাম ক্যানাইন)',
      '34': 'Lower Left 1st Premolar (নিচের বাম ১ম প্রিমোলার)',
      '35': 'Lower Left 2nd Premolar (নিচের বাম ২য় প্রিমোলার)',
      '36': 'Lower Left 1st Molar (নিচের বাম ১ম মোলার)',
      '37': 'Lower Left 2nd Molar (নিচের বাম ২য় মোলার)',
      '38': 'Lower Left 3rd Molar / Wisdom (নিচের বাম আক্কেল দাঁত)',

      '41': 'Lower Right Central Incisor (নিচের ডান সেন্ট্রাল ইনসাইজার)',
      '42': 'Lower Right Lateral Incisor (নিচের ডান ল্যাটারাল ইনসাইজার)',
      '43': 'Lower Right Canine (নিচের ডান ক্যানাইন)',
      '44': 'Lower Right 1st Premolar (নিচের ডান ১ম প্রিমোলার)',
      '45': 'Lower Right 2nd Premolar (নিচের ডান ২য় প্রিমোলার)',
      '46': 'Lower Right 1st Molar (নিচের ডান ১ম মোলার)',
      '47': 'Lower Right 2nd Molar (নিচের ডান ২য় মোলার)',
      '48': 'Lower Right 3rd Molar / Wisdom (নিচের ডান আক্কেল দাঁত)',
    };

    return names[fdiNumber] ?? 'দাঁত #$fdiNumber';
  }
}
