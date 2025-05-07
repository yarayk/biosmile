import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> insertUser(String name, String email) async {
  final response = await supabase
      .from('test_table') // Название таблицы в Supabase
      .insert({
    'name': name,
    'email': email,
  });

  if (response.error == null) {
    print("Данные успешно добавлены!");
  } else {
    print("Ошибка: ${response.error!.message}");
  }
}