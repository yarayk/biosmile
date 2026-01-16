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
  final _petAgeController = TextEditingController();
  final _petNameController = TextEditingController();

  bool _hasChanged = false;
  String _userId = '123456789';
  bool _isLoading = true;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final profile = await _profileService.loadProfileWithAvatar();

    final petName = _prefs.getString('petName') ?? '';
    final petAge = _prefs.getString('petAge') ?? '';

    if (profile != null) {
      _lastNameController.text = profile.lastName;
      _firstNameController.text = profile.firstName;
      _middleNameController.text = profile.middleName;
      _userId = profile.id;
    }

    _petNameController.text = petName;
    _petAgeController.text = petAge;

    setState(() => _isLoading = false);
  }

  Future<void> _savePetData() async {
    await _prefs.setString('petName', _petNameController.text.trim());
    await _prefs.setString('petAge', _petAgeController.text.trim());
  }

  Future<void> _saveSettings() async {
    final data = UserProfileData(
      lastName: _lastNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      email: '',
      id: _userId,
      avatarUrl: '',
      coins: 0,
      xp: 0,
      level: 0,
    );

    await _profileService.saveProfileData(data);
    await _savePetData();
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0 * _getScaleFactor()),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 14 * _getScaleFactor(),
              fontWeight: FontWeight.w400,
              color: Color(0xFF777777),
              height: 1.0,
            ),
          ),
        ),
        SizedBox(height: 4 * _getScaleFactor()),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() => _hasChanged = true),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.0 * _getScaleFactor(),
              vertical: 12.0 * _getScaleFactor(),
            ),
            filled: true,
            fillColor: Color(0xFFF2F2F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(101 * _getScaleFactor()),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 14 * _getScaleFactor(),
            fontWeight: FontWeight.w400,
            color: Color(0xFF777777),
          ),
        ),
      ],
    );
  }

  // === МАСШТАБ ОТНОСИТЕЛЬНО ШИРИНЫ ЭКРАНА ===
  double _getScaleFactor() {
    return MediaQuery.of(context).size.width / 375.0;
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = _getScaleFactor();

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: SafeArea(
        child: Stack(
          children: [
            // === РЕДАКТИРОВАТЬ ЗДЕСЬ: top для стрелки назад и заголовка ===
            // Header Back Button
            Positioned(
              left: 16 * scaleFactor,
              top: 40 * scaleFactor, // РЕДАКТИРОВАТЬ: top для стрелки
              width: 34 * scaleFactor,
              height: 34 * scaleFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.36 * scaleFactor),
                ),
                child: Center(
                  child: IconButton(
                    icon: Image.asset(
                      'assets/exercise/arrow_left.png',
                      width: 18 * scaleFactor,
                      height: 18 * scaleFactor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            // Header Title
            Positioned(
              left: 0,
              right: 0,
              top: 47 * scaleFactor, // РЕДАКТИРОВАТЬ: top для "Настройки"
              height: 21 * scaleFactor,
              child: Center(
                child: Text(
                  'Настройки',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 18 * scaleFactor,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191919),
                    height: 1.166,
                  ),
                ),
              ),
            ),
            // Form Container
            Positioned(
              left: 17 * scaleFactor,
              top: 135 * scaleFactor,
              width: 343 * scaleFactor,
              height: 460 * scaleFactor,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Fields (gap: 16px between sections, 12px between inputs)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Фамилия
                      _buildInputField('Фамилия', _lastNameController),
                      SizedBox(height: 12 * scaleFactor),
                      // Имя
                      _buildInputField('Имя', _firstNameController),
                      SizedBox(height: 12 * scaleFactor),
                      // Отчество
                      _buildInputField('Отчество', _middleNameController),
                      SizedBox(height: 12 * scaleFactor),
                      // Возраст
                      _buildInputField('Возраст', _petAgeController),
                      SizedBox(height: 12 * scaleFactor),
                      // Имя питомца
                      _buildInputField('Имя питомца', _petNameController),
                    ],
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  // Data Section (gap: 8px)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User ID
                      Row(
                        children: [
                          Text(
                            'ID пользователя: ',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 12 * scaleFactor,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF777777),
                              height: 1.166,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _userId,
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 12 * scaleFactor,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF777777),
                                height: 1.166,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * scaleFactor),
                      // Политика конфиденциальности
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/privacy'),
                        child: SizedBox(
                          width: 343 * scaleFactor,
                          height: 14 * scaleFactor,
                          child: Text(
                            'Политика конфиденциальности',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 12 * scaleFactor,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF777777),
                              height: 1.166,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8 * scaleFactor),
                      // Условия использования
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/terms'),
                        child: SizedBox(
                          width: 343 * scaleFactor,
                          height: 14 * scaleFactor,
                          child: Text(
                            'Условия использования',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 12 * scaleFactor,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF777777),
                              height: 1.166,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // === РЕДАКТИРОВАТЬ ЗДЕСЬ: top для кнопки сохранить ===
            // Save Button
            Positioned(
              left: 17 * scaleFactor,
              top: 650 * scaleFactor, // РЕДАКТИРОВАТЬ: top для кнопки сохранить
              width: 343 * scaleFactor,
              height: 53 * scaleFactor,
              child: ElevatedButton(
                onPressed: _hasChanged
                    ? () async {
                  await _saveSettings();
                  setState(() => _hasChanged = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Настройки сохранены')),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF81C784).withOpacity(_hasChanged ? 1.0 : 0.3),
                  disabledBackgroundColor: Color(0xFF81C784).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(69 * scaleFactor),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 16 * scaleFactor,
                    horizontal: 12 * scaleFactor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Сохранить',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 18 * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.166,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _petAgeController.dispose();
    _petNameController.dispose();
    super.dispose();
  }
}
