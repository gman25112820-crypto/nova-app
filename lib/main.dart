import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const NovaApp());
}

// ─── Dark Color Palette ───────────────────────────────────────────────────────

const _bg          = Color(0xFF0F0E1A);
const _bg2         = Color(0xFF16152A);
const _surface     = Color(0xFF1E1D35);
const _surfaceGlow = Color(0xFF252440);
const _purple      = Color(0xFF6C63FF);
const _purpleDark  = Color(0xFF4B44CC);
const _purpleGlow  = Color(0x336C63FF);
const _teal        = Color(0xFF00C9A7);
const _tealGlow    = Color(0x2200C9A7);
const _coral       = Color(0xFFFF6B6B);
const _coralGlow   = Color(0x22FF6B6B);
const _amber       = Color(0xFFFFB830);
const _amberGlow   = Color(0x22FFB830);
const _green       = Color(0xFF4CAF50);
const _text        = Color(0xFFFFFFFF);
const _text2       = Color(0xFF9896B8);
const _text3       = Color(0xFF5A5880);
const _border      = Color(0x1AFFFFFF);
const _borderBright= Color(0x30FFFFFF);

// ─── Responsive ──────────────────────────────────────────────────────────────

class R {
  static bool isMobile(BuildContext c)  => MediaQuery.of(c).size.width < 600;
  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width >= 1024;
  static double pad(BuildContext c)     => isMobile(c) ? 16 : 24;
}

// ─── Theme ───────────────────────────────────────────────────────────────────

ThemeData _theme() {
  final base = GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme);
  return ThemeData.dark().copyWith(
    useMaterial3: true,
    textTheme: base,
    colorScheme: ColorScheme.dark(
      primary: _purple, secondary: _teal,
      surface: _surface, background: _bg,
    ),
    scaffoldBackgroundColor: _bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: _bg, elevation: 0,
      foregroundColor: _text, surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _bg2,
      indicatorColor: _purpleGlow,
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.dmSans(fontSize: 10, color: _text2),
      ),
    ),
    cardTheme: CardThemeData(
      color: _surface, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: _surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _purple, width: 1.5)),
      labelStyle: GoogleFonts.dmSans(color: _text2),
      hintStyle: GoogleFonts.dmSans(color: _text3),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: _purple, inactiveTrackColor: _surfaceGlow,
      thumbColor: _purple, overlayColor: _purpleGlow, trackHeight: 6,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? _purple : _text3),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? _purpleGlow : _surface),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _surfaceGlow,
      contentTextStyle: GoogleFonts.dmSans(color: _text, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerColor: _border,
  );
}

// ─── Models ──────────────────────────────────────────────────────────────────

class CheckInEntry {
  final String id;
  final DateTime date;
  final int pain, energy, water, steps;
  final String mood, notes, medicationName;
  final List<String> symptoms;
  final bool tookMedication;
  final double sleep;
  final List<String> painLocations;

  const CheckInEntry({
    required this.id, required this.date,
    required this.pain, required this.energy,
    required this.mood, required this.symptoms,
    required this.notes, required this.tookMedication,
    required this.medicationName, required this.water,
    required this.steps, required this.sleep,
    this.painLocations = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'date': date.toIso8601String(),
    'pain': pain, 'energy': energy, 'mood': mood,
    'symptoms': symptoms, 'notes': notes,
    'tookMedication': tookMedication, 'medicationName': medicationName,
    'water': water, 'steps': steps, 'sleep': sleep,
    'painLocations': painLocations,
  };

  factory CheckInEntry.fromMap(Map<String, dynamic> m) => CheckInEntry(
    id: m['id'] as String, date: DateTime.parse(m['date'] as String),
    pain: m['pain'] as int, energy: m['energy'] as int,
    mood: m['mood'] as String? ?? 'Okay',
    symptoms: List<String>.from(m['symptoms'] ?? []),
    notes: m['notes'] as String? ?? '',
    tookMedication: m['tookMedication'] as bool? ?? false,
    medicationName: m['medicationName'] as String? ?? '',
    water: m['water'] as int? ?? 0, steps: m['steps'] as int? ?? 0,
    sleep: (m['sleep'] ?? 0.0).toDouble(),
    painLocations: List<String>.from(m['painLocations'] ?? []),
  );

  String toJson() => jsonEncode(toMap());
  factory CheckInEntry.fromJson(String s) => CheckInEntry.fromMap(jsonDecode(s) as Map<String, dynamic>);
}

class DiaryEntry {
  final String id; final DateTime date;
  final String title, content, mood; final List<String> tags;
  const DiaryEntry({required this.id, required this.date, required this.title, required this.content, required this.mood, required this.tags});
  Map<String, dynamic> toMap() => {'id':id,'date':date.toIso8601String(),'title':title,'content':content,'mood':mood,'tags':tags};
  factory DiaryEntry.fromMap(Map<String, dynamic> m) => DiaryEntry(id:m['id'] as String,date:DateTime.parse(m['date'] as String),title:m['title'] as String??\'\',content:m['content'] as String??\'\',mood:m['mood'] as String??\'Okay\',tags:List<String>.from(m['tags']??[]));
  String toJson() => jsonEncode(toMap());
  factory DiaryEntry.fromJson(String s) => DiaryEntry.fromMap(jsonDecode(s) as Map<String, dynamic>);
}

class PlannerEvent {
  final String id; final DateTime date;
  final String title, type, notes; final TimeOfDay time; bool completed;
  PlannerEvent({required this.id,required this.date,required this.title,required this.type,required this.notes,required this.time,this.completed=false});
  Map<String, dynamic> toMap() => {'id':id,'date':date.toIso8601String(),'title':title,'type':type,'notes':notes,'hour':time.hour,'minute':time.minute,'completed':completed};
  factory PlannerEvent.fromMap(Map<String, dynamic> m) => PlannerEvent(id:m['id'] as String,date:DateTime.parse(m['date'] as String),title:m['title'] as String??\'\',type:m['type'] as String??\'Appointment\',notes:m['notes'] as String??\'\',time:TimeOfDay(hour:m['hour'] as int??9,minute:m['minute'] as int??0),completed:m['completed'] as bool??false);
  String toJson() => jsonEncode(toMap());
  factory PlannerEvent.fromJson(String s) => PlannerEvent.fromMap(jsonDecode(s) as Map<String, dynamic>);
}

// ─── Repositories ────────────────────────────────────────────────────────────

class CheckInRepository {
  static const _key = 'nova_v4';
  Future<List<CheckInEntry>> load() async {
    final p = await SharedPreferences.getInstance();
    final list = (p.getStringList(_key) ?? []).map(CheckInEntry.fromJson).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
  Future<void> save(CheckInEntry e) async {
    final p = await SharedPreferences.getInstance();
    final list = await load(); list.insert(0, e);
    await p.setStringList(_key, list.map((x) => x.toJson()).toList());
  }
  Future<void> deleteById(String id) async {
    final p = await SharedPreferences.getInstance();
    final list = await load(); list.removeWhere((e) => e.id == id);
    await p.setStringList(_key, list.map((x) => x.toJson()).toList());
  }
  Future<void> clear() async { final p = await SharedPreferences.getInstance(); await p.remove(_key); }
}

class DiaryRepository {
  static const _key = 'nova_diary_v1';
  Future<List<DiaryEntry>> load() async {
    final p = await SharedPreferences.getInstance();
    final list = (p.getStringList(_key) ?? []).map(DiaryEntry.fromJson).toList();
    list.sort((a, b) => b.date.compareTo(a.date)); return list;
  }
  Future<void> save(DiaryEntry e) async {
    final p = await SharedPreferences.getInstance();
    final list = await load(); list.removeWhere((x) => x.id == e.id); list.insert(0, e);
    await p.setStringList(_key, list.map((x) => x.toJson()).toList());
  }
  Future<void> deleteById(String id) async {
    final p = await SharedPreferences.getInstance();
    final list = await load(); list.removeWhere((e) => e.id == id);
    await p.setStringList(_key, list.map((x) => x.toJson()).toList());
  }
}

class PlannerRepository {
  static const _key = 'nova_planner_v1';
  Future<List<PlannerEvent>> load() async {
    final p = await SharedPreferences.getInstance();
    final list = (p.getStringList(_key) ?? []).map(PlannerEvent.fromJson).toList();
    list.sort((a, b) => a.date.compareTo(b.date)); return list;
  }
  Future<void> save(PlannerEvent e) async {
    final p = await SharedPreferences.getInstance();
    final list = await load(); list.removeWhere((x) => x.id == e.id); list.add(e);
    await p.setStringList(_key, list.map((x) => x.toJson()).toList());
  }
  Future<void> deleteById(String id) async {
    final p = await SharedPreferences.getInstance();
    final list = await load(); list.removeWhere((e) => e.id == id);
    await p.setStringList(_key, list.map((x) => x.toJson()).toList());
  }
}

// ─── AI Insights ─────────────────────────────────────────────────────────────

class Insight { final String icon, text; const Insight(this.icon, this.text); }

List<Insight> generateInsights(List<CheckInEntry> data) {
  if (data.length < 3) return [const Insight('💡', 'Log a few more days to unlock personalised insights.')];
  final recent = data.take(7).toList(); final insights = <Insight>[];
  if (recent.where((e) => e.sleep < 6 && e.pain >= 6).length >= 2)
    insights.add(const Insight('😴', 'Pain is higher on low-sleep nights. Try to get 7+ hours.'));
  final med = recent.where((e) => e.tookMedication).toList();
  final noMed = recent.where((e) => !e.tookMedication).toList();
  if (med.isNotEmpty && noMed.isNotEmpty) {
    final ma = med.fold(0,(a,b)=>a+b.pain)/med.length;
    final na = noMed.fold(0,(a,b)=>a+b.pain)/noMed.length;
    if (na - ma > 1) insights.add(Insight('💊','Medication reducing pain by ${(na-ma).toStringAsFixed(1)} points on average.'));
  }
  if (recent.length >= 6) {
    final f = recent.sublist(recent.length ~/ 2).fold(0,(a,b)=>a+b.pain)/(recent.length~/2);
    final s = recent.sublist(0, recent.length ~/ 2).fold(0,(a,b)=>a+b.pain)/(recent.length~/2);
    if (f - s > 1) insights.add(const Insight('📈','Pain improving this week — keep going!'));
    else if (s - f > 1) insights.add(const Insight('⚠️','Pain levels rising. Consider contacting your provider.'));
  }
  final hw = recent.where((e)=>e.water>=7).toList();
  final lw = recent.where((e)=>e.water<5).toList();
  if (hw.isNotEmpty && lw.isNotEmpty && lw.fold(0,(a,b)=>a+b.pain)/lw.length - hw.fold(0,(a,b)=>a+b.pain)/hw.length > 0.5)
    insights.add(const Insight('💧','You feel better on high-hydration days.'));
  if (insights.isEmpty) insights.add(const Insight('✨','Things look stable. Keep logging!'));
  return insights.take(3).toList();
}

int calculateStreak(List<CheckInEntry> data) {
  if (data.isEmpty) return 0;
  int streak = 0;
  DateTime check = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  for (final e in data.take(30)) {
    final ed = DateTime(e.date.year, e.date.month, e.date.day);
    final diff = check.difference(ed).inDays;
    if (diff == streak) { streak++; check = check.subtract(const Duration(days:1)); }
    else if (diff > streak) break;
  }
  return streak;
}

// ─── Export ──────────────────────────────────────────────────────────────────

class ExportService {
  static String generateCsv(List<CheckInEntry> data) {
    final rows = ['Date,Time,Pain,Energy,Mood,Symptoms,Water,Sleep,Steps,Medication,Notes'];
    for (final e in data) {
      final d = e.date;
      rows.add('${d.day}/${d.month}/${d.year},${d.hour}:${d.minute.toString().padLeft(2,'0')},${e.pain},${e.energy},${e.mood},"${e.symptoms.join(';')}",${e.water},${e.sleep.toStringAsFixed(1)},${e.steps},${e.tookMedication?'Yes':'No'},"${e.notes.replaceAll(',',';')}"');
    }
    return rows.join('\n');
  }

