import '../models/check_in_entry.dart';

/// Converts a list of [CheckInEntry] records into portable export formats.
/// All formatting is pure Dart — no external dependencies.
/// Output is a string the caller can write to a file, share, or print.
class ExportService {
  // ── CSV ─────────────────────────────────────────────────────────────────

  /// Returns a RFC-4180-compatible CSV string for [entries].
  /// Columns: Date, Pain Rating, Nerve Rating, Locations, Symptoms,
  ///          Triggers, Notes.
  /// List fields are joined with ' | ' so each entry occupies one row.
  String generateCsv(List<CheckInEntry> entries) {
    final StringBuffer buf = StringBuffer();

    buf.writeln(
      'Date,Pain Rating (0-10),Nerve Symptom Rating (0-10),'
      'Pain Locations,Symptoms,Triggers,Notes',
    );

    for (final CheckInEntry e in entries) {
      buf.writeln([
        _csvCell(_formatDate(e.date)),
        _csvCell(e.painRating.toString()),
        _csvCell(e.nerveSymptomRating.toString()),
        _csvCell(e.painLocations.join(' | ')),
        _csvCell(e.symptoms.join(' | ')),
        _csvCell(e.triggers.join(' | ')),
        _csvCell(e.notes),
      ].join(','));
    }

    return buf.toString();
  }

  // ── HTML report ─────────────────────────────────────────────────────────

