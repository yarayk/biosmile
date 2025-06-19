import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile_service.dart';

final _profileService = ProfileService();

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _emailController = TextEditingController();

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
    final profile = await _profileService.loadProfileWithAvatar();
    if (profile != null) {
      _lastNameController.text = profile.lastName;
      _firstNameController.text = profile.firstName;
      _middleNameController.text = profile.middleName;
      _emailController.text = profile.email;
      _userId = profile.id;
      _selectedAvatar = profile.avatarUrl;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final data = UserProfileData(
      lastName: _lastNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      email: _emailController.text.trim(),
      id: _userId,
      avatarUrl: _selectedAvatar!, coins: 0, xp: 0, level: 0,
    );

    await _profileService.saveProfileData(data);
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/fon9.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Прозрачный Scaffold
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.8),
          leading: IconButton(
            icon: Icon(Icons.subdirectory_arrow_left_rounded, color: Colors.orange),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Настройки', style: TextStyle(color: Colors.black)),
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
                      ? CircularProgressIndicator()
                      : CircleAvatar(
                    backgroundColor: Colors.yellow,
                    radius: 40,
                    backgroundImage: AssetImage(_selectedAvatar!),
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
      ),
    );
  }

}