  static String generateHtmlReport(List<CheckInEntry> data, String name) {
    if (data.isEmpty) return '<p>No data.</p>';
    final avgPain = (data.fold(0,(a,b)=>a+b.pain)/data.length).toStringAsFixed(1);
    final avgEnergy = (data.fold(0,(a,b)=>a+b.energy)/data.length).toStringAsFixed(1);
    final syms = <String,int>{};
    for (final e in data) for (final s in e.symptoms) syms[s]=(syms[s]??0)+1;
    final topSyms = (syms.entries.toList()..sort((a,b)=>b.value.compareTo(a.value))).take(6).map((e)=>'<tr><td>${e.key}</td><td>${e.value}</td><td>${((e.value/data.length)*100).toStringAsFixed(0)}%</td></tr>').join();
    final rows = data.map((e){final d=e.date;final dc=e.pain<=3?'#00C9A7':e.pain<=6?'#FFB830':'#FF6B6B';return '<tr><td>${d.day}/${d.month}/${d.year}</td><td style="color:$dc;font-weight:600">${e.pain}/10</td><td>${e.energy}/10</td><td>${e.mood}</td><td>${e.symptoms.isEmpty?\'—\':e.symptoms.join(\', \')}</td><td>${e.water}gl</td><td>${e.sleep.toStringAsFixed(1)}h</td><td>${e.tookMedication?(e.medicationName.isEmpty?\'Yes\':e.medicationName):\'—\'}</td><td>${e.notes.isEmpty?\'—\':e.notes}</td></tr>';}).join();
    final now=DateTime.now();
    return '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Nova Report</title><style>*{box-sizing:border-box;margin:0;padding:0}body{font-family:Arial,sans-serif;color:#1A1535}.hdr{background:linear-gradient(135deg,#6C63FF,#4B44CC);color:white;padding:32px}.hdr h1{font-size:28px;font-weight:700}.hdr p{opacity:.8;font-size:14px;margin-top:4px}.body{padding:32px}.sec{margin-bottom:32px}.sec h2{font-size:18px;font-weight:700;color:#6C63FF;margin-bottom:12px;padding-bottom:8px;border-bottom:2px solid #EAE8FF}.grid{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:16px}.stat{background:#F7F5FF;border-radius:12px;padding:16px;text-align:center}.sval{font-size:24px;font-weight:700;color:#6C63FF}.slbl{font-size:11px;color:#6B6890;margin-top:2px}table{width:100%;border-collapse:collapse;font-size:12px}th{background:#EAE8FF;color:#4B44CC;font-weight:600;padding:8px;text-align:left}td{padding:8px;border-bottom:1px solid #F0EEF8}.ftr{background:#F7F5FF;padding:16px;text-align:center;font-size:11px;color:#6B6890}@media print{body{-webkit-print-color-adjust:exact;print-color-adjust:exact}}</style></head><body><div class="hdr"><h1>Nova Pain Report</h1><p>Patient: $name | Generated: ${now.day}/${now.month}/${now.year} | ${data.length} entries</p></div><div class="body"><div class="sec"><h2>Summary</h2><div class="grid"><div class="stat"><div class="sval">$avgPain</div><div class="slbl">Avg Pain</div></div><div class="stat"><div class="sval">$avgEnergy</div><div class="slbl">Avg Energy</div></div><div class="stat"><div class="sval">${data.where((e)=>e.tookMedication).length}</div><div class="slbl">Med Days</div></div><div class="stat"><div class="sval">${data.length}</div><div class="slbl">Entries</div></div></div></div>${syms.isNotEmpty?'<div class="sec"><h2>Top Symptoms</h2><table><tr><th>Symptom</th><th>Days</th><th>Frequency</th></tr>$topSyms</table></div>':\'\'}<div class="sec"><h2>Daily Log</h2><table><tr><th>Date</th><th>Pain</th><th>Energy</th><th>Mood</th><th>Symptoms</th><th>Water</th><th>Sleep</th><th>Medication</th><th>Notes</th></tr>$rows</table></div></div><div class="ftr">Generated by Nova Pain Management App. For informational purposes only.</div></body></html>';
  }
}

// ─── App Root ────────────────────────────────────────────────────────────────

class NovaApp extends StatelessWidget {
  const NovaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Nova', debugShowCheckedModeBanner: false, theme: _theme(), home: const AppShell(),
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _idx = 0;
  final _repo    = CheckInRepository();
  final _diary   = DiaryRepository();
  final _planner = PlannerRepository();
  int _tick = 0;
  void _refresh() => setState(() => _tick++);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(repo: _repo, tick: _tick, onCheckIn: () => setState(() => _idx = 1)),
      CheckInScreen(_repo, onSaved: _refresh),
      PlannerScreen(repo: _planner),
      DiaryScreen(repo: _diary),
      MoreScreen(checkInRepo: _repo),
    ];

    if (R.isDesktop(context)) {
      return Scaffold(body: Row(children: [
        Container(
          color: _bg2,
          child: NavigationRail(
            backgroundColor: _bg2, selectedIndex: _idx,
            onDestinationSelected: (i) => setState(() => _idx = i),
            labelType: NavigationRailLabelType.all,
            indicatorColor: _purpleGlow,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('Nova', style: GoogleFonts.dmSans(color: _purple, fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined, color: _text2), selectedIcon: Icon(Icons.dashboard, color: _purple), label: Text('Home')),
              NavigationRailDestination(icon: Icon(Icons.add_circle_outline, color: _text2), selectedIcon: Icon(Icons.add_circle, color: _purple), label: Text('Check-in')),
              NavigationRailDestination(icon: Icon(Icons.calendar_month_outlined, color: _text2), selectedIcon: Icon(Icons.calendar_month, color: _purple), label: Text('Planner')),
              NavigationRailDestination(icon: Icon(Icons.book_outlined, color: _text2), selectedIcon: Icon(Icons.book, color: _purple), label: Text('Diary')),
              NavigationRailDestination(icon: Icon(Icons.more_horiz, color: _text2), selectedIcon: Icon(Icons.more_horiz, color: _purple), label: Text('More')),
            ],
          ),
        ),
        Container(width: 1, color: _border),
        Expanded(child: pages[_idx]),
      ]));
    }

    return Scaffold(
      body: IndexedStack(index: _idx, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: _bg2,
          border: Border(top: BorderSide(color: _border)),
        ),
        child: NavigationBar(
          backgroundColor: _bg2,
          surfaceTintColor: Colors.transparent,
          indicatorColor: _purpleGlow,
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined, color: _text2), selectedIcon: Icon(Icons.dashboard, color: _purple), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline, color: _text2), selectedIcon: Icon(Icons.add_circle, color: _purple), label: 'Check-in'),
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined, color: _text2), selectedIcon: Icon(Icons.calendar_month, color: _purple), label: 'Planner'),
            NavigationDestination(icon: Icon(Icons.book_outlined, color: _text2), selectedIcon: Icon(Icons.book, color: _purple), label: 'Diary'),
            NavigationDestination(icon: Icon(Icons.more_horiz, color: _text2), selectedIcon: Icon(Icons.more_horiz, color: _purple), label: 'More'),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard ───────────────────────────────────────────────────────────────