  /// Returns a self-contained, print-ready HTML document for [entries].
  /// Includes a summary metrics block and a per-entry chronological table
  /// suitable for GP appointments, PIP evidence, or personal records.
  String generateHtmlReport(List<CheckInEntry> entries, String userName) {
    final int total = entries.length;
    final double avgPain = total == 0
        ? 0
        : entries.map((e) => e.painRating).reduce((a, b) => a + b) / total;
    final double avgNerve = total == 0
        ? 0
        : entries.map((e) => e.nerveSymptomRating).reduce((a, b) => a + b) /
            total;

    final String generatedOn = _formatDate(DateTime.now());
    final String safeUserName = _htmlEscape(userName);

    final StringBuffer buf = StringBuffer();

    buf.write('''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Nova Health — Pain Analytics Report</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    font-size: 13px;
    color: #1a1a2e;
    background: #f5f6fa;
    padding: 32px 24px;
  }
  .page { max-width: 860px; margin: 0 auto; background: #fff;
          border-radius: 10px; padding: 40px; box-shadow: 0 2px 12px rgba(0,0,0,.08); }

  /* Header */
  .header { border-bottom: 2px solid #4c6ef5; padding-bottom: 20px; margin-bottom: 28px; }
  .header h1 { font-size: 22px; font-weight: 700; color: #2d3a8c; }
  .header .subtitle { font-size: 13px; color: #6b7280; margin-top: 4px; }
  .header .meta { font-size: 12px; color: #9ca3af; margin-top: 8px; }

  /* Disclaimer */
  .disclaimer {
    background: #fffbeb; border: 1px solid #f59e0b;
    border-radius: 6px; padding: 10px 14px;
    font-size: 11.5px; color: #78350f; margin-bottom: 24px; line-height: 1.5;
  }

  /* Summary metrics */
  .summary { display: flex; gap: 16px; margin-bottom: 28px; flex-wrap: wrap; }
  .metric {
    flex: 1; min-width: 140px; background: #f0f2ff;
    border-radius: 8px; padding: 14px 18px;
    border-left: 4px solid #4c6ef5;
  }
  .metric .label { font-size: 11px; color: #6b7280; text-transform: uppercase;
                   letter-spacing: .6px; margin-bottom: 4px; }
  .metric .value { font-size: 26px; font-weight: 700; color: #2d3a8c; }
  .metric .unit  { font-size: 11px; color: #9ca3af; }

  /* Table */
  h2 { font-size: 14px; font-weight: 700; color: #2d3a8c;
       margin-bottom: 12px; padding-bottom: 6px; border-bottom: 1px solid #e5e7eb; }
  table { width: 100%; border-collapse: collapse; font-size: 12px; }
  thead tr { background: #f0f2ff; }
  th {
    text-align: left; padding: 9px 10px;
    font-size: 11px; font-weight: 600; color: #4c6ef5;
    text-transform: uppercase; letter-spacing: .5px;
    border-bottom: 2px solid #c7d2fe;
  }
  td { padding: 9px 10px; vertical-align: top; border-bottom: 1px solid #f3f4f6; }
  tr:last-child td { border-bottom: none; }
  tr:nth-child(even) td { background: #fafafa; }
  .pill {
    display: inline-block; background: #e0e7ff; color: #3730a3;
    border-radius: 12px; padding: 2px 8px;
    font-size: 11px; margin: 2px 2px 2px 0; white-space: nowrap;
  }
  .pill.trigger { background: #fff7ed; color: #9a3412; }
  .pill.symptom { background: #fdf2f8; color: #86198f; }
  .pain-high { color: #dc2626; font-weight: 700; }
  .pain-mid  { color: #d97706; font-weight: 600; }
  .pain-low  { color: #16a34a; font-weight: 600; }
  .notes-cell { max-width: 200px; line-height: 1.45; color: #374151; }
  .empty { text-align: center; padding: 32px; color: #9ca3af; font-style: italic; }

  /* Footer */
  .footer { margin-top: 32px; padding-top: 16px; border-top: 1px solid #e5e7eb;
            font-size: 11px; color: #9ca3af; line-height: 1.6; }

  @media print {
    body { background: #fff; padding: 0; }
    .page { box-shadow: none; padding: 20px; }
  }
</style>
</head>
<body>
<div class="page">

  <div class="header">
    <h1>Nova Health — Pain Analytics Report</h1>
    <div class="subtitle">Personal health record prepared by $safeUserName</div>
    <div class="meta">Generated: $generatedOn &nbsp;·&nbsp; Total entries: $total &nbsp;·&nbsp; Local device record only</div>
  </div>

  <div class="disclaimer">
    <strong>Personal record only.</strong> This document does not constitute a clinical report, prescription, or official medical evidence.
    It is a personal log prepared to support appointments, benefit applications, or support conversations.
    All data was entered by the record holder and stored locally on their device.
    Nothing has been transmitted to any external service.
  </div>

  <div class="summary">
    <div class="metric">
      <div class="label">Total entries</div>
      <div class="value">$total</div>
    </div>
    <div class="metric">
      <div class="label">Avg pain rating</div>
      <div class="value">${avgPain.toStringAsFixed(1)}</div>
      <div class="unit">out of 10</div>
    </div>
    <div class="metric">
      <div class="label">Avg nerve rating</div>
      <div class="value">${avgNerve.toStringAsFixed(1)}</div>
      <div class="unit">out of 10</div>
    </div>
  </div>

  <h2>Chronological Entry Log</h2>
''');

    if (entries.isEmpty) {
      buf.write('<p class="empty">No entries recorded yet.</p>\n');
    } else {
      buf.write('''  <table>
    <thead>
      <tr>
        <th>Date</th>
        <th>Pain</th>
        <th>Nerve</th>
        <th>Locations</th>
        <th>Symptoms</th>
        <th>Triggers</th>
        <th>Notes</th>
      </tr>
    </thead>
    <tbody>
''');

      for (final CheckInEntry e in entries) {
        final String painClass = e.painRating >= 7
            ? 'pain-high'
            : e.painRating >= 4
                ? 'pain-mid'
                : 'pain-low';
        final String nerveClass = e.nerveSymptomRating >= 7
            ? 'pain-high'
            : e.nerveSymptomRating >= 4
                ? 'pain-mid'
                : 'pain-low';

        final String locationPills = e.painLocations
            .map((l) => '<span class="pill">${_htmlEscape(l)}</span>')
            .join(' ');
        final String symptomPills = e.symptoms
            .map((s) => '<span class="pill symptom">${_htmlEscape(s)}</span>')
            .join(' ');
        final String triggerPills = e.triggers
            .map((t) => '<span class="pill trigger">${_htmlEscape(t)}</span>')
            .join(' ');

        buf.write('''      <tr>
        <td>${_htmlEscape(_formatDate(e.date))}</td>
        <td class="$painClass">${e.painRating}/10</td>
        <td class="$nerveClass">${e.nerveSymptomRating}/10</td>
        <td>${locationPills.isEmpty ? '—' : locationPills}</td>
        <td>${symptomPills.isEmpty ? '—' : symptomPills}</td>
        <td>${triggerPills.isEmpty ? '—' : triggerPills}</td>
        <td class="notes-cell">${_htmlEscape(e.notes).isEmpty ? '—' : _htmlEscape(e.notes)}</td>
      </tr>
''');
      }

      buf.write('    </tbody>\n  </table>\n');
    }

    buf.write('''
  <div class="footer">
    This record was generated by Nova Health on $generatedOn.
    Nova Health is a personal record tool. It does not diagnose, prescribe, or replace professional medical advice.
    All records are stored locally on the user's device. No accounts, cloud sync, or data sharing are enabled.
  </div>

</div>
</body>
</html>''');

    return buf.toString();
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  /// Wraps a cell value in quotes and escapes any internal quotes per RFC 4180.
  String _csvCell(String value) {
    final String escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  /// Formats a [DateTime] as YYYY-MM-DD.
  String _formatDate(DateTime dt) {
    final String y = dt.year.toString().padLeft(4, '0');
    final String m = dt.month.toString().padLeft(2, '0');
    final String d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Escapes the five XML/HTML special characters.
  String _htmlEscape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
