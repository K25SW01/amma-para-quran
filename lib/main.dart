import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const AmmaParaApp());
}

const Color forestGreen = Color(0xFF123D2B);
const Color cream = Color(0xFFF7F3E8);
const Color gold = Color(0xFFD4AF65);

final ValueNotifier<String> appLanguage = ValueNotifier<String>('en');
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

String tr(String en, String ur) => appLanguage.value == 'ur' ? ur : en;

class AmmaParaApp extends StatefulWidget {
  const AmmaParaApp({super.key});

  @override
  State<AmmaParaApp> createState() => _AmmaParaAppState();
}

class _AmmaParaAppState extends State<AmmaParaApp> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    appLanguage.value = prefs.getString('app_language') ?? 'en';
    appThemeMode.value = prefs.getBool('dark_mode') == true
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Amma Para Quran',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: cream,
            colorScheme: ColorScheme.fromSeed(
              seedColor: forestGreen,
              primary: forestGreen,
              surface: cream,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: forestGreen,
              foregroundColor: Colors.white,
            ),
            cardTheme: const CardThemeData(color: Colors.white),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: forestGreen,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: forestGreen,
              foregroundColor: Colors.white,
            ),
          ),
          home: ValueListenableBuilder<String>(
            valueListenable: appLanguage,
            builder: (context, language, _) => const HomeScreen(),
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _setLanguage(String language) async {
    appLanguage.value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', language);
    if (mounted) setState(() {});
  }

  Future<void> _setDarkMode(bool enabled) async {
    appThemeMode.value = enabled ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', enabled);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final urdu = appLanguage.value == 'ur';
    return Scaffold(
      appBar: AppBar(title: Text(urdu ? 'ترتیبات' : 'Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            urdu ? 'زبان / Language' : 'Language / زبان',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          RadioGroup<String>(
            groupValue: appLanguage.value,
            onChanged: (value) {
              if (value != null) _setLanguage(value);
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                ),
                RadioListTile<String>(title: const Text('اردو'), value: 'ur'),
              ],
            ),
          ),
          const Divider(height: 32),
          SwitchListTile(
            title: Text(urdu ? 'ڈارک موڈ' : 'Dark mode'),
            subtitle: Text(
              urdu ? 'گہرا تھیم استعمال کریں' : 'Use a dark appearance',
            ),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: appThemeMode.value == ThemeMode.dark,
            onChanged: _setDarkMode,
          ),
          const SizedBox(height: 16),
          Text(
            urdu
                ? 'آپ کی ترتیبات خودکار طور پر محفوظ ہوں گی۔'
                : 'Your settings are saved automatically.',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Amma Para Quran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: tr('Settings', 'ترتیبات'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: forestGreen,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: gold, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.menu_book_rounded, color: gold, size: 42),
                SizedBox(height: 16),
                Text(
                  tr('Welcome to Amma Para', 'عمّ پارہ میں خوش آمدید'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Read, listen, and learn the final Juz of the Holy Quran.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
                SizedBox(height: 18),
                Text(
                  'جزء عمّ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: gold,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            tr('Your Learning', 'آپ کی تعلیم'),
            style: TextStyle(
              color: forestGreen,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _FeatureCard(
            icon: Icons.menu_book_rounded,
            title: tr('Read Quran', 'قرآن پڑھیں'),
            subtitle: tr(
              'Read Arabic ayat with Urdu translation',
              'عربی آیات اردو ترجمے کے ساتھ پڑھیں',
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SurahListScreen()),
            ),
          ),
          _FeatureCard(
            icon: Icons.headphones_rounded,
            title: tr('Listen to Tilawat', 'تلاوت سنیں'),
            subtitle: tr('Listen to Quran recitation', 'قرآن کی تلاوت سنیں'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SurahListScreen()),
            ),
          ),
          _FeatureCard(
            icon: Icons.school_rounded,
            title: tr('Learn Arabic Grammar', 'عربی قواعد سیکھیں'),
            subtitle: tr(
              'Study Ism, Fi‘l, Harf, Nahw and Sarf',
              'اسم، فعل، حرف، نحو اور صرف سیکھیں',
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GrammarScreen()),
            ),
          ),
          _FeatureCard(
            icon: Icons.quiz_rounded,
            title: tr('Practice Quiz', 'مشق کے سوالات'),
            subtitle: tr(
              'Test your Quran and grammar knowledge',
              'قرآن اور قواعد کا علم جانچیں',
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GrammarQuizScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: cream,
          child: Icon(icon, color: forestGreen),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: forestGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  late Future<List<dynamic>> surahsFuture;

  @override
  void initState() {
    super.initState();
    surahsFuture = loadSurahs();
  }

  Future<List<dynamic>> loadSurahs() async {
    final response = await http
        .get(Uri.parse('https://api.alquran.cloud/v1/juz/30/quran-uthmani'))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Could not load Quran data.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final ayahs = json['data']['ayahs'] as List<dynamic>;
    final Map<int, Map<String, dynamic>> unique = {};

    for (final item in ayahs) {
      final surah = item['surah'] as Map<String, dynamic>;
      final number = surah['number'] as int;
      unique[number] = surah;
    }

    return unique.values.toList()
      ..sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Para 30 — Surahs')),
      body: FutureBuilder<List<dynamic>>(
        future: surahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Quran data could not load. Check your internet.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => surahsFuture = loadSurahs());
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final surahs = snapshot.data ?? [];

          return ListView.builder(
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index] as Map<String, dynamic>;
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: forestGreen,
                    child: Text(
                      '${surah['number']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    surah['englishName'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: forestGreen,
                    ),
                  ),
                  subtitle: Text(
                    '${surah['englishNameTranslation']} • ${surah['numberOfAyahs']} ayat',
                  ),
                  trailing: Text(
                    surah['name'] as String,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 20),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahReaderScreen(
                        surahNumber: surah['number'] as int,
                        surahName: surah['englishName'] as String,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SurahReaderScreen extends StatefulWidget {
  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  final int surahNumber;
  final String surahName;

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  late Future<List<Map<String, dynamic>>> ayahsFuture;
  final AudioPlayer audioPlayer = AudioPlayer();
  int? playingAyahNumber;

  @override
  void initState() {
    super.initState();
    ayahsFuture = loadAyahs();
  }

  Future<void> toggleAyah(int ayahNumber) async {
    if (playingAyahNumber == ayahNumber && audioPlayer.playing) {
      await audioPlayer.pause();
      if (mounted) setState(() => playingAyahNumber = null);
      return;
    }
    if (playingAyahNumber == ayahNumber &&
        audioPlayer.processingState != ProcessingState.completed) {
      await audioPlayer.play();
      return;
    }
    await playAyah(ayahNumber);
    if (mounted) setState(() => playingAyahNumber = ayahNumber);
  }

  Future<void> playAyah(int ayahNumber) async {
    try {
      final audioUrl =
          'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$ayahNumber.mp3';
      await audioPlayer.setUrl(audioUrl);
      await audioPlayer.play();
      if (mounted) {
        setState(() => playingAyahNumber = ayahNumber);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio could not be played. Please try again.'),
          ),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> loadAyahs() async {
    final arabicResponse = await http
        .get(
          Uri.parse(
            'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/quran-uthmani',
          ),
        )
        .timeout(const Duration(seconds: 30));

    final urduResponse = await http
        .get(
          Uri.parse(
            'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/ur.jalandhry',
          ),
        )
        .timeout(const Duration(seconds: 30));

    if (arabicResponse.statusCode != 200 || urduResponse.statusCode != 200) {
      throw Exception('Could not load this Surah.');
    }

    final arabicData =
        jsonDecode(arabicResponse.body)['data']['ayahs'] as List<dynamic>;
    final urduData =
        jsonDecode(urduResponse.body)['data']['ayahs'] as List<dynamic>;

    if (arabicData.length != urduData.length) {
      throw Exception('Arabic and Urdu ayah counts do not match.');
    }

    final result = <Map<String, dynamic>>[];

    for (int i = 0; i < arabicData.length; i++) {
      if (arabicData[i]['numberInSurah'] != urduData[i]['numberInSurah']) {
        throw Exception('Ayah numbers do not match.');
      }

      result.add({
        'number': arabicData[i]['numberInSurah'],
        'globalNumber': arabicData[i]['number'],
        'arabic': arabicData[i]['text'],
        'urdu': urduData[i]['text'],
      });
    }

    return result;
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surahName)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ayahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Ayat could not load.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final ayahs = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ayahs.length,
            itemBuilder: (context, index) {
              final ayah = ayahs[index];

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Ayah ${ayah['number']}',
                        style: const TextStyle(
                          color: forestGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip:
                              playingAyahNumber == ayah['globalNumber'] &&
                                  audioPlayer.playing
                              ? 'Pause ayah'
                              : 'Play ayah',
                          icon: Icon(
                            playingAyahNumber == ayah['globalNumber'] &&
                                    audioPlayer.playing
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            color: forestGreen,
                            size: 30,
                          ),
                          onPressed: () =>
                              toggleAyah(ayah['globalNumber'] as int),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ayah['arabic'] as String,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 27,
                          height: 2,
                          color: forestGreen,
                        ),
                      ),
                      const Divider(height: 28),
                      Text(
                        ayah['urdu'] as String,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 19,
                          height: 1.8,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  static const lessons = [
    {
      'title': '1. Ism (اسم)',
      'meaning': 'A name, person, place, or thing.',
      'example': 'رَبٌّ',
      'urdu': 'ربّ — پالنے والا',
    },
    {
      'title': '2. Fi‘l (فعل)',
      'meaning': 'A word that expresses an action.',
      'example': 'خَلَقَ',
      'urdu': 'خَلَقَ — اس نے پیدا کیا',
    },
    {
      'title': '3. Harf (حرف)',
      'meaning':
          'A particle whose meaning depends on its use with other words.',
      'example': 'مِنْ',
      'urdu': 'مِنْ — سے',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text('Arabic Grammar'),
        backgroundColor: forestGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Learn the Basics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Begin with three basic Arabic word categories.'),
          const SizedBox(height: 16),
          ...lessons.map(
            (lesson) => Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson['title']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: forestGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(lesson['meaning']!),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        lesson['example']!,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(lesson['urdu']!),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GrammarQuizScreen extends StatefulWidget {
  const GrammarQuizScreen({super.key});

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  static const questions = [
    {
      'q': 'Which word is an Ism (noun)?',
      'options': ['خَلَقَ', 'كِتَابٌ', 'مِنْ'],
      'answer': 1,
    },
    {
      'q': 'Which word is a Fi‘l (verb)?',
      'options': ['مِنْ', 'رَبٌّ', 'خَلَقَ'],
      'answer': 2,
    },
    {
      'q': 'Which word is a Harf (particle)?',
      'options': ['مِنْ', 'كِتَابٌ', 'ذَهَبَ'],
      'answer': 0,
    },
    {
      'q': 'An Ism can name a…',
      'options': ['Person or thing', 'Only an action', 'Only a particle'],
      'answer': 0,
    },
    {
      'q': 'A Fi‘l usually expresses…',
      'options': ['A name', 'An action', 'A place only'],
      'answer': 1,
    },
  ];

  int index = 0;
  int score = 0;
  int? selected;
  bool finished = false;

  Future<void> submitAnswer() async {
    if (selected == null) return;

    final newScore = score + (selected == questions[index]['answer'] ? 1 : 0);

    if (index == questions.length - 1) {
      final prefs = await SharedPreferences.getInstance();
      final completed = (prefs.getInt('completedQuizzes') ?? 0) + 1;
      await prefs.setInt('completedQuizzes', completed);
      await prefs.setInt('lastQuizScore', newScore);
      await prefs.setInt(
        'bestQuizScore',
        newScore > (prefs.getInt('bestQuizScore') ?? 0)
            ? newScore
            : (prefs.getInt('bestQuizScore') ?? 0),
      );

      if (!mounted) return;
      setState(() {
        score = newScore;
        finished = true;
      });
    } else {
      setState(() {
        score = newScore;
        index++;
        selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: Text(tr('Practice Quiz', 'مشق کے سوالات')),
        backgroundColor: forestGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: finished
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 72,
                      color: Color(0xFFD4AF65),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Quiz Completed!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your score: $score / ${questions.length}',
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        index = 0;
                        score = 0;
                        selected = null;
                        finished = false;
                      }),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${index + 1} of ${questions.length}',
                    style: const TextStyle(color: forestGreen, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (index + 1) / questions.length,
                    color: forestGreen,
                    backgroundColor: Colors.black12,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    questions[index]['q'] as String,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...(questions[index]['options'] as List<String>)
                      .asMap()
                      .entries
                      .map(
                        (option) => Card(
                          color: selected == option.key
                              ? const Color(0xFFE2EBDD)
                              : Colors.white,
                          child: ListTile(
                            leading: Icon(
                              selected == option.key
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: forestGreen,
                            ),
                            title: Text(option.value),
                            onTap: () => setState(() => selected = option.key),
                          ),
                        ),
                      ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forestGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: selected == null ? null : submitAnswer,
                    child: Text(
                      index == questions.length - 1
                          ? 'Finish Quiz'
                          : 'Next Question',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: forestGreen,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final prefs = snapshot.data!;
          final completed = prefs.getInt('completedQuizzes') ?? 0;
          final lastScore = prefs.getInt('lastQuizScore') ?? 0;
          final bestScore = prefs.getInt('bestQuizScore') ?? 0;

          Widget stat(String title, String value, IconData icon) {
            return Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(icon, color: forestGreen, size: 32),
                title: Text(title),
                trailing: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: forestGreen,
                  ),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Your Learning Journey',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              stat('Quizzes completed', '$completed', Icons.quiz),
              stat(
                'Last quiz score',
                '$lastScore / 5',
                Icons.assignment_turned_in,
              ),
              stat('Best quiz score', '$bestScore / 5', Icons.emoji_events),
              const SizedBox(height: 12),
              Text(
                'Complete a practice quiz to start building your progress.',
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}