class DashboardScreen extends StatelessWidget {
  final CheckInRepository repo;
  final int tick;
  final VoidCallback onCheckIn;
  const DashboardScreen({super.key, required this.repo, required this.tick, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CheckInEntry>>(
      future: repo.load(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Scaffold(backgroundColor: _bg, body: Center(child: CircularProgressIndicator(color: _purple)));
        final list = snap.data!;
        if (list.isEmpty) return _emptyDashboard(ctx);

        final latest  = list.first;
        final r7      = list.reversed.take(7).toList();
        final insights = generateInsights(list);
        final streak  = calculateStreak(list);
        final wkAvg   = r7.isEmpty ? 0.0 : r7.fold(0,(a,b)=>a+b.pain)/r7.length;

        return Scaffold(
          backgroundColor: _bg,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: Stack(children: [
                // Background glow orbs
                Positioned(top: -60, right: -60, child: _orb(280, _purple, 0.2)),
                Positioned(top: 180, left: -50, child: _orb(180, _teal, 0.15)),
                Positioned(top: 100, right: 20, child: _orb(120, _coral, 0.1)),

                SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_greeting(), style: GoogleFonts.dmSans(color: _text2, fontSize: 13)),
                        const SizedBox(height: 2),
                        RichText(text: TextSpan(children: [
                          TextSpan(text: 'How are you ', style: GoogleFonts.dmSans(color: _text, fontSize: 22, fontWeight: FontWeight.w600)),
                          TextSpan(text: 'feeling?', style: GoogleFonts.dmSans(color: _purple, fontSize: 22, fontWeight: FontWeight.w700)),
                        ])),
                      ]),
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [_purple, _teal]),
                        ),
                        child: Center(child: Text('G', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // Horizontal stat pills
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _statPill('🔴', latest.pain.toString(), 'Pain', _pc(latest.pain)),
                        _statPill('⚡', latest.energy.toString(), 'Energy', _ec(latest.energy)),
                        _statPill('😊', latest.mood, 'Mood', _purple),
                        _statPill('🔥', '$streak', 'Streak', _amber),
                        _statPill('💧', '${latest.water}/8', 'Water', _teal),
                        _statPill('😴', '${latest.sleep.toStringAsFixed(1)}h', 'Sleep', _purple),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Streak hero card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors:[_purple,_purpleDark], begin:Alignment.topLeft, end:Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: _purple.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Current streak', style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('$streak', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w700, height: 1)),
                            const SizedBox(width: 8),
                            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('days 🔥', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14))),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: List.generate(7, (i) => Container(
                            width: 10, height: 10, margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: i < streak ? Colors.white : Colors.white24),
                          ))),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('This week', style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(wkAvg.toStringAsFixed(1), style: GoogleFonts.dmSans(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w600, height: 1)),
                          Text('avg pain', style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 12)),
                          const SizedBox(height: 16),
                          _trendArrow(r7),
                        ]),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 24),
                ])),
              ])),

              // Progress rings
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sectionTitle('PROGRESS'),
                  const SizedBox(height: 12),
                  Row(children: [
                    _ringCard('Water', latest.water/8, '${latest.water}/8', _purple),
                    const SizedBox(width: 10),
                    _ringCard('Sleep', latest.sleep/8, '${latest.sleep.toStringAsFixed(1)}h', _teal),
                    const SizedBox(width: 10),
                    _ringCard('Steps', latest.steps/8000, _fs(latest.steps), _amber),
                  ]),
                ])),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Pain trend
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sectionTitle('PAIN TREND (7 DAYS)'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Pain levels', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: _text)),
                        _trendBadge(r7),
                      ]),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: r7.length > 1
                            ? CustomPaint(painter: DarkTrendPainter(r7, (e) => e.pain.toDouble()))
                            : Center(child: Text('Log more days', style: GoogleFonts.dmSans(color: _text3))),
                      ),
                    ]),
                  ),
                ])),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // AI Insights
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sectionTitle('AI INSIGHTS'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: _purpleGlow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _purple.withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(children: insights.map((ins) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ins.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(ins.text, style: GoogleFonts.dmSans(fontSize: 13, color: _text, height: 1.5))),
                      ]),
                    )).toList()),
                  ),
                ])),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Quick actions
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sectionTitle('QUICK ACTIONS'),
                  const SizedBox(height: 12),
                  Row(children: [
                    _qaCard('✚', 'Check-in', _purple, _purpleGlow, onCheckIn),
                    const SizedBox(width: 10),
                    _qaCard('📅', 'Planner', _teal, _tealGlow, () {}),
                    const SizedBox(width: 10),
                    _qaCard('📓', 'Diary', _amber, _amberGlow, () {}),
                    const SizedBox(width: 10),
                    _qaCard('⬇', 'Export', _coral, _coralGlow, () {}),
                  ]),
                ])),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Latest check-in
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sectionTitle('LATEST CHECK-IN'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _detRow('Pain', '${latest.pain}/10'),
                      _detRow('Energy', '${latest.energy}/10'),
                      _detRow('Mood', latest.mood),
                      _detRow('Symptoms', latest.symptoms.isEmpty ? 'None' : latest.symptoms.join(', ')),
                      _detRow('Medication', latest.tookMedication ? (latest.medicationName.isEmpty ? 'Taken' : latest.medicationName) : 'None'),
                      _detRow('Water', '${latest.water} glasses'),
                      _detRow('Sleep', '${latest.sleep.toStringAsFixed(1)}h'),
                      if (latest.notes.isNotEmpty) _detRow('Notes', latest.notes),
                    ]),
                  ),
                ])),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyDashboard(BuildContext ctx) => Scaffold(
    backgroundColor: _bg,
    body: Stack(children: [
      Positioned(top: -60, right: -60, child: _orb(280, _purple, 0.2)),
      Positioned(top: 200, left: -50, child: _orb(180, _teal, 0.15)),
      SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Nova', style: GoogleFonts.dmSans(color: _purple, fontSize: 48, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Your pain management companion', style: GoogleFonts.dmSans(color: _text2, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: _border)),
            child: Column(children: [
              const Text('🌟', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('Welcome to Nova', style: GoogleFonts.dmSans(color: _text, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Start tracking your pain to unlock insights and patterns.', style: GoogleFonts.dmSans(color: _text2, fontSize: 14), textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: onCheckIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple, foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text('Start your first check-in', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
          )),
        ]),
      )),
    ]),
  );

  Widget _orb(double size, Color color, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(opacity)),
  );

  Widget _statPill(String icon, String val, String label, Color color) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text(val, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: _text2)),
    ]),
  );

  Widget _trendArrow(List<CheckInEntry> r7) {
    if (r7.length < 2) return const SizedBox();
    final first = r7.first.pain.toDouble();
    final last  = r7.last.pain.toDouble();
    final improving = last < first;
    return Row(children: [
      Icon(improving ? Icons.trending_down : Icons.trending_up, color: improving ? _teal : _coral, size: 18),
      const SizedBox(width: 4),
      Text(improving ? 'Improving' : 'Rising', style: GoogleFonts.dmSans(color: improving ? _teal : _coral, fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _trendBadge(List<CheckInEntry> r7) {
    if (r7.length < 2) return const SizedBox();
    final improving = r7.last.pain < r7.first.pain;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: improving ? _tealGlow : _coralGlow, borderRadius: BorderRadius.circular(10)),
      child: Text(improving ? '↓ Improving' : '↑ Rising', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: improving ? _teal : _coral)),
    );
  }

  Widget _ringCard(String label, double progress, String val, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border)),
      child: Column(children: [
        SizedBox(width: 56, height: 56, child: CustomPaint(painter: DarkRingPainter(progress.clamp(0.0,1.0), color))),
        const SizedBox(height: 8),
        Text(val, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: _text)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: _text2)),
      ]),
    ),
  );

  Widget _qaCard(String icon, String label, Color color, Color bg, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    ),
  );

  Widget _detRow(String l, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 90, child: Text(l, style: GoogleFonts.dmSans(color: _text2, fontWeight: FontWeight.w500, fontSize: 13))),
      Expanded(child: Text(v, style: GoogleFonts.dmSans(fontSize: 13, color: _text))),
    ]),
  );

  Color _pc(int p) => p<=3?_teal:p<=6?_amber:_coral;
  Color _ec(int e) => e>=7?_teal:e>=4?_amber:_coral;
  String _fs(int s) => s>=1000?'${(s/1000).toStringAsFixed(1)}k':s.toString();
}

// ─── Check-In ────────────────────────────────────────────────────────────────

class CheckInScreen extends StatefulWidget {
  final CheckInRepository repo; final VoidCallback onSaved;
  const CheckInScreen(this.repo, {super.key, required this.onSaved});
  @override State<CheckInScreen> createState() => _CheckInState();
}

class _CheckInState extends State<CheckInScreen> {
  double pain=5, energy=5, water=4, sleep=7;
  String mood='Okay'; bool tookMedication=false;
  final Set<String> selectedSymptoms={}, selectedLocations={};
  final _steps=TextEditingController(text:'3000'), _notes=TextEditingController(), _med=TextEditingController();
  bool _saving=false;

  static const _symptoms=['Headache','Fatigue','Nausea','Back pain','Joint pain','Brain fog','Dizziness','Poor sleep','Anxiety','Insomnia','Muscle pain','Stiffness'];
  static const _moods=['Very low','Low','Okay','Good','Great'];
  static const _bodyParts=['Neck','Upper back','Lower back','Left shoulder','Right shoulder','Left hip','Right hip','Left knee','Right knee','Lumbar','Thoracic','Sacrum'];

  @override void dispose() { _steps.dispose(); _notes.dispose(); _med.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_saving) return;
    setState(()=>_saving=true);
    try {
      await widget.repo.save(CheckInEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(), date: DateTime.now(),
        pain: pain.round(), energy: energy.round(), mood: mood,
        symptoms: selectedSymptoms.toList()..sort(), notes: _notes.text.trim(),
        tookMedication: tookMedication, medicationName: _med.text.trim(),
        water: water.round(), steps: int.tryParse(_steps.text)??0, sleep: sleep,
        painLocations: selectedLocations.toList(),
      ));
      widget.onSaved();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check-in saved! 🎉')));
      _reset();
    } finally { if (mounted) setState(()=>_saving=false); }
  }

  void _reset() {
    setState((){pain=5;energy=5;water=4;sleep=7;mood='Okay';tookMedication=false;selectedSymptoms.clear();selectedLocations.clear();});
    _steps.text='3000'; _notes.clear(); _med.clear();
  }

  @override
  Widget build(BuildContext context) {
    final pad = R.pad(context);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Check-in', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 22, color: _purple)),
          Text(_fmtDate(DateTime.now()), style: GoogleFonts.dmSans(fontSize: 12, color: _text2)),
        ]),
        toolbarHeight: 64,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, 24),
        children: [

          _darkCard(Column(children: [
            _sl(context,'Pain level',pain,0,10,10,(v)=>setState(()=>pain=v),'${pain.round()}/10','None','Severe',_pc(pain.round())),
            const SizedBox(height: 16),
            _sl(context,'Energy level',energy,0,10,10,(v)=>setState(()=>energy=v),'${energy.round()}/10','Exhausted','Energised',_ec(energy.round())),
          ])),

          const SizedBox(height: 12),

          _darkCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Mood', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: _text)),
            const SizedBox(height: 12),
            Wrap(spacing:8,runSpacing:8,children:_moods.map((m){final sel=mood==m;return GestureDetector(onTap:()=>setState(()=>mood=m),child:AnimatedContainer(duration:const Duration(milliseconds:150),padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),decoration:BoxDecoration(color:sel?_purple:_surfaceGlow,borderRadius:BorderRadius.circular(20),border:Border.all(color:sel?_purple:_border,width:1.5)),child:Text(m,style:GoogleFonts.dmSans(fontSize:13,color:sel?Colors.white:_text2,fontWeight:sel?FontWeight.w600:FontWeight.normal))));}).toList()),
          ])),

          const SizedBox(height: 12),

          _darkCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Text('🫀', style: TextStyle(fontSize: 18)), const SizedBox(width: 8), Text('Pain locations', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: _text))]),
            const SizedBox(height: 4),
            Text('Select all areas where you feel pain', style: GoogleFonts.dmSans(fontSize: 12, color: _text2)),
            const SizedBox(height: 14),
            SizedBox(height: 260, child: Row(children: [
              Expanded(child: CustomPaint(painter: BodyDiagramPainter(selectedLocations, dark: true), child: GestureDetector(onTapDown:(d)=>_handleBodyTap(d.localPosition)))),
              const SizedBox(width: 12),
              Expanded(child: Wrap(spacing:6,runSpacing:6,children:_bodyParts.map((p){final sel=selectedLocations.contains(p);return GestureDetector(onTap:()=>setState(()=>sel?selectedLocations.remove(p):selectedLocations.add(p)),child:AnimatedContainer(duration:const Duration(milliseconds:150),padding:const EdgeInsets.symmetric(horizontal:8,vertical:5),decoration:BoxDecoration(color:sel?_coralGlow:_surfaceGlow,borderRadius:BorderRadius.circular(8),border:Border.all(color:sel?_coral:_border)),child:Text(p,style:GoogleFonts.dmSans(fontSize:10,color:sel?_coral:_text2))));}).toList())),
            ])),
          ])),

          const SizedBox(height: 12),

          _darkCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Symptoms today', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: _text)),
            const SizedBox(height: 12),
            Wrap(spacing:8,runSpacing:8,children:_symptoms.map((s){final sel=selectedSymptoms.contains(s);return GestureDetector(onTap:()=>setState(()=>sel?selectedSymptoms.remove(s):selectedSymptoms.add(s)),child:AnimatedContainer(duration:const Duration(milliseconds:150),padding:const EdgeInsets.symmetric(horizontal:12,vertical:7),decoration:BoxDecoration(color:sel?_coralGlow:_surfaceGlow,borderRadius:BorderRadius.circular(16),border:Border.all(color:sel?_coral:_border,width:1.5)),child:Text(s,style:GoogleFonts.dmSans(fontSize:12,color:sel?_coral:_text2,fontWeight:sel?FontWeight.w600:FontWeight.normal))));}).toList()),
          ])),

          const SizedBox(height: 12),

          _darkCard(Column(children: [
            _sl(context,'Water',water,0,12,12,(v)=>setState(()=>water=v),'${water.round()} glasses',null,null,_teal),
            const SizedBox(height: 16),
            _sl(context,'Sleep',sleep,0,12,24,(v)=>setState(()=>sleep=v),'${sleep.toStringAsFixed(1)} hours',null,null,_purple),
          ])),

          const SizedBox(height: 12),

          _darkCard(TextField(controller:_steps,keyboardType:TextInputType.number,inputFormatters:[FilteringTextInputFormatter.digitsOnly],style:GoogleFonts.dmSans(color:_text),decoration:InputDecoration(labelText:'Steps today',prefixIcon:const Icon(Icons.directions_walk_outlined,color:_amber),border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none,filled:false))),

          const SizedBox(height: 12),

          _darkCard(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
              Text('Took medication',style:GoogleFonts.dmSans(fontSize:15,fontWeight:FontWeight.w500,color:_text)),
              Switch(value:tookMedication,onChanged:(v)=>setState(()=>tookMedication=v)),
            ]),
            if(tookMedication)...[const SizedBox(height:8),TextField(controller:_med,style:GoogleFonts.dmSans(color:_text),decoration:const InputDecoration(labelText:'Medication name',border:InputBorder.none,enabledBorder:InputBorder.none,filled:false))],
          ])),

          const SizedBox(height: 12),

          _darkCard(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('Notes',style:GoogleFonts.dmSans(fontSize:16,fontWeight:FontWeight.w600,color:_text)),
            const SizedBox(height:8),
            TextField(controller:_notes,maxLines:4,style:GoogleFonts.dmSans(color:_text),decoration:InputDecoration(hintText:'How are you feeling? Any triggers...', hintStyle:GoogleFonts.dmSans(color:_text3),border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none,filled:false)),
          ])),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _saving?null:_save,
            style: ElevatedButton.styleFrom(
              backgroundColor:_purple, foregroundColor:Colors.white,
              minimumSize:const Size.fromHeight(54),
              shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),
              elevation:0,
            ),
            child: _saving ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2))
                : Text('Save check-in',style:GoogleFonts.dmSans(fontSize:16,fontWeight:FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _handleBodyTap(Offset pos) {
    const regions = {
      'Neck': Rect.fromLTWH(60,30,60,30), 'Upper back': Rect.fromLTWH(40,70,100,50),
      'Lower back': Rect.fromLTWH(40,120,100,50), 'Sacrum': Rect.fromLTWH(55,170,70,30),
      'Left shoulder': Rect.fromLTWH(10,65,40,40), 'Right shoulder': Rect.fromLTWH(130,65,40,40),
      'Left hip': Rect.fromLTWH(20,165,55,40), 'Right hip': Rect.fromLTWH(105,165,55,40),
    };
    for (final e in regions.entries) {
      if (e.value.contains(pos)) {
        setState(() { if(selectedLocations.contains(e.key)) selectedLocations.remove(e.key); else selectedLocations.add(e.key); });
        return;
      }
    }
  }

  Widget _darkCard(Widget child) => Container(
    margin: EdgeInsets.zero,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
    child: child,
  );

  Widget _sl(BuildContext ctx, String title, double value, double min, double max, int div, ValueChanged<double> onChange, String valText, String? lead, String? trail, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: GoogleFonts.dmSans(fontSize:15,fontWeight:FontWeight.w600,color:_text)),
        Text(valText, style: GoogleFonts.dmSans(fontSize:14,fontWeight:FontWeight.w700,color:color)),
      ]),
      SliderTheme(data:SliderTheme.of(ctx).copyWith(activeTrackColor:color,thumbColor:color,inactiveTrackColor:_surfaceGlow), child:Slider(value:value,min:min,max:max,divisions:div,onChanged:onChange)),
      if(lead!=null&&trail!=null) Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(lead,style:GoogleFonts.dmSans(fontSize:11,color:_text3)),Text(trail,style:GoogleFonts.dmSans(fontSize:11,color:_text3))]),
    ]);
  }

  Color _pc(int p) => p<=3?_teal:p<=6?_amber:_coral;
  Color _ec(int e) => e>=7?_teal:e>=4?_amber:_coral;
}

