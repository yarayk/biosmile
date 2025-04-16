import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController(text: 'Калинина');
  final _firstNameController = TextEditingController(text: 'Аня');
  final _middleNameController = TextEditingController(text: 'Отчество');
  final _emailController = TextEditingController(text: 'kalinina.anya@jimin.bts');
  final _passwordController = TextEditingController(text: 'кулибяка007');

  bool _obscurePassword = true;
  bool _hasChanged = false;
  String? _selectedAvatar;
  String _userId = '123456789';

  // Явное прописывание путей к каждому аватару
  final List<String> _avatarPaths = [
    'assets/avatars/avatar_1.png',
    'assets/avatars/avatar_2.png',
    'assets/avatars/avatar_3.png',
    'assets/avatars/avatar_4.png',
    'assets/avatars/avatar_5.png',
    'assets/avatars/avatar_6.png',
    'assets/avatars/avatar_7.png',
    'assets/avatars/avatar_8.png',
    'assets/avatars/avatar_9.png',
    'assets/avatars/avatar_10.png',
  ];

  bool _isLoading = true; // Флаг для контроля загрузки настроек

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString('selectedAvatar');
    setState(() {
      _selectedAvatar = savedAvatar ?? _avatarPaths[0]; // Если не сохранено, устанавливаем аватар по умолчанию
      _isLoading = false; // Завершаем загрузку
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedAvatar != null) {
      await prefs.setString('selectedAvatar', _selectedAvatar!);
    }
  }

  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Выберите аватар'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _avatarPaths.map((avatar) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatar = avatar;
                  _hasChanged = true;
                });
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundImage: AssetImage(avatar),
                radius: 30,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Нет'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: Text('Да'),
          ),
        ],
      ),
    );
  }

  Widget _styledTextField(String label, TextEditingController controller,
      {bool obscure = false, Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.subdirectory_arrow_left_rounded, color: Colors.orange),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Настройки', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasChanged)
            TextButton(
              onPressed: () async {
                await _saveSettings();
                setState(() => _hasChanged = false);
              },
              child: Text('Сохранить', style: TextStyle(color: Colors.orange)),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() => _hasChanged = true),
          child: ListView(
            children: [
              Text('Аккаунт', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _showAvatarSelectionDialog,
                  child: Text('Изменить аватар', style: TextStyle(color: Colors.green)),
                ),
              ),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator() // Пока идет загрузка, показываем индикатор
                    : CircleAvatar(
                  backgroundColor: Colors.yellow,
                  radius: 40,
                  backgroundImage: AssetImage(_selectedAvatar!),  // Показываем выбранный аватар
                ),
              ),
              SizedBox(height: 16),
              _styledTextField('Фамилия *', _lastNameController),
              SizedBox(height: 12),
              _styledTextField('Имя *', _firstNameController),
              SizedBox(height: 12),
              _styledTextField('Отчество', _middleNameController),
              SizedBox(height: 12),
              _styledTextField('Электронная почта', _emailController),
              SizedBox(height: 12),
              _styledTextField(
                'Пароль',
                _passwordController,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(Icons.remove_red_eye_outlined, color: Colors.orange),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              SizedBox(height: 16),
              Text('ID Пользователя: $_userId', style: TextStyle(color: Colors.grey)),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/privacy'),
                  child: Text('Политика конфиденциальности', style: TextStyle(color: Colors.green)),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/terms'),
                  child: Text('Условия использования', style: TextStyle(color: Colors.green)),
                ),
              ),
              SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _confirmLogout,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: Text('выйти', style: TextStyle(color: Colors.orange)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
