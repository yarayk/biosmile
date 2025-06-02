import 'package:flutter/material.dart';
import '../photo_view.dart';
import '../photo_service.dart';


class PhotoDiaryPage extends StatefulWidget {
  @override
  _PhotoDiaryPageState createState() => _PhotoDiaryPageState();
}

class _PhotoDiaryPageState extends State<PhotoDiaryPage> {
  List<Photo> photos = [];       // список загруженных фото
  bool isLoading = false;        // флаг загрузки
  String? errorMessage;          // сообщение об ошибке
  String selectedFilter = 'Все фото';
  String? selectedSection;
  String? selectedExercise;
  String activeTab = 'Раздел';

  @override
  void initState() {
    super.initState();
    loadPhotos();  // вызываем загрузку фото при инициализации страницы
  }

  Future<void> loadPhotos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedPhotos = await fetchPhotos(
        section: selectedSection,
        exercise: selectedExercise,
        timeFilter: selectedFilter,
      );
      setState(() {
        photos = fetchedPhotos;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  final List<String> filters = ['Годы', 'Месяцы', 'Дни', 'Все фото'];

  final Map<String, List<String>> sectionExercises = {
    'Упражнения для мимических мышц': [
      'Поднять брови вверх, удержать',
      'Нахмурить брови, удержать',
      'Закрыть глаза (крепко-слабо)',
      'Поморгать',
      'Двигать глазным яблоком, закрыв глаза',
      'Прищуриваться, подтягивая нижнее веко',
      'Поочередно закрывать правый и левый глаз',
      'Сморщить нос',
      'Раздувать ноздри, шевелить носом. Втягивать ноздри',
      'Звук “М”',
      'Звук “О”',
      'Плевать',
      'Звуки “У”, “А”',
      'Рот открыт, звуки “О”, “А”',
      'Произносить “Т”, “П”, “Р”, “У”',
    ],
    'Упражнения для щек': [
      'Надуть обе щеки',
      'Втянуть обе щеки',
      'Надуть правую щеку, затем левую',
      'Чередовать 1 и 2 задание',
      'Имитировать полоскание',
    ],
    'Упражнения для нижней челюсти': [
      'Рот приоткрыть, широко открыть, плотно закрыть',
      'Движения нижней челюстью вперед, назад, вправо, влево, круговые движения',
      'Имитация жевания с открытым/ закрытым ртом',
    ],
    'Упражнения для губ': [
      'Вытянуть губы вперед - трубочкой',
      'Движения “трубочкой”',
      'Трубочка-улыбочка поочередно',
      'Улыбка (вправо-влево)',
      'Длинное задание',
      'Захватывать зубами верхние и нижние губы',
      'Оскалиться',
    ],
    'Упражнения для языка': [
      'Открыть рот, язык поднять, опустить',
      'Рот открыт, язык вверх-вниз',
      'Рот открыть, язык к правому уху, к левому',
      'Облизать нижнюю, затем верхнюю губу',
      'Облизать губы по кругу',
      'Языком погладить твердое небо',
      'Длинное задание',
    ],
    'Дополнительные упражнения': [
      'Поцокать, как лошадка',
      'Брать с ладони мелкие куски яблока',
      'Вибрация губ (фыркать)',
      'Длинное задание',
    ],
  };

  void showSectionBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) {
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> itemsToShow = [];
            if (activeTab == 'Раздел') {
              itemsToShow = sectionExercises.keys.toList();
            } else if (selectedSection != null) {
              itemsToShow = sectionExercises[selectedSection] ?? [];
            }

            bool hasSelection = selectedSection != null || selectedExercise != null;

            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasSelection)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedSection = null;
                              selectedExercise = null;
                              activeTab = 'Раздел';
                            });
                            setModalState(() {
                              errorMessage = null;
                            });
                          },
                          child: Text(
                            'Сбросить',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        SizedBox(width: 90),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          hasSelection ? 'Сохранить' : 'Закрыть',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey.shade200,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildTabOption('Раздел', setModalState, () {
                          errorMessage = null;
                        }),
                        buildTabOption('Упражнение', setModalState, () {
                          if (selectedSection == null) {
                            errorMessage = 'Сначала выберите фильтр по разделам';
                          } else {
                            errorMessage = null;
                          }
                        }),
                      ],
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: 16),
                  Container(
                    height: 250,
                    child: ListView(
                      children: itemsToShow.map((item) {
                        final isSelected = (activeTab == 'Раздел' && item == selectedSection) ||
                            (activeTab == 'Упражнение' && item == selectedExercise);
                        return ListTile(
                          title: Text(
                            item,
                            style: TextStyle(
                              color: isSelected ? Colors.purple : Colors.blue,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            if (activeTab == 'Раздел') {
                              setState(() {
                                selectedSection = item;
                                selectedExercise = null;
                              });
                              loadPhotos();
                              setModalState(() {
                                errorMessage = null;
                              });
                            } else if (selectedSection == null) {
                              setModalState(() {
                                errorMessage = 'Сначала выберите фильтр по разделам';
                              });
                            } else {
                              setState(() {
                                selectedExercise = item;
                              });
                              loadPhotos();
                              setModalState(() {
                                errorMessage = null;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildTabOption(
      String title,
      void Function(void Function()) setModalState,
      void Function() updateError,
      ) {
    final isActive = title == activeTab;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          updateError();
          if (title == 'Упражнение' && selectedSection == null) return;
          activeTab = title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildFilterWithIcon() {
    return GestureDetector(
      onTap: showSectionBottomSheet,
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedSection == null
                  ? 'Фильтрация по разделам'
                  : 'Раздел: $selectedSection${selectedExercise != null ? '\nУпражнение: $selectedExercise' : ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.amber),
        ],
      ),
    );
  }

  Widget buildFilterTabs() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.amber, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => selectedFilter = filter);
                loadPhotos();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Фото-дневник',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: 40),
      ],
    );
  }

  Widget buildPhotoRow() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          'Ошибка загрузки фото:\n$errorMessage',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (photos.isEmpty) {
      return Center(
        child: Text(
          'Фото не найдены',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // форматируем дату, например "dd.MM.yyyy"
              '${photo.dateTaken.day.toString().padLeft(2, '0')}.${photo.dateTaken.month.toString().padLeft(2, '0')}.${photo.dateTaken.year}',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                photo.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Ошибка загрузки изображения: $error');
                  return Icon(Icons.broken_image);
                },
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f0f7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            SizedBox(height: 16),
            buildFilterTabs(),
            SizedBox(height: 20),
            buildFilterWithIcon(),
            SizedBox(height: 20),
            Expanded(  // Добавляем Expanded, чтобы GridView занял оставшееся место и не вылезал
              child: buildPhotoRow(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/work.png', width: 30, height: 30),
            label: 'Упражнения',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/home.png', width: 30, height: 30),
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
    );
  }
}