// ─── Planner ─────────────────────────────────────────────────────────────────

class PlannerScreen extends StatefulWidget {
  final PlannerRepository repo;
  const PlannerScreen({super.key, required this.repo});
  @override State<PlannerScreen> createState() => _PlannerState();
}

class _PlannerState extends State<PlannerScreen> {
  DateTime _selected = DateTime.now();

  static const _types = ['Appointment','Medication','Exercise','Rest','Goal','Other'];
  static const _typeColors = {'Appointment':_purple,'Medication':_teal,'Exercise':_amber,'Rest':_coral,'Goal':_green,'Other':_text2};
  static const _typeIcons = {'Appointment':Icons.medical_services_outlined,'Medication':Icons.medication_outlined,'Exercise':Icons.fitness_center_outlined,'Rest':Icons.bed_outlined,'Goal':Icons.flag_outlined,'Other':Icons.event_outlined};

  Future<void> _addEvent() async {
    final titleCtrl = TextEditingController(); final notesCtrl = TextEditingController();
    String type = 'Appointment'; TimeOfDay time = const TimeOfDay(hour: 9, minute: 0);
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, showDragHandle: true,
      backgroundColor: _bg2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => Padding(
        padding: EdgeInsets.fromLTRB(24,0,24,MediaQuery.of(ctx).viewInsets.bottom+32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add event', style: GoogleFonts.dmSans(fontSize:20,fontWeight:FontWeight.w700,color:_text)),
          const SizedBox(height:16),
          TextField(controller:titleCtrl,style:GoogleFonts.dmSans(color:_text),decoration:const InputDecoration(labelText:'Title')),
          const SizedBox(height:12),
          Text('Type', style:GoogleFonts.dmSans(fontSize:14,color:_text2)),
          const SizedBox(height:8),
          Wrap(spacing:8,runSpacing:8,children:_types.map((t){final sel=type==t;final c=_typeColors[t]??_text2;return GestureDetector(onTap:()=>set(()=>type=t),child:AnimatedContainer(duration:const Duration(milliseconds:150),padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),decoration:BoxDecoration(color:sel?c.withOpacity(0.2):_surfaceGlow,borderRadius:BorderRadius.circular(20),border:Border.all(color:sel?c:_border,width:1.5)),child:Text(t,style:GoogleFonts.dmSans(fontSize:12,color:sel?c:_text2,fontWeight:sel?FontWeight.w600:FontWeight.normal))));}).toList()),
          const SizedBox(height:12),
          GestureDetector(onTap:()async{final t=await showTimePicker(context:ctx,initialTime:time);if(t!=null)set(()=>time=t);},child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:_surfaceGlow,borderRadius:BorderRadius.circular(14),border:Border.all(color:_border)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Time',style:GoogleFonts.dmSans(fontSize:14,color:_text2)),Text(time.format(ctx),style:GoogleFonts.dmSans(fontSize:14,fontWeight:FontWeight.w600,color:_purple))]))),
          const SizedBox(height:16),
          SizedBox(width:double.infinity,child:ElevatedButton(onPressed:()async{if(titleCtrl.text.trim().isEmpty)return;await widget.repo.save(PlannerEvent(id:DateTime.now().microsecondsSinceEpoch.toString(),date:_selected,title:titleCtrl.text.trim(),type:type,notes:notesCtrl.text.trim(),time:time));if(mounted){Navigator.pop(context);setState((){});}},style:ElevatedButton.styleFrom(backgroundColor:_purple,foregroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),elevation:0,minimumSize:const Size.fromHeight(48)),child:Text('Add event',style:GoogleFonts.dmSans(fontWeight:FontWeight.w600)))),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlannerEvent>>(
      future: widget.repo.load(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Scaffold(backgroundColor:_bg,body:Center(child:CircularProgressIndicator(color:_purple)));
        final all = snap.data!;
        final today = all.where((e)=>_sd(e.date,_selected)).toList()..sort((a,b)=>a.time.hour*60+a.time.minute-(b.time.hour*60+b.time.minute));

        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(backgroundColor:_bg,title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Planner',style:GoogleFonts.dmSans(fontWeight:FontWeight.w700,fontSize:22,color:_purple)),Text('Appointments & goals',style:GoogleFonts.dmSans(fontSize:12,color:_text2))]),toolbarHeight:64),
          floatingActionButton: FloatingActionButton(onPressed:_addEvent,backgroundColor:_purple,child:const Icon(Icons.add,color:Colors.white)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16,16,16,100),
            children: [
              SizedBox(height:80,child:ListView.builder(scrollDirection:Axis.horizontal,itemCount:14,itemBuilder:(_, i){
                final d=DateTime.now().subtract(const Duration(days:3)).add(Duration(days:i));
                final sel=_sd(d,_selected); final hasE=all.any((e)=>_sd(e.date,d));
                return GestureDetector(onTap:()=>setState(()=>_selected=d),child:AnimatedContainer(duration:const Duration(milliseconds:150),width:52,margin:const EdgeInsets.only(right:8),decoration:BoxDecoration(color:sel?_purple:_surface,borderRadius:BorderRadius.circular(14),border:Border.all(color:sel?_purple:_border)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(_da(d.weekday),style:GoogleFonts.dmSans(fontSize:11,color:sel?Colors.white70:_text2)),const SizedBox(height:4),Text('${d.day}',style:GoogleFonts.dmSans(fontSize:18,fontWeight:FontWeight.w700,color:sel?Colors.white:_text)),const SizedBox(height:4),if(hasE)Container(width:6,height:6,decoration:BoxDecoration(shape:BoxShape.circle,color:sel?Colors.white:_purple))])));
              })),
              const SizedBox(height:20),
              _sectionTitle('EVENTS — ${_fds(_selected).toUpperCase()}'),
              const SizedBox(height:10),
              if(today.isEmpty) Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(16),border:Border.all(color:_border)),child:Column(children:[const Icon(Icons.event_available_outlined,color:_text3,size:40),const SizedBox(height:8),Text('No events today',style:GoogleFonts.dmSans(color:_text2,fontSize:14))]))
              else ...today.map((e)=>_eventTile(e)),
            ],
          ),
        );
      },
    );
  }

  Widget _eventTile(PlannerEvent e) {
    final c = _typeColors[e.type]??_text2; final ic = _typeIcons[e.type]??Icons.event_outlined;
    return Container(
      margin: const EdgeInsets.only(bottom:10),
      decoration: BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(16),border:Border.all(color:_border)),
      child: ListTile(
        leading: Container(width:40,height:40,decoration:BoxDecoration(color:c.withOpacity(0.15),shape:BoxShape.circle),child:Icon(ic,color:c,size:20)),
        title: Text(e.title,style:GoogleFonts.dmSans(fontSize:14,fontWeight:FontWeight.w600,color:e.completed?_text2:_text,decoration:e.completed?TextDecoration.lineThrough:null)),
        subtitle: Text('${e.time.format(context)} · ${e.type}',style:GoogleFonts.dmSans(fontSize:12,color:_text2)),
        trailing: Checkbox(value:e.completed,activeColor:_purple,checkColor:Colors.white,side:const BorderSide(color:_text3),onChanged:(v)async{e.completed=v??false;await widget.repo.save(e);setState((){});}),
      ),
    );
  }

  bool _sd(DateTime a, DateTime b) => a.year==b.year&&a.month==b.month&&a.day==b.day;
  String _da(int d) => const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d-1];
  String _fds(DateTime d) { const mo=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${d.day} ${mo[d.month-1]}'; }
}

