import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AmmaParaApp());
}

const Color forestGreen = Color(0xFF123D2B);
const Color cream = Color(0xFFF7F3E8);
const Color gold = Color(0xFFD4AF65);

class AmmaParaApp extends StatelessWidget {
  const AmmaParaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amma Para Quran',
      debugShowCheckedModeBanner: false,
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
      ),
      home: const HomeScreen(),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.menu_book_rounded, color: gold, size: 42),
                SizedBox(height: 16),
                Text(
                  'Welcome to Amma Para',
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
          const Text(
            'Your Learning',
            style: TextStyle(
              color: forestGreen,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _FeatureCard(
            icon: Icons.menu_book_rounded,
            title: 'Read Quran',
            subtitle: 'Read Arabic ayat with Urdu translation',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SurahListScreen()),
            ),
          ),
          _FeatureCard(
            icon: Icons.headphones_rounded,
            title: 'Listen to Tilawat',
            subtitle: 'Listen to Quran recitation',
            onTap: () => _message(context, 'Tilawat audio is coming next.'),
          ),
          _FeatureCard(
            icon: Icons.school_rounded,
            title: 'Learn Arabic Grammar',
            subtitle: 'Study Ism, Fi‘l, Harf, Nahw and Sarf',
            onTap: () => _message(context, 'Arabic grammar is coming next.'),
          ),
          _FeatureCard(
            icon: Icons.quiz_rounded,
            title: 'Practice Quiz',
            subtitle: 'Test your Quran and grammar knowledge',
            onTap: () => _message(context, 'Practice quiz is coming next.'),
          ),
        ],
      ),
    );
  }

  static void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
    final response = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/juz/30/quran-uthmani'),
    ).timeout(const Duration(seconds: 30));

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
                    const Text('Quran data could not load. Check your internet.'),
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
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
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

  @override
  void initState() {
    super.initState();
    ayahsFuture = loadAyahs();
  }

  Future<List<Map<String, dynamic>>> loadAyahs() async {
    final arabicResponse = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surahNumber}/quran-uthmani'),
    ).timeout(const Duration(seconds: 30));

    final urduResponse = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surahNumber}/ur.jalandhry'),
    ).timeout(const Duration(seconds: 30));

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
        'arabic': arabicData[i]['text'],
        'urdu': urduData[i]['text'],
      });
    }

    return result;
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
                      const SizedBox(height: 16),
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