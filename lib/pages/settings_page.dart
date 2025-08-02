import 'package:flutter/material.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final profile = await _profileService.loadProfileWithAvatar();
    if (profile != null && profile.avatarUrl != null) {
      _lastNameController.text = profile.lastName;
      _firstNameController.text = profile.firstName;
      _middleNameController.text = profile.middleName;
      _emailController.text = profile.email;
      _userId = profile.id;
      _selectedAvatar = profile.avatarUrl;
    }
    // Если profile.avatarUrl == null, не устанавливаем старый аватар
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final data = UserProfileData(
      lastName: _lastNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      email: _emailController.text.trim(),
      id: _userId,
      avatarUrl: _selectedAvatar ?? '',
      coins: 0,
      xp: 0,
      level: 0,
    );

    await _profileService.saveProfileData(data);
  }

  Future<void> _navigateToAvatarSelection() async {
    final selected = await Navigator.pushNamed(context, '/avatar');
    if (selected != null && selected is String) {
      setState(() {
        _selectedAvatar = selected;
        _hasChanged = true;
      });
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Нет')),
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.8),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.orange),
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
                    onPressed: _navigateToAvatarSelection,
                    child: Text('Изменить аватар', style: TextStyle(color: Colors.green)),
                  ),
                ),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : CircleAvatar(
                    backgroundColor: Colors.yellow,
                    radius: 40,
                    backgroundImage: _selectedAvatar != null
                        ? AssetImage(_selectedAvatar!)
                        : null,
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