// ─── Diary ───────────────────────────────────────────────────────────────────

class DiaryScreen extends StatefulWidget {
  final DiaryRepository repo;
  const DiaryScreen({super.key, required this.repo});
  @override State<DiaryScreen> createState() => _DiaryState();
}

class _DiaryState extends State<DiaryScreen> {
  Future<void> _new(BuildContext context) async {
    final titleCtrl=TextEditingController(); final contentCtrl=TextEditingController();
    String mood='Okay'; final Set<String> tags={};
    const allTags=['Good day','Bad day','Pain flare','Rested','Anxious','Grateful','Active','Social','Quiet day','Doctor visit'];
    await showModalBottomSheet<void>(context:context,isScrollControlled:true,showDragHandle:true,backgroundColor:_bg2,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),builder:(ctx)=>StatefulBuilder(builder:(ctx,set)=>Padding(padding:EdgeInsets.fromLTRB(24,0,24,MediaQuery.of(ctx).viewInsets.bottom+32),child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text('New entry',style:GoogleFonts.dmSans(fontSize:20,fontWeight:FontWeight.w700,color:_text)),Text(_fmtDateFull(DateTime.now()),style:GoogleFonts.dmSans(fontSize:13,color:_text2)),const SizedBox(height:16),TextField(controller:titleCtrl,style:GoogleFonts.dmSans(color:_text),decoration:const InputDecoration(labelText:'Title')),const SizedBox(height:12),TextField(controller:contentCtrl,style:GoogleFonts.dmSans(color:_text),maxLines:6,decoration:const InputDecoration(labelText:'Write your thoughts...',alignLabelWithHint:true)),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:['Very low','Low','Okay','Good','Great'].map((m){final sel=mood==m;return GestureDetector(onTap:()=>set(()=>mood=m),child:AnimatedContainer(duration:const Duration(milliseconds:150),padding:const EdgeInsets.symmetric(horizontal:14,vertical:7),decoration:BoxDecoration(color:sel?_purple:_surfaceGlow,borderRadius:BorderRadius.circular(20),border:Border.all(color:sel?_purple:_border,width:1.5)),child:Text(m,style:GoogleFonts.dmSans(fontSize:12,color:sel?Colors.white:_text2))));}).toList()),const SizedBox(height:12),Wrap(spacing:6,runSpacing:6,children:allTags.map((t){final sel=tags.contains(t);return GestureDetector(onTap:()=>set(()=>sel?tags.remove(t):tags.add(t)),child:Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),decoration:BoxDecoration(color:sel?_purpleGlow:_surfaceGlow,borderRadius:BorderRadius.circular(10),border:Border.all(color:sel?_purple:_border)),child:Text(t,style:GoogleFonts.dmSans(fontSize:11,color:sel?_purple:_text2))));}).toList()),const SizedBox(height:16),SizedBox(width:double.infinity,child:ElevatedButton(onPressed:()async{if(contentCtrl.text.trim().isEmpty)return;await DiaryRepository().save(DiaryEntry(id:DateTime.now().microsecondsSinceEpoch.toString(),date:DateTime.now(),title:titleCtrl.text.trim().isEmpty?'Entry ${DateTime.now().day}/${DateTime.now().month}':titleCtrl.text.trim(),content:contentCtrl.text.trim(),mood:mood,tags:tags.toList()));if(mounted){Navigator.pop(context);setState((){});}},style:ElevatedButton.styleFrom(backgroundColor:_purple,foregroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),elevation:0,minimumSize:const Size.fromHeight(48)),child:Text('Save entry',style:GoogleFonts.dmSans(fontWeight:FontWeight.w600))))])))));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiaryEntry>>(
      future: DiaryRepository().load(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Scaffold(backgroundColor:_bg,body:Center(child:CircularProgressIndicator(color:_purple)));
        final list = snap.data!;
        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(backgroundColor:_bg,title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Diary',style:GoogleFonts.dmSans(fontWeight:FontWeight.w700,fontSize:22,color:_purple)),Text('${list.length} entries',style:GoogleFonts.dmSans(fontSize:12,color:_text2))]),toolbarHeight:64),
          floatingActionButton: FloatingActionButton(onPressed:()=>_new(context),backgroundColor:_purple,child:const Icon(Icons.edit_outlined,color:Colors.white)),
          body: list.isEmpty ? _darkEmpty('Your diary','Tap + to write your first entry')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16,16,16,100),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final e = list[i];
                    final me = {'Very low':'😞','Low':'😕','Okay':'😐','Good':'🙂','Great':'😊'}[e.mood]??'😐';
                    return Container(
                      margin: const EdgeInsets.only(bottom:12),
                      decoration: BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:_border)),
                      child: Material(color:Colors.transparent,child:InkWell(borderRadius:BorderRadius.circular(20),onTap:()=>_show(ctx,e),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(e.title,style:GoogleFonts.dmSans(fontSize:15,fontWeight:FontWeight.w600,color:_text)),Text(me,style:const TextStyle(fontSize:20))]),const SizedBox(height:4),Text(_fmtDateFull(e.date),style:GoogleFonts.dmSans(fontSize:12,color:_text2)),const SizedBox(height:8),Text(e.content,maxLines:2,overflow:TextOverflow.ellipsis,style:GoogleFonts.dmSans(fontSize:13,color:_text2,height:1.4)),if(e.tags.isNotEmpty)...[const SizedBox(height:8),Wrap(spacing:6,runSpacing:4,children:e.tags.map((t)=>Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:3),decoration:BoxDecoration(color:_purpleGlow,borderRadius:BorderRadius.circular(8)),child:Text(t,style:GoogleFonts.dmSans(fontSize:10,color:_purple)))).toList())]]))),
                    );
                  },
                ),
        );
      },
    );
  }

  void _show(BuildContext ctx, DiaryEntry e) {
    showModalBottomSheet<void>(context:ctx,isScrollControlled:true,showDragHandle:true,backgroundColor:_bg2,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),builder:(_)=>DraggableScrollableSheet(expand:false,initialChildSize:0.75,builder:(_,ctrl)=>ListView(controller:ctrl,padding:const EdgeInsets.fromLTRB(24,0,24,32),children:[Text(e.title,style:GoogleFonts.dmSans(fontSize:22,fontWeight:FontWeight.w700,color:_text)),const SizedBox(height:4),Text(_fmtDateFull(e.date),style:GoogleFonts.dmSans(fontSize:13,color:_text2)),const SizedBox(height:16),Text(e.content,style:GoogleFonts.dmSans(fontSize:15,color:_text,height:1.6)),if(e.tags.isNotEmpty)...[const SizedBox(height:16),Wrap(spacing:8,runSpacing:6,children:e.tags.map((t)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),decoration:BoxDecoration(color:_purpleGlow,borderRadius:BorderRadius.circular(10)),child:Text(t,style:GoogleFonts.dmSans(fontSize:12,color:_purple)))).toList())],const SizedBox(height:16),OutlinedButton(onPressed:()async{await DiaryRepository().deleteById(e.id);if(mounted){Navigator.pop(ctx);setState((){});}},style:OutlinedButton.styleFrom(foregroundColor:_coral,side:const BorderSide(color:_coral),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),minimumSize:const Size.fromHeight(48)),child:Text('Delete entry',style:GoogleFonts.dmSans()))])));
  }
}

// ─── More Screen ─────────────────────────────────────────────────────────────

class MoreScreen extends StatelessWidget {
  final CheckInRepository checkInRepo;
  const MoreScreen({super.key, required this.checkInRepo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(backgroundColor:_bg,title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('More',style:GoogleFonts.dmSans(fontWeight:FontWeight.w700,fontSize:22,color:_purple)),Text('Tools & resources',style:GoogleFonts.dmSans(fontSize:12,color:_text2))]),toolbarHeight:64),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context,Icons.health_and_safety_outlined,_teal,'Advice Hub','Do\'s & don\'ts for pain',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const AdviceScreen()))),
          const SizedBox(height:10),
          _tile(context,Icons.history_outlined,_purple,'History','All your check-ins',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>HistoryScreen(repo:checkInRepo,onChanged:(){})))),
          const SizedBox(height:10),
          _tile(context,Icons.download_outlined,_coral,'Export','Doctor report & CSV',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ExportScreen(repo:checkInRepo)))),
          const SizedBox(height:10),
          _tile(context,Icons.compare_arrows_outlined,_amber,'App Comparison','Nova vs Bearable & others',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const ComparisonScreen()))),
          const SizedBox(height:10),
          _tile(context,Icons.notifications_outlined,_purple,'Notifications','Reminders & alerts',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const NotificationsScreen()))),
          const SizedBox(height:10),
          _tile(context,Icons.settings_outlined,_text2,'Settings','App preferences',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SettingsScreen()))),
        ],
      ),
    );
  }

  Widget _tile(BuildContext ctx, IconData icon, Color color, String title, String sub, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(16),border:Border.all(color:_border)),
      child: Row(children:[
        Container(width:44,height:44,decoration:BoxDecoration(color:color.withOpacity(0.15),borderRadius:BorderRadius.circular(12)),child:Icon(icon,color:color,size:22)),
        const SizedBox(width:14),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:GoogleFonts.dmSans(fontSize:15,fontWeight:FontWeight.w600,color:_text)),Text(sub,style:GoogleFonts.dmSans(fontSize:12,color:_text2))])),
        const Icon(Icons.chevron_right,color:_text3),
      ]),
    ),
  );
}

