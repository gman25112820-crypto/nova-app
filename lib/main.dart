diff --git a/docs/nova_app_v2_main.dart b/docs/nova_app_v2_main.dart
new file mode 100644
index 0000000000000000000000000000000000000000..95e3e1c3aa23975b4e9fe4e7d9761bd266da89e6
--- /dev/null
+++ b/docs/nova_app_v2_main.dart
@@ -0,0 +1,397 @@
+import 'dart:math' as math;
+import 'package:fl_chart/fl_chart.dart';
+import 'package:flutter/material.dart';
+import 'package:google_fonts/google_fonts.dart';
+import 'package:shared_preferences/shared_preferences.dart';
+
+void main() async {
+  WidgetsFlutterBinding.ensureInitialized();
+  runApp(const NovaApp());
+}
+
+class NovaApp extends StatelessWidget {
+  const NovaApp({super.key});
+
+  @override
+  Widget build(BuildContext context) {
+    final ColorScheme scheme = ColorScheme.fromSeed(
+      seedColor: const Color(0xFF6C63FF),
+      brightness: Brightness.dark,
+    );
+
+    return MaterialApp(
+      debugShowCheckedModeBanner: false,
+      title: 'Nova Pain Tracker',
+      theme: ThemeData(
+        colorScheme: scheme,
+        scaffoldBackgroundColor: const Color(0xFF0E1022),
+        useMaterial3: true,
+        textTheme: GoogleFonts.dmSansTextTheme(
+          ThemeData.dark().textTheme,
+        ),
+      ),
+      home: const HomeScreen(),
+    );
+  }
+}
+
+class HomeScreen extends StatefulWidget {
+  const HomeScreen({super.key});
+
+  @override
+  State<HomeScreen> createState() => _HomeScreenState();
+}
+
+class _HomeScreenState extends State<HomeScreen> {
+  final List<double> _scores = <double>[];
+  final TextEditingController _controller = TextEditingController();
+
+  @override
+  void initState() {
+    super.initState();
+    _loadScores();
+  }
+
+  @override
+  void dispose() {
+    _controller.dispose();
+    super.dispose();
+  }
+
+  Future<void> _loadScores() async {
+    final SharedPreferences prefs = await SharedPreferences.getInstance();
+    final List<String> raw = prefs.getStringList('pain_scores') ?? <String>[];
+
+    setState(() {
+      _scores
+        ..clear()
+        ..addAll(raw.map((String e) => double.tryParse(e) ?? 0));
+    });
+  }
+
+  Future<void> _saveScores() async {
+    final SharedPreferences prefs = await SharedPreferences.getInstance();
+    await prefs.setStringList(
+      'pain_scores',
+      _scores.map((double e) => e.toStringAsFixed(1)).toList(),
+    );
+  }
+
+  Future<void> _addScore() async {
+    final double? value = double.tryParse(_controller.text.trim());
+
+    if (value == null || value < 0 || value > 10) {
+      _snack('Enter a valid score from 0 to 10.');
+      return;
+    }
+
+    setState(() {
+      _scores.add(value);
+      if (_scores.length > 30) {
+        _scores.removeAt(0);
+      }
+    });
+
+    _controller.clear();
+    await _saveScores();
+  }
+
+  Future<void> _clearAll() async {
+    setState(() {
+      _scores.clear();
+    });
+
+    final SharedPreferences prefs = await SharedPreferences.getInstance();
+    await prefs.remove('pain_scores');
+    _snack('All pain scores cleared.');
+  }
+
+  void _snack(String message) {
+    ScaffoldMessenger.of(context).showSnackBar(
+      SnackBar(content: Text(message)),
+    );
+  }
+
+  double get _average {
+    if (_scores.isEmpty) {
+      return 0;
+    }
+    return _scores.reduce((double a, double b) => a + b) / _scores.length;
+  }
+
+  double get _latest {
+    if (_scores.isEmpty) {
+      return 0;
+    }
+    return _scores.last;
+  }
+
+  double get _trend {
+    if (_scores.length < 2) {
+      return 0;
+    }
+    return _scores.last - _scores[_scores.length - 2];
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    return Scaffold(
+      appBar: AppBar(
+        title: const Text('Nova Pain Tracker'),
+        centerTitle: true,
+      ),
+      body: SafeArea(
+        child: SingleChildScrollView(
+          padding: const EdgeInsets.all(16),
+          child: Column(
+            crossAxisAlignment: CrossAxisAlignment.start,
+            children: <Widget>[
+              _buildHeader(),
+              const SizedBox(height: 12),
+              _buildInputCard(),
+              const SizedBox(height: 12),
+              _buildStatsRow(),
+              const SizedBox(height: 12),
+              _buildChartCard(),
+              const SizedBox(height: 12),
+              _buildRecentList(),
+            ],
+          ),
+        ),
+      ),
+    );
+  }
+
+  Widget _buildHeader() {
+    return Container(
+      width: double.infinity,
+      padding: const EdgeInsets.all(16),
+      decoration: BoxDecoration(
+        borderRadius: BorderRadius.circular(20),
+        gradient: const LinearGradient(
+          colors: <Color>[Color(0xFF6C63FF), Color(0xFF00C9A7)],
+          begin: Alignment.topLeft,
+          end: Alignment.bottomRight,
+        ),
+      ),
+      child: const Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: <Widget>[
+          Text(
+            'Daily Pain Overview',
+            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
+          ),
+          SizedBox(height: 6),
+          Text('Track, trend, and review your pain score in one place.'),
+        ],
+      ),
+    );
+  }
+
+  Widget _buildInputCard() {
+    return Card(
+      elevation: 0,
+      color: const Color(0xFF171A32),
+      child: Padding(
+        padding: const EdgeInsets.all(14),
+        child: Row(
+          children: <Widget>[
+            Expanded(
+              child: TextField(
+                controller: _controller,
+                keyboardType: const TextInputType.numberWithOptions(decimal: true),
+                decoration: const InputDecoration(
+                  labelText: 'Pain score (0-10)',
+                  border: OutlineInputBorder(),
+                ),
+              ),
+            ),
+            const SizedBox(width: 10),
+            FilledButton(
+              onPressed: _addScore,
+              child: const Text('Add'),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildStatsRow() {
+    return Row(
+      children: <Widget>[
+        Expanded(child: _statCard('Latest', _latest.toStringAsFixed(1), Icons.bolt)),
+        const SizedBox(width: 10),
+        Expanded(child: _statCard('Average', _average.toStringAsFixed(1), Icons.show_chart)),
+        const SizedBox(width: 10),
+        Expanded(
+          child: _statCard(
+            'Trend',
+            _trend >= 0 ? '+${_trend.toStringAsFixed(1)}' : _trend.toStringAsFixed(1),
+            _trend > 0 ? Icons.trending_up : Icons.trending_down,
+          ),
+        ),
+      ],
+    );
+  }
+
+  Widget _statCard(String label, String value, IconData icon) {
+    return Container(
+      padding: const EdgeInsets.all(12),
+      decoration: BoxDecoration(
+        color: const Color(0xFF171A32),
+        borderRadius: BorderRadius.circular(16),
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: <Widget>[
+          Icon(icon, size: 18, color: const Color(0xFF9AA0FF)),
+          const SizedBox(height: 8),
+          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
+          const SizedBox(height: 2),
+          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
+        ],
+      ),
+    );
+  }
+
+  Widget _buildChartCard() {
+    if (_scores.isEmpty) {
+      return _emptyPanel('No chart data yet. Add your first score.');
+    }
+
+    final List<FlSpot> spots = <FlSpot>[
+      for (int i = 0; i < _scores.length; i++) FlSpot(i.toDouble(), _scores[i]),
+    ];
+
+    final double xInterval = math.max(1, (_scores.length / 6).floor()).toDouble();
+
+    return Container(
+      height: 280,
+      padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
+      decoration: BoxDecoration(
+        color: const Color(0xFF171A32),
+        borderRadius: BorderRadius.circular(18),
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: <Widget>[
+          const Text('Pain Trend', style: TextStyle(fontWeight: FontWeight.w700)),
+          const SizedBox(height: 12),
+          Expanded(
+            child: LineChart(
+              LineChartData(
+                minY: 0,
+                maxY: 10,
+                gridData: FlGridData(
+                  show: true,
+                  horizontalInterval: 2,
+                  getDrawingHorizontalLine: (double value) {
+                    return FlLine(
+                      color: Colors.white10,
+                      strokeWidth: 1,
+                    );
+                  },
+                ),
+                borderData: FlBorderData(show: false),
+                titlesData: FlTitlesData(
+                  leftTitles: AxisTitles(
+                    sideTitles: SideTitles(
+                      showTitles: true,
+                      reservedSize: 28,
+                      interval: 2,
+                      getTitlesWidget: (double value, TitleMeta meta) {
+                        return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
+                      },
+                    ),
+                  ),
+                  bottomTitles: AxisTitles(
+                    sideTitles: SideTitles(
+                      showTitles: true,
+                      interval: xInterval,
+                      getTitlesWidget: (double value, TitleMeta meta) {
+                        return Text('${value.toInt() + 1}', style: const TextStyle(fontSize: 10));
+                      },
+                    ),
+                  ),
+                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
+                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
+                ),
+                lineBarsData: <LineChartBarData>[
+                  LineChartBarData(
+                    spots: spots,
+                    isCurved: true,
+                    barWidth: 3,
+                    color: const Color(0xFF00C9A7),
+                    dotData: const FlDotData(show: true),
+                    belowBarData: BarAreaData(
+                      show: true,
+                      color: const Color(0xFF00C9A7).withOpacity(0.15),
+                    ),
+                  ),
+                ],
+              ),
+            ),
+          ),
+        ],
+      ),
+    );
+  }
+
+  Widget _buildRecentList() {
+    if (_scores.isEmpty) {
+      return _emptyPanel('No entries yet.');
+    }
+
+    final List<double> recent = _scores.reversed.take(8).toList();
+
+    return Container(
+      width: double.infinity,
+      padding: const EdgeInsets.all(14),
+      decoration: BoxDecoration(
+        color: const Color(0xFF171A32),
+        borderRadius: BorderRadius.circular(18),
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: <Widget>[
+          Row(
+            mainAxisAlignment: MainAxisAlignment.spaceBetween,
+            children: <Widget>[
+              const Text('Recent entries', style: TextStyle(fontWeight: FontWeight.w700)),
+              TextButton(
+                onPressed: _scores.isEmpty ? null : _clearAll,
+                child: const Text('Clear all'),
+              ),
+            ],
+          ),
+          const SizedBox(height: 6),
+          for (int i = 0; i < recent.length; i++)
+            ListTile(
+              dense: true,
+              contentPadding: EdgeInsets.zero,
+              leading: CircleAvatar(
+                radius: 14,
+                backgroundColor: const Color(0xFF2D315C),
+                child: Text('${i + 1}', style: const TextStyle(fontSize: 11)),
+              ),
+              title: Text('Pain score ${recent[i].toStringAsFixed(1)}'),
+              subtitle: const Text('Saved locally on this device'),
+            ),
+        ],
+      ),
+    );
+  }
+
+  Widget _emptyPanel(String text) {
+    return Container(
+      width: double.infinity,
+      padding: const EdgeInsets.all(24),
+      decoration: BoxDecoration(
+        color: const Color(0xFF171A32),
+        borderRadius: BorderRadius.circular(18),
+      ),
+      child: Center(child: Text(text)),
+    );
+  }
+}
