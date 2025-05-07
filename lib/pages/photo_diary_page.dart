import 'package:flutter/material.dart';

class PhotoDiaryPage extends StatefulWidget {
  @override
  _PhotoDiaryPageState createState() => _PhotoDiaryPageState();
}

class _PhotoDiaryPageState extends State<PhotoDiaryPage> {
  String selectedFilter = 'Все фото';
  String? selectedSection;
  final List<String> filters = ['Годы', 'Месяцы', 'Дни', 'Все фото'];
  final List<String> sections = [
    'Упражнения для мимических мышц',
    'Упражнения для щек',
    'Упражнения для нижней челюсти',
    'Упражнения для губ',
    'Упражнения для языка',
  ];

  Widget buildFilterTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber, width: 2),
        borderRadius: BorderRadius.circular(40),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
                selectedSection = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.lightGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
        ),
        Text('Фото-дневник', style: TextStyle(fontSize: 20)),
        SizedBox(width: 24),
      ],
    );
  }

  Widget buildSectionFilter() {
    return GestureDetector(
      onTap: showBottomSheetFilter,
      child: Row(
        children: [
          Text(
            selectedSection ?? 'Фильтрация по разделам',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.filter_alt, color: Colors.orange),
        ],
      ),
    );
  }

  void showBottomSheetFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (selectedSection != null)
                      TextButton(
                        onPressed: () => setState(() {
                          selectedSection = null;
                          Navigator.pop(context);
                        }),
                        child: Text('Сбросить', style: TextStyle(color: Colors.orange)),
                      ),
                    Text('Раздел', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Закрыть', style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
                ...sections.map((section) => ListTile(
                  title: Text(
                    section,
                    style: TextStyle(
                      color: selectedSection == section ? Colors.purple : Colors.black,
                      fontWeight: selectedSection == section ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () => setState(() {
                    selectedSection = section;
                    Navigator.pop(context);
                  }),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/work.png', width: 30, height: 30),
            label: 'Упражнения',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/home.png', width: 40, height: 40),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/prof.png', width: 30, height: 30),
            label: 'Профиль',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/exercise_sections');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(),
                SizedBox(height: 16),
                buildFilterTabs(),
                SizedBox(height: 12),
                buildSectionFilter(),
                // Сетка изображений удалена
              ],
            ),
          ),
        ),
      ),
    );
  }
}