// ─── Advice Screen ───────────────────────────────────────────────────────────

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});
  static const _dos=[('Stay gently active','Walking, swimming and gentle stretching keep joints mobile. Aim for 20–30 mins daily.','🚶'),('Apply heat for chronic pain','Heat relaxes muscles. Use a heat pad for 15–20 mins on stiff joints or back.','🔥'),('Apply ice for acute flares','Ice reduces inflammation. Use for 10–15 mins wrapped in a cloth.','🧊'),('Sleep on a supportive mattress','Medium-firm support for spinal alignment. Pillow between knees relieves lumbar pressure.','🛏️'),('Stay hydrated','Spinal discs need water to maintain cushioning. Aim for 8 glasses a day.','💧'),('Pace your activity','Break tasks into chunks with rest in between. Overdoing it on good days leads to flares.','⏱️'),('Practice mindfulness','Meditation reduces the brain\'s pain perception and lowers stress hormones.','🧘'),('Strengthen your core','Core muscles support the spine. Gentle Pilates reduces back pain over time.','💪'),('Attend all medical appointments','Consistent follow-ups ensure the best treatment outcomes.','🏥'),('Use a pain journal','Tracking helps identify triggers. Share it with your doctor for better care.','📓')];
  static const _donts=[('Don\'t sit for long periods','Sitting increases disc pressure. Stand and stretch every 30 minutes.','🪑'),('Don\'t lift with your back','Bend at the knees, keep loads close, engage your core when lifting.','📦'),('Don\'t ignore warning signs','New numbness, tingling or worsening pain needs prompt medical attention.','⚠️'),('Don\'t rely solely on painkillers','Long-term NSAID use has serious side effects. Combine with other therapies.','💊'),('Don\'t sleep on your stomach','This puts your neck and lumbar spine into unnatural positions.','😴'),('Don\'t push through severe pain','Pain is a signal — rest when your body demands it.','🛑'),('Don\'t self-diagnose','Always seek professional diagnosis for new or changing symptoms.','🔍'),('Don\'t smoke','Smoking reduces blood flow to spinal discs, accelerating degeneration.','🚭'),('Don\'t catastrophise','Fear of movement worsens chronic pain. Guided activity helps rewire pain pathways.','🧠'),('Don\'t skip physiotherapy','Consistent exercises build resilience. Sporadic effort produces little improvement.','🏃')];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor:_bg,
    appBar:AppBar(backgroundColor:_bg,title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Advice Hub',style:GoogleFonts.dmSans(fontWeight:FontWeight.w700,fontSize:22,color:_purple)),Text('Evidence-based pain management',style:GoogleFonts.dmSans(fontSize:12,color:_text2))]),toolbarHeight:64),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      Text('✅  WHAT TO DO',style:GoogleFonts.dmSans(fontSize:13,fontWeight:FontWeight.w700,color:_green,letterSpacing:0.8)),
      const SizedBox(height:10),
      ..._dos.map((d)=>_aCard(d.$1,d.$2,d.$3,_green,_green.withOpacity(0.1))),
      const SizedBox(height:20),
      Text('❌  WHAT TO AVOID',style:GoogleFonts.dmSans(fontSize:13,fontWeight:FontWeight.w700,color:_coral,letterSpacing:0.8)),
      const SizedBox(height:10),
      ..._donts.map((d)=>_aCard(d.$1,d.$2,d.$3,_coral,_coral.withOpacity(0.08))),
      const SizedBox(height:20),
      Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:_amber.withOpacity(0.1),borderRadius:BorderRadius.circular(14),border:Border.all(color:_amber.withOpacity(0.2))),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('⚕️',style:TextStyle(fontSize:20)),const SizedBox(width:12),Expanded(child:Text('General information only. Always consult your GP, physiotherapist or pain specialist before making changes to your treatment.',style:GoogleFonts.dmSans(fontSize:12,color:_text2,height:1.4)))])),
    ]),
  );

  Widget _aCard(String t, String b, String e, Color c, Color bg) => Container(
    margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(14),
    decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(14),border:Border.all(color:c.withOpacity(0.2))),
    child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e,style:const TextStyle(fontSize:22)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:GoogleFonts.dmSans(fontSize:14,fontWeight:FontWeight.w600,color:_text)),const SizedBox(height:4),Text(b,style:GoogleFonts.dmSans(fontSize:12,color:_text2,height:1.4))]))]),
  );
}

// ─── Comparison Screen ───────────────────────────────────────────────────────

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});
  static const _features=[('Pain tracking',true,true,true,true),('Body diagram',false,true,true,true),('AI insights',true,false,false,true),('Planner',false,false,false,true),('Diary/Journal',true,false,false,true),('Doctor export',true,true,false,true),('Free to use',true,false,true,true),('Local/private',false,false,false,true),('Streak tracker',true,false,false,true),('Advice hub',false,false,true,true)];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor:_bg,
    appBar:AppBar(backgroundColor:_bg,title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Comparison',style:GoogleFonts.dmSans(fontWeight:FontWeight.w700,fontSize:22,color:_purple)),Text('How Nova stacks up',style:GoogleFonts.dmSans(fontSize:12,color:_text2))]),toolbarHeight:64),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      Container(decoration:BoxDecoration(gradient:const LinearGradient(colors:[_purple,_purpleDark],begin:Alignment.topLeft,end:Alignment.bottomRight),borderRadius:BorderRadius.circular(20)),padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Nova vs the competition',style:GoogleFonts.dmSans(color:Colors.white,fontSize:18,fontWeight:FontWeight.w700)),const SizedBox(height:6),Text('Bearable · Manage My Pain · PainScale',style:GoogleFonts.dmSans(color:Colors.white60,fontSize:13))])),
      const SizedBox(height:20),
      Container(decoration:BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:_border)),padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Feature comparison',style:GoogleFonts.dmSans(fontSize:16,fontWeight:FontWeight.w600,color:_text)),const SizedBox(height:16),Padding(padding:const EdgeInsets.only(bottom:8),child:Row(children:[const Expanded(flex:3,child:SizedBox()),Expanded(child:Text('Bear.',style:GoogleFonts.dmSans(fontSize:10,fontWeight:FontWeight.w700,color:_purple),textAlign:TextAlign.center)),Expanded(child:Text('MMP',style:GoogleFonts.dmSans(fontSize:10,fontWeight:FontWeight.w700,color:_teal),textAlign:TextAlign.center)),Expanded(child:Text('Pain.',style:GoogleFonts.dmSans(fontSize:10,fontWeight:FontWeight.w700,color:_amber),textAlign:TextAlign.center)),Expanded(child:Text('Nova',style:GoogleFonts.dmSans(fontSize:10,fontWeight:FontWeight.w700,color:_coral),textAlign:TextAlign.center))])),
      ..._features.map((f)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(children:[Expanded(flex:3,child:Text(f.$1,style:GoogleFonts.dmSans(fontSize:12,color:_text))),_tick(f.$2,_purple),_tick(f.$3,_teal),_tick(f.$4,_amber),_tick(f.$5,_coral)])))
      ])),
      const SizedBox(height:16),
      _appCard('Nova','🚀 Yours','All features in one app — body diagram, planner, diary, AI insights, export, advice hub. Private, local, free.',_coral),
      const SizedBox(height:10),
      _appCard('Bearable','⭐ 4.7','Best customisation and insights. Backed by clinicians. No body diagram or planner. Premium £35/year.',_purple),
      const SizedBox(height:10),
      _appCard('Manage My Pain','⭐ 4.2','Strong body diagram and doctor reports. Interface feels dated. No diary or planner.',_teal),
      const SizedBox(height:10),
      _appCard('PainScale','⭐ 4.4','Clean modern UI. Good education. Limited export. No diary.',_amber),
    ]),
  );

  Widget _tick(bool v, Color c) => Expanded(child:Icon(v?Icons.check_circle:Icons.cancel_outlined,color:v?c:_text3,size:18));

  Widget _appCard(String name, String rating, String desc, Color c) => Container(
    decoration:BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(16),border:Border.all(color:_border)),
    padding:const EdgeInsets.all(16),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(name,style:GoogleFonts.dmSans(fontSize:16,fontWeight:FontWeight.w700,color:_text)),Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),decoration:BoxDecoration(color:c.withOpacity(0.15),borderRadius:BorderRadius.circular(10)),child:Text(rating,style:GoogleFonts.dmSans(fontSize:12,fontWeight:FontWeight.w600,color:c)))]),const SizedBox(height:8),Text(desc,style:GoogleFonts.dmSans(fontSize:12,color:_text2,height:1.4))]),
  );
}

// ─── History ─────────────────────────────────────────────────────────────────

class HistoryScreen extends StatefulWidget {
  final CheckInRepository repo; final VoidCallback onChanged;
  const HistoryScreen({super.key,required this.repo,required this.onChanged});
  @override State<HistoryScreen> createState() => _HistoryState();
}

class _HistoryState extends State<HistoryScreen> {
  String _f='All';
  static const _filters=['All','High pain','Low pain','With symptoms','With notes'];
  List<CheckInEntry> _apply(List<CheckInEntry> l){switch(_f){case'High pain':return l.where((e)=>e.pain>=7).toList();case'Low pain':return l.where((e)=>e.pain<=3).toList();case'With symptoms':return l.where((e)=>e.symptoms.isNotEmpty).toList();case'With notes':return l.where((e)=>e.notes.isNotEmpty).toList();default:return l;}}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CheckInEntry>>(
      future: widget.repo.load(),
      builder: (ctx, snap) {
        if(!snap.hasData) return const Scaffold(backgroundColor:_bg,body:Center(child:CircularProgressIndicator(color:_purple)));
        final all=snap.data!; final list=_apply(all);
        return Scaffold(
          backgroundColor:_bg,
          appBar:AppBar(backgroundColor:_bg,title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('History',style:GoogleFonts.dmSans(fontWeight:FontWeight.w700,fontSize:22,color:_purple)),Text('${all.length} entries',style:GoogleFonts.dmSans(fontSize:12,color:_text2))]),toolbarHeight:64,actions:[if(all.isNotEmpty)IconButton(onPressed:()async{final ok=await showDialog<bool>(context:ctx,builder:(_)=>AlertDialog(backgroundColor:_bg2,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),title:Text('Clear all?',style:GoogleFonts.dmSans(fontWeight:FontWeight.w700,color:_text)),content:Text('Permanently deletes all history.',style:GoogleFonts.dmSans(color:_text2)),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:Text('Cancel',style:GoogleFonts.dmSans(color:_text2))),TextButton(onPressed:()=>Navigator.pop(ctx,true),style:TextButton.styleFrom(foregroundColor:_coral),child:Text('Delete',style:GoogleFonts.dmSans()))]));if(ok==true){await widget.repo.clear();widget.onChanged();if(mounted)setState((){});}},icon:const Icon(Icons.delete_sweep_outlined))]),
          body:Column(children:[
            SizedBox(height:52,child:ListView(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),children:_filters.map((f){final sel=_f==f;return GestureDetector(onTap:()=>setState(()=>_f=f),child:Container(margin:const EdgeInsets.only(right:8),padding:const EdgeInsets.symmetric(horizontal:14,vertical:6),decoration:BoxDecoration(color:sel?_purple:_surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:sel?_purple:_border,width:1.5)),child:Text(f,style:GoogleFonts.dmSans(fontSize:13,color:sel?Colors.white:_text2,fontWeight:sel?FontWeight.w600:FontWeight.normal))));}).toList())),
            Expanded(child:list.isEmpty?_darkEmpty('No entries found','Try a different filter'):ListView.builder(padding:const EdgeInsets.fromLTRB(16,0,16,24),itemCount:list.length,itemBuilder:(_,i){final e=list[i];final pc=e.pain<=3?_teal:e.pain<=6?_amber:_coral;return Container(margin:const EdgeInsets.only(bottom:10),decoration:BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(16),border:Border.all(color:_border)),child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:8),onTap:()=>_detail(ctx,e),title:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(_fmtDate(e.date),style:GoogleFonts.dmSans(fontSize:13,color:_text2)),Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),decoration:BoxDecoration(color:pc.withOpacity(0.15),borderRadius:BorderRadius.circular(10)),child:Text('Pain ${e.pain}',style:GoogleFonts.dmSans(fontSize:12,fontWeight:FontWeight.w600,color:pc)))]),subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:6),Row(children:[Text('⚡ ${e.energy}',style:GoogleFonts.dmSans(fontSize:12,color:_text2)),const SizedBox(width:8),Text('💧 ${e.water}gl',style:GoogleFonts.dmSans(fontSize:12,color:_text2)),const SizedBox(width:8),Text('😴 ${e.sleep.toStringAsFixed(1)}h',style:GoogleFonts.dmSans(fontSize:12,color:_text2))]),const SizedBox(height:4),Text(e.mood+(e.tookMedication?' · Meds':''),style:GoogleFonts.dmSans(fontSize:12,color:_text2)),if(e.symptoms.isNotEmpty)...[const SizedBox(height:4),Wrap(spacing:4,runSpacing:4,children:e.symptoms.map((s)=>Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:2),decoration:BoxDecoration(color:_surfaceGlow,borderRadius:BorderRadius.circular(8)),child:Text(s,style:GoogleFonts.dmSans(fontSize:11,color:_text2)))).toList())]])));})),
          ]),
        );
      },
    );
  }

  void _detail(BuildContext ctx, CheckInEntry e) {
    showModalBottomSheet<void>(context:ctx,isScrollControlled:true,showDragHandle:true,backgroundColor:_bg2,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),builder:(_)=>DraggableScrollableSheet(expand:false,initialChildSize:0.75,builder:(_,ctrl)=>ListView(controller:ctrl,padding:const EdgeInsets.fromLTRB(24,0,24,32),children:[Text(_fmtDateFull(e.date),style:GoogleFonts.dmSans(fontSize:20,fontWeight:FontWeight.w700,color:_text)),const SizedBox(height:16),...[['Pain','${e.pain}/10'],['Energy','${e.energy}/10'],['Mood',e.mood],['Symptoms',e.symptoms.isEmpty?'None':e.symptoms.join(', ')],['Locations',e.painLocations.isEmpty?'None':e.painLocations.join(', ')],['Water','${e.water} glasses'],['Sleep','${e.sleep.toStringAsFixed(1)} hours'],['Steps',e.steps.toString()],['Medication',e.tookMedication?(e.medicationName.isEmpty?'Taken':e.medicationName):'None'],['Notes',e.notes.isEmpty?'None':e.notes]].map((r)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:100,child:Text(r[0],style:GoogleFonts.dmSans(color:_text2,fontSize:14))),Expanded(child:Text(r[1],style:GoogleFonts.dmSans(fontWeight:FontWeight.w500,fontSize:14,color:_text)))]))),const SizedBox(height:12),OutlinedButton(onPressed:()async{await widget.repo.deleteById(e.id);widget.onChanged();if(mounted){Navigator.pop(ctx);setState((){});}},style:OutlinedButton.styleFrom(foregroundColor:_coral,side:const BorderSide(color:_coral),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),minimumSize:const Size.fromHeight(48)),child:Text('Delete entry',style:GoogleFonts.dmSans()))])));
  }
}

// ─── Export ──────────────────────────────────────────────────────────────────

class ExportScreen extends StatefulWidget {
  final CheckInRepository repo;
  const ExportScreen({super.key,required this.repo});
  @override State<ExportScreen> createState() => _ExportState();
}

class _ExportState extends State<ExportScreen> {
  String _name='', _range='All time'; bool _exp=false;
  static const _ranges=['Last 7 days','Last 30 days','Last 90 days','All time'];
  List<CheckInEntry> _filter(List<CheckInEntry> d){final now=DateTime.now();switch(_range){case'Last 7 days':return d.where((e)=>now.difference(e.date).inDays<=7).toList();case'Last 30 days':return d.where((e)=>now.difference(e.date).inDays<=30).toList();case'Last 90 days':return d.where((e)=>now.difference(e.date).inDays<=90).toList();default:return d;}}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CheckInEntry>>(
      future: widget.repo.load(),
      builder: (ctx, snap) {
        if(!snap.hasData) return const Scaffold(backgroundColor:_bg,body:Center(child:CircularProgressIndicator(color:_purple)));
        final filtered=_filter(snap.data!);
        final avgPain=filtered.isEmpty?'—':(filtered.fold(0,(a,b)=>a+b.pain)/filtered.length).toStringAsFixed(1);
        return Scaffold(
          backgroundColor:_bg,
          appBar:AppBar(backgroundColor:_bg,title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Export',style:GoogleFonts.dmSans(fontWeight:FontWeight.w700,fontSize:22,color:_purple)),Text('Doctor reports & data',style:GoogleFonts.dmSans(fontSize:12,color:_text2))]),toolbarHeight:64),
          body:ListView(padding:const EdgeInsets.all(16),children:[
            Container(decoration:BoxDecoration(gradient:const LinearGradient(colors:[_purple,_purpleDark],begin:Alignment.topLeft,end:Alignment.bottomRight),borderRadius:BorderRadius.circular(20)),padding:const EdgeInsets.all(20),child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[_ps('${filtered.length}','Entries'),_ps(avgPain,'Avg Pain'),_ps('${filtered.where((e)=>e.tookMedication).length}','Med Days')])),
            const SizedBox(height:20),
            _dc(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Patient name',style:GoogleFonts.dmSans(fontSize:15,fontWeight:FontWeight.w600,color:_text)),const SizedBox(height:8),TextField(onChanged:(v)=>setState(()=>_name=v),style:GoogleFonts.dmSans(color:_text),decoration:const InputDecoration(hintText:'Your name (optional)'))])),
            const SizedBox(height:12),
            _dc(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Date range',style:GoogleFonts.dmSans(fontSize:15,fontWeight:FontWeight.w600,color:_text)),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:_ranges.map((r){final sel=_range==r;return GestureDetector(onTap:()=>setState(()=>_range=r),child:AnimatedContainer(duration:const Duration(milliseconds:150),padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),decoration:BoxDecoration(color:sel?_purple:_surfaceGlow,borderRadius:BorderRadius.circular(20),border:Border.all(color:sel?_purple:_border,width:1.5)),child:Text(r,style:GoogleFonts.dmSans(fontSize:13,color:sel?Colors.white:_text2,fontWeight:sel?FontWeight.w600:FontWeight.normal))));}).toList())])),
            const SizedBox(height:20),
            _eb(Icons.table_chart_outlined,_teal,'Export CSV','Copy to clipboard — paste into Excel',()async{setState(()=>_exp=true);await Clipboard.setData(ClipboardData(text:ExportService.generateCsv(filtered)));setState(()=>_exp=false);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('CSV copied! Paste into Excel or Google Sheets.')));}),
            const SizedBox(height:12),
            _eb(Icons.picture_as_pdf_outlined,_coral,'Export PDF Report','Copy HTML — paste & print to PDF',()async{setState(()=>_exp=true);await Clipboard.setData(ClipboardData(text:ExportService.generateHtmlReport(filtered,_name.isEmpty?'Patient':_name)));setState(()=>_exp=false);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('HTML copied! Save as .html, open in browser, print to PDF.')));}),
          ]),
        );
      },
    );
  }

  Widget _ps(String v, String l) => Column(children:[Text(v,style:GoogleFonts.dmSans(color:Colors.white,fontSize:24,fontWeight:FontWeight.w700)),Text(l,style:GoogleFonts.dmSans(color:Colors.white60,fontSize:12))]);
  Widget _dc(Widget child) => Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:_border)),child:child);
  Widget _eb(IconData icon,Color c,String t,String s,VoidCallback onTap) => _dc(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:c.withOpacity(0.15),borderRadius:BorderRadius.circular(12)),child:Icon(icon,color:c)),const SizedBox(width:12),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:GoogleFonts.dmSans(fontSize:15,fontWeight:FontWeight.w600,color:_text)),Text(s,style:GoogleFonts.dmSans(fontSize:12,color:_text2))])]),const SizedBox(height:12),SizedBox(width:double.infinity,child:ElevatedButton(onPressed:_exp?null:onTap,style:ElevatedButton.styleFrom(backgroundColor:c,foregroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),elevation:0),child:_exp?const SizedBox(width:18,height:18,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)):Text(t,style:GoogleFonts.dmSans(fontWeight:FontWeight.w600))))]));
}

// ─── Notifications ───────────────────────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override State<NotificationsScreen> createState() => _NotifState();
}

class _NotifState extends State<NotificationsScreen> {
  bool _daily=false,_pain=false,_med=false,_weekly=false;
  TimeOfDay _dt=const TimeOfDay(hour:20,minute:0), _mt=const TimeOfDay(hour:8,minute:0);
  int _threshold=8;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    setState((){_daily=p.getBool('nd')??false;_pain=p.getBool('np')??false;_med=p.getBool('nm')??false;_weekly=p.getBool('nw')??false;_dt=TimeOfDay(hour:p.getInt('ndh')??20,minute:p.getInt('ndm')??0);_mt=TimeOfDay(hour:p.getInt('nmh')??8,minute:p.getInt('nmm')??0);_threshold=p.getInt('nt')??8;});
  }
  Future<void> _save() async {
    final p=await SharedPreferences.getInstance();
    await p.setBool('nd',_daily);await p.setBool('np',_pain);await p.setBool('nm',_med);await p.setBool('nw',_weekly);await p.setInt('ndh',_dt.hour);await p.setInt('ndm',_dt.minute);await p.setInt('nmh',_mt.hour);await p.setInt('nmm',_mt.minute);await p.setInt('nt',_threshold);
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Notification settings saved!')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor:_bg,
    appBar:AppBar(backgroundColor:_bg,title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Notifications',style:GoogleFonts.dmSans(fontWeight:FontWeight.w700,fontSize:22,color:_purple)),Text('Reminders & alerts',style:GoogleFonts.dmSans(fontSize:12,color:_text2))]),toolbarHeight:64),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      _nc(Icons.alarm_outlined,_purple,'Daily check-in','Reminds you to log each day',_daily,(v){setState(()=>_daily=v);_save();},_daily?GestureDetector(onTap:()async{final t=await showTimePicker(context:context,initialTime:_dt);if(t!=null){setState(()=>_dt=t);_save();}},child:_tp(_dt.format(context))):null),
      const SizedBox(height:12),
      _nc(Icons.medication_outlined,_teal,'Medication reminder','Alert when it\'s time for medication',_med,(v){setState(()=>_med=v);_save();},_med?GestureDetector(onTap:()async{final t=await showTimePicker(context:context,initialTime:_mt);if(t!=null){setState(()=>_mt=t);_save();}},child:_tp(_mt.format(context))):null),
      const SizedBox(height:12),
      _nc(Icons.warning_amber_outlined,_coral,'High pain alert','Notify when pain reaches your threshold',_pain,(v){setState(()=>_pain=v);_save();},_pain?Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Threshold: $_threshold/10',style:GoogleFonts.dmSans(fontSize:13,color:_text2)),SliderTheme(data:SliderTheme.of(context).copyWith(activeTrackColor:_coral,thumbColor:_coral),child:Slider(value:_threshold.toDouble(),min:5,max:10,divisions:5,onChanged:(v){setState(()=>_threshold=v.round());_save();}))]):null),
      const SizedBox(height:12),
      _nc(Icons.bar_chart_outlined,_amber,'Weekly summary','Sunday evening summary of your week',_weekly,(v){setState(()=>_weekly=v);_save();},null),
      const SizedBox(height:20),
      Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:_purpleGlow,borderRadius:BorderRadius.circular(14),border:Border.all(color:_purple.withOpacity(0.2))),child:Row(children:[const Text('📱',style:TextStyle(fontSize:16)),const SizedBox(width:10),Expanded(child:Text('Push notifications activate when you install Nova on your phone.',style:GoogleFonts.dmSans(fontSize:12,color:_text,height:1.4)))])),
    ]),
  );

  Widget _tp(String t) => Container(margin:const EdgeInsets.only(top:8),padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),decoration:BoxDecoration(color:_purpleGlow,borderRadius:BorderRadius.circular(12)),child:Row(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.access_time,size:14,color:_purple),const SizedBox(width:6),Text(t,style:GoogleFonts.dmSans(fontSize:13,fontWeight:FontWeight.w600,color:_purple)),const SizedBox(width:4),const Icon(Icons.edit,size:12,color:_purple)]));
  Widget _nc(IconData icon,Color c,String t,String s,bool v,ValueChanged<bool> onChange,Widget? extra) => Container(decoration:BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:_border)),padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:c.withOpacity(0.15),borderRadius:BorderRadius.circular(10)),child:Icon(icon,color:c,size:20)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:GoogleFonts.dmSans(fontSize:14,fontWeight:FontWeight.w600,color:_text)),Text(s,style:GoogleFonts.dmSans(fontSize:12,color:_text2))])),Switch(value:v,onChanged:onChange)]),if(extra!=null&&v)...[const Divider(height:20,color:_border),extra]]));
}

// ─── Settings ────────────────────────────────────────────────────────────────

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor:_bg,
    appBar:AppBar(backgroundColor:_bg,title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Settings',style:GoogleFonts.dmSans(fontWeight:FontWeight.w700,fontSize:22,color:_purple)),Text('App preferences',style:GoogleFonts.dmSans(fontSize:12,color:_text2))]),toolbarHeight:64),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      Container(decoration:BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:_border)),child:Column(children:[_st('Nova version','3.1.0 — Dark Edition',Icons.info_outline),const Divider(height:1,color:_border,indent:56),_st('Built with','Flutter + Google Fonts',Icons.flutter_dash),const Divider(height:1,color:_border,indent:56),_st('Data storage','Local only — 100% private',Icons.lock_outline),const Divider(height:1,color:_border,indent:56),_st('Compared to','Bearable, Manage My Pain, PainScale',Icons.compare_arrows_outlined)])),
      const SizedBox(height:16),
      Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:_tealGlow,borderRadius:BorderRadius.circular(14),border:Border.all(color:_teal.withOpacity(0.2))),child:Row(children:[const Text('🔒',style:TextStyle(fontSize:16)),const SizedBox(width:10),Expanded(child:Text('All your data stays on your device. Nova never sends anything to any server.',style:GoogleFonts.dmSans(fontSize:12,color:_teal,height:1.4)))])),
    ]),
  );
  Widget _st(String t,String s,IconData i) => ListTile(leading:Icon(i,color:_purple,size:22),title:Text(t,style:GoogleFonts.dmSans(fontSize:14,fontWeight:FontWeight.w500,color:_text)),subtitle:Text(s,style:GoogleFonts.dmSans(fontSize:12,color:_text2)));
}

// ─── Body Diagram ─────────────────────────────────────────────────────────────

class BodyDiagramPainter extends CustomPainter {
  final Set<String> selected; final bool dark;
  BodyDiagramPainter(this.selected, {this.dark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final sw=size.width; final sh=size.height; final cx=sw/2;
    final skin=Paint()..color=dark?const Color(0xFF2A2840):const Color(0xFFFDE8D8);
    final outline=Paint()..color=dark?const Color(0xFF5A5880):const Color(0xFFD4A888)..style=PaintingStyle.stroke..strokeWidth=1.5;
    final selP=Paint()..color=_coral.withOpacity(0.4);
    final sp=Paint()..color=dark?const Color(0xFF6C63FF):const Color(0xFF9E9EFF)..strokeWidth=2.5..style=PaintingStyle.stroke;
    final disc=Paint()..color=dark?const Color(0xFF4B44CC):const Color(0xFF6C63FF);
    final dmg=Paint()..color=_coral;

    canvas.drawOval(Rect.fromCenter(center:Offset(cx,sh*0.07),width:sw*0.22,height:sh*0.1),skin);
    canvas.drawOval(Rect.fromCenter(center:Offset(cx,sh*0.07),width:sw*0.22,height:sh*0.1),outline);
    canvas.drawRect(Rect.fromLTWH(cx-sw*0.06,sh*0.12,sw*0.12,sh*0.05),skin);
    canvas.drawRect(Rect.fromLTWH(cx-sw*0.06,sh*0.12,sw*0.12,sh*0.05),outline);
    final tp=Path()..moveTo(cx-sw*0.25,sh*0.17)..lineTo(cx+sw*0.25,sh*0.17)..lineTo(cx+sw*0.2,sh*0.55)..lineTo(cx-sw*0.2,sh*0.55)..close();
    canvas.drawPath(tp,skin); canvas.drawPath(tp,outline);
    if(selected.contains('Upper back')||selected.contains('Thoracic')) canvas.drawRect(Rect.fromLTWH(cx-sw*0.18,sh*0.17,sw*0.36,sh*0.17),selP);
    if(selected.contains('Lower back')||selected.contains('Lumbar')) canvas.drawRect(Rect.fromLTWH(cx-sw*0.16,sh*0.34,sw*0.32,sh*0.14),selP);
    if(selected.contains('Sacrum')) canvas.drawOval(Rect.fromCenter(center:Offset(cx,sh*0.54),width:sw*0.2,height:sh*0.06),selP);
    if(selected.contains('Neck')) canvas.drawRect(Rect.fromLTWH(cx-sw*0.08,sh*0.11,sw*0.16,sh*0.07),selP);
    if(selected.contains('Left shoulder')) canvas.drawOval(Rect.fromCenter(center:Offset(cx-sw*0.28,sh*0.2),width:sw*0.14,height:sh*0.08),selP);
    if(selected.contains('Right shoulder')) canvas.drawOval(Rect.fromCenter(center:Offset(cx+sw*0.28,sh*0.2),width:sw*0.14,height:sh*0.08),selP);
    canvas.drawLine(Offset(cx,sh*0.13),Offset(cx,sh*0.54),sp);
    for(int i=0;i<12;i++){
      final y=sh*0.13+(sh*0.54-sh*0.13)*(i/11);
      canvas.drawRect(Rect.fromCenter(center:Offset(cx,y),width:sw*0.1,height:sh*0.022),Paint()..color=dark?const Color(0xFF3D3A6E):const Color(0xFFB8C8FF));
      if(i<11){final dy=sh*0.13+(sh*0.54-sh*0.13)*((i+0.5)/11);canvas.drawOval(Rect.fromCenter(center:Offset(cx,dy),width:sw*0.08,height:sh*0.014),(i==5||i==7)?dmg:disc);}
    }
    final pelvis=Path()..moveTo(cx-sw*0.2,sh*0.55)..quadraticBezierTo(cx-sw*0.25,sh*0.62,cx-sw*0.15,sh*0.64)..lineTo(cx+sw*0.15,sh*0.64)..quadraticBezierTo(cx+sw*0.25,sh*0.62,cx+sw*0.2,sh*0.55)..close();
    canvas.drawPath(pelvis,Paint()..color=dark?const Color(0xFF2D2A5E):const Color(0xFFD0C0FF));
    canvas.drawPath(pelvis,Paint()..color=dark?const Color(0xFF6C63FF):const Color(0xFF9980FF)..style=PaintingStyle.stroke..strokeWidth=1.5);
    if(selected.contains('Left hip')) canvas.drawOval(Rect.fromCenter(center:Offset(cx-sw*0.18,sh*0.64),width:sw*0.14,height:sh*0.07),selP);
    if(selected.contains('Right hip')) canvas.drawOval(Rect.fromCenter(center:Offset(cx+sw*0.18,sh*0.64),width:sw*0.14,height:sh*0.07),selP);
  }

  @override bool shouldRepaint(BodyDiagramPainter o) => o.selected!=selected;
}

// ─── Custom Painters ─────────────────────────────────────────────────────────

class DarkRingPainter extends CustomPainter {
  final double progress; final Color color;
  DarkRingPainter(this.progress, this.color);
  @override
  void paint(Canvas c, Size s) {
    final r=(s.width-10)/2;
    final rect=Rect.fromCircle(center:Offset(s.width/2,s.height/2),radius:r);
    c.drawArc(rect,0,math.pi*2,false,Paint()..color=_surfaceGlow..style=PaintingStyle.stroke..strokeWidth=7);
    c.drawArc(rect,-math.pi/2,math.pi*2*progress,false,Paint()..color=color..style=PaintingStyle.stroke..strokeWidth=7..strokeCap=StrokeCap.round);
  }
  @override bool shouldRepaint(DarkRingPainter o) => o.progress!=progress||o.color!=color;
}

class DarkTrendPainter extends CustomPainter {
  final List<CheckInEntry> items; final double Function(CheckInEntry) vb;
  DarkTrendPainter(this.items, this.vb);
  @override
  void paint(Canvas c, Size s) {
    if(items.length<2) return;
    const p=16.0; final w=s.width-p*2; final h=s.height-p*2;
    for(int i=1;i<4;i++){final y=p+h/4*i;c.drawLine(Offset(p,y),Offset(s.width-p,y),Paint()..color=_surfaceGlow..strokeWidth=1);}
    final pts=List.generate(items.length,(i){final x=p+(w/(items.length-1))*i;final v=vb(items[i]).clamp(0,10);final y=p+h-(v/10)*h;return Offset(x,y);});
    final area=Path()..moveTo(pts.first.dx,pts.first.dy);
    for(int i=1;i<pts.length;i++){final mx=(pts[i-1].dx+pts[i].dx)/2;area.cubicTo(mx,pts[i-1].dy,mx,pts[i].dy,pts[i].dx,pts[i].dy);}
    area..lineTo(pts.last.dx,s.height-p)..lineTo(pts.first.dx,s.height-p)..close();
    c.drawPath(area,Paint()..color=_purple.withOpacity(0.15));
    final line=Path()..moveTo(pts.first.dx,pts.first.dy);
    for(int i=1;i<pts.length;i++){final mx=(pts[i-1].dx+pts[i].dx)/2;line.cubicTo(mx,pts[i-1].dy,mx,pts[i].dy,pts[i].dx,pts[i].dy);}
    c.drawPath(line,Paint()..color=_purple..strokeWidth=2.5..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
    for(final pt in pts){c.drawCircle(pt,4,Paint()..color=_purple);c.drawCircle(pt,2.5,Paint()..color=_bg);}
  }
  @override bool shouldRepaint(DarkTrendPainter o) => true;
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _sectionTitle(String t) => Text(t, style: GoogleFonts.dmSans(fontSize:12,fontWeight:FontWeight.w600,color:_text2,letterSpacing:0.8));

Widget _darkEmpty(String t, String s) => Center(child:Padding(padding:const EdgeInsets.all(32),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.self_improvement_outlined,size:64,color:_text3),const SizedBox(height:16),Text(t,style:GoogleFonts.dmSans(fontSize:20,fontWeight:FontWeight.w600,color:_text),textAlign:TextAlign.center),const SizedBox(height:6),Text(s,style:GoogleFonts.dmSans(fontSize:14,color:_text2),textAlign:TextAlign.center)])));

String _greeting(){final h=DateTime.now().hour;return h<12?'Good morning':h<17?'Good afternoon':'Good evening';}

String _fmtDate(DateTime d){const wd=['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];const mo=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];return '${wd[d.weekday-1]} ${d.day} ${mo[d.month-1]}, ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';}

String _fmtDateFull(DateTime d){const wd=['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];const mo=['January','February','March','April','May','June','July','August','September','October','November','December'];return '${wd[d.weekday-1]}, ${d.day} ${mo[d.month-1]} ${d.year}';}
