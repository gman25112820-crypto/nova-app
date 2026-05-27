import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
// NOVA ADVICE HUB
// Reads conditions from 'nova_health_profile' and surfaces
// relevant self-management advice cards. Bookmarks persist
// under 'nova_advice_bookmarks'. All content is general
// self-management information only — not medical advice.
// ─────────────────────────────────────────────────────────────

// ── Data model ────────────────────────────────────────────────

class _Advice {
  final String id;
  final String title;
  final String body;
  final String category;
  final Color  catColor;
  final IconData catIcon;
  /// Condition names (matching HealthProfileScreen presets) this
  /// card applies to. Use 'general' for cards shown to everyone.
  final List<String> conditions;

  const _Advice({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.catColor,
    required this.catIcon,
    required this.conditions,
  });
}

// ── Palette (module-level constants) ─────────────────────────

const _bg     = Color(0xFF0D1020);
const _panel  = Color(0xFF171A2E);
const _panel2 = Color(0xFF211C3A);
const _border = Color(0xFF252845);
const _text   = Color(0xFFF7F4FF);
const _muted  = Color(0xFFB9AECF);
const _blue   = Color(0xFF5DADEC);
const _purple = Color(0xFF8D6CFF);
const _teal   = Color(0xFF46D6C8);
const _amber  = Color(0xFFFFC857);
const _rose   = Color(0xFFFF6FAE);
const _green  = Color(0xFF7EC87A);

// ── Advice content library ────────────────────────────────────

const List<_Advice> _allAdvice = [

  // ── General (shown to everyone) ──────────────────────────

  _Advice(
    id: 'gen_01',
    title: 'Prepare for GP appointments',
    body: 'Write down your top 3 concerns before the appointment. '
        'Bring a list of current medications and note when symptoms started, '
        'how often they occur, and what makes them better or worse. '
        'You can ask the receptionist for a longer slot if needed.',
    category: 'Appointments',
    catColor: _blue,
    catIcon: Icons.calendar_today_rounded,
    conditions: ['general'],
  ),
  _Advice(
    id: 'gen_02',
    title: 'Keep an activity and symptom diary',
    body: 'Tracking symptoms alongside activity, sleep, food, and stress '
        'for even two weeks can reveal patterns that are hard to spot otherwise. '
        'Screenshots or printed summaries from this app can support discussions '
        'with your care team.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['general'],
  ),
  _Advice(
    id: 'gen_03',
    title: 'Know your rights in healthcare',
    body: 'You have the right to ask for a second opinion, request written '
        'information, bring someone with you to appointments, and ask for '
        'reasonable adjustments (e.g. written notes, longer appointments, '
        'ground-floor access). You can also ask your GP to refer you to a '
        'specialist if you feel your concerns aren\'t being addressed.',
    category: 'Advocacy',
    catColor: _purple,
    catIcon: Icons.shield_outlined,
    conditions: ['general'],
  ),
  _Advice(
    id: 'gen_04',
    title: 'Medication log basics',
    body: 'Record what you take, what dose, what time, and any effects — '
        'including side effects. Note what was prescribed for what. This helps '
        'at appointments, prevents dangerous interactions, and makes reviews '
        'more productive. Never stop prescribed medication without speaking '
        'to your prescriber.',
    category: 'Medications',
    catColor: _rose,
    catIcon: Icons.medication_rounded,
    conditions: ['general'],
  ),
  _Advice(
    id: 'gen_05',
    title: 'Boom-and-bust cycle',
    body: 'Many chronic conditions worsen when you push through on good days '
        'and then crash. Aim for consistent, sustainable activity rather than '
        'doing a lot when you feel well. Small steady steps tend to build '
        'capacity better than big efforts followed by flares.',
    category: 'Pacing',
    catColor: _amber,
    catIcon: Icons.speed_rounded,
    conditions: ['general'],
  ),
  _Advice(
    id: 'gen_06',
    title: 'Rest is not laziness',
    body: 'Planned rest is an active strategy, not giving up. Scheduling '
        'rest before you\'re exhausted — rather than waiting until you crash — '
        'helps protect your capacity and reduces recovery time. Rest can '
        'include sitting quietly, lying down, or any low-stimulation activity.',
    category: 'Pacing',
    catColor: _amber,
    catIcon: Icons.speed_rounded,
    conditions: ['general'],
  ),

  // ── Chronic back pain & Sciatica ─────────────────────────

  _Advice(
    id: 'back_01',
    title: 'Heat vs ice for back pain',
    body: 'Heat (warm pack, bath, heat pad) relaxes muscle tension and '
        'is often helpful for chronic back pain and stiffness. Ice is more '
        'useful for acute injuries or inflammation. Many people find alternating '
        'works well. Never apply directly to skin — use a cloth layer.',
    category: 'Pain management',
    catColor: _rose,
    catIcon: Icons.thermostat_rounded,
    conditions: ['Chronic back pain', 'Sciatica', 'Scoliosis'],
  ),
  _Advice(
    id: 'back_02',
    title: 'Gentle movement beats bed rest',
    body: 'Staying still for long periods often worsens chronic back pain. '
        'Short, gentle walks and careful movement tend to aid recovery better '
        'than rest alone. Swimming, walking in water, and yoga adapted for '
        'back pain are often recommended — ask your GP or physio what\'s '
        'appropriate for your situation.',
    category: 'Movement',
    catColor: _green,
    catIcon: Icons.directions_walk_rounded,
    conditions: ['Chronic back pain', 'Sciatica', 'Scoliosis'],
  ),
  _Advice(
    id: 'back_03',
    title: 'Sleep positions for back pain',
    body: 'Side-sleeping with a pillow between your knees keeps the spine '
        'aligned and reduces pressure. If you sleep on your back, a pillow '
        'under your knees can help. Avoid sleeping on your front if possible — '
        'it increases lumbar pressure. A medium-firm mattress is often '
        'recommended but individual needs vary.',
    category: 'Sleep',
    catColor: _purple,
    catIcon: Icons.bedtime_rounded,
    conditions: ['Chronic back pain', 'Sciatica'],
  ),
  _Advice(
    id: 'back_04',
    title: 'Sciatica flare: what helps',
    body: 'During a sciatica flare, gentle movement is usually better than '
        'complete rest. Avoid sitting for long periods — set a timer to stand '
        'or walk briefly every 20–30 minutes. Ice or heat on the lower back '
        'or buttock area may give temporary relief. If numbness, weakness, '
        'or bladder/bowel changes occur, seek urgent medical review.',
    category: 'Pain management',
    catColor: _rose,
    catIcon: Icons.thermostat_rounded,
    conditions: ['Sciatica'],
  ),
  _Advice(
    id: 'back_05',
    title: 'Workplace adjustments for back pain',
    body: 'You can request reasonable adjustments from your employer under '
        'the Equality Act 2010 if your back pain qualifies as a disability. '
        'These might include a standing desk, ergonomic chair, flexible hours, '
        'working from home, or adjusting your duties. Your GP can provide a '
        'fit note with recommendations.',
    category: 'Advocacy',
    catColor: _purple,
    catIcon: Icons.shield_outlined,
    conditions: ['Chronic back pain', 'Sciatica', 'Scoliosis'],
  ),

  // ── Fibromyalgia ─────────────────────────────────────────

  _Advice(
    id: 'fibro_01',
    title: 'Understanding fibromyalgia flares',
    body: 'Flares are temporary worsening of symptoms often triggered by '
        'overdoing it, poor sleep, stress, illness, or weather changes. '
        'Keeping a diary to identify your personal triggers can help you '
        'plan ahead and reduce their frequency and severity.',
    category: 'Pain management',
    catColor: _rose,
    catIcon: Icons.thermostat_rounded,
    conditions: ['Fibromyalgia'],
  ),
  _Advice(
    id: 'fibro_02',
    title: 'Pacing with an energy envelope',
    body: 'The energy envelope approach means staying within your available '
        'energy rather than spending it all on good days. Estimate your '
        'daily energy as a percentage and aim to use 70–80% to leave a '
        'buffer. Activities, emotions, and even sensory input all draw '
        'from the same pool.',
    category: 'Pacing',
    catColor: _amber,
    catIcon: Icons.speed_rounded,
    conditions: ['Fibromyalgia', 'ME / Chronic fatigue'],
  ),
  _Advice(
    id: 'fibro_03',
    title: 'Sleep and fibromyalgia',
    body: 'Non-restorative sleep is a core feature of fibromyalgia — '
        'you may sleep many hours but wake unrefreshed. Consistent sleep '
        'and wake times, a cool dark room, avoiding screens an hour before '
        'bed, and limiting caffeine after noon can all help. Discuss sleep '
        'problems explicitly with your GP — there are medication options.',
    category: 'Sleep',
    catColor: _purple,
    catIcon: Icons.bedtime_rounded,
    conditions: ['Fibromyalgia'],
  ),
  _Advice(
    id: 'fibro_04',
    title: 'Communicating fibromyalgia to others',
    body: 'Fibromyalgia is invisible, which can make it hard for others '
        'to understand. Phrases like "my nervous system amplifies pain signals" '
        'or "my body\'s alarm system is oversensitive" can help. You don\'t '
        'owe anyone an explanation, but having a simple description ready '
        'can reduce the emotional load of repeated conversations.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Fibromyalgia'],
  ),
  _Advice(
    id: 'fibro_05',
    title: 'Gentle movement for fibromyalgia',
    body: 'Low-impact exercise — walking, swimming, water aerobics, gentle '
        'yoga, tai chi — is among the most evidence-supported interventions '
        'for fibromyalgia. Start very slowly (even 5 minutes), increase '
        'gradually, and stop before you\'re tired rather than after. '
        'Soreness after movement is common but should ease within 24 hours.',
    category: 'Movement',
    catColor: _green,
    catIcon: Icons.directions_walk_rounded,
    conditions: ['Fibromyalgia'],
  ),

  // ── ME / Chronic fatigue ──────────────────────────────────

  _Advice(
    id: 'me_01',
    title: 'Post-exertional malaise (PEM)',
    body: 'PEM is the hallmark of ME/CFS: a worsening of symptoms — '
        'often delayed by 12–48 hours — after physical, cognitive, or '
        'emotional exertion that wouldn\'t affect healthy people. '
        'Recognising your personal PEM threshold and staying below it '
        'is the central management strategy. Pushing through makes it worse.',
    category: 'Pacing',
    catColor: _amber,
    catIcon: Icons.speed_rounded,
    conditions: ['ME / Chronic fatigue'],
  ),
  _Advice(
    id: 'me_02',
    title: 'Heart rate pacing for ME/CFS',
    body: 'Many people with ME/CFS use a heart rate monitor to stay below '
        'their anaerobic threshold — roughly 55% of maximum heart rate, or '
        'a rough formula of (220 − your age) × 0.55. Staying below this '
        'level helps avoid triggering PEM. A cheap wrist monitor or smartwatch '
        'is enough to get started.',
    category: 'Pacing',
    catColor: _amber,
    catIcon: Icons.speed_rounded,
    conditions: ['ME / Chronic fatigue'],
  ),
  _Advice(
    id: 'me_03',
    title: 'Orthostatic intolerance tips',
    body: 'Many people with ME/CFS experience symptoms when upright '
        '(dizziness, heart racing, worsening fatigue). Strategies include: '
        'rising slowly, compression stockings, eating smaller meals, '
        'increasing salt and fluid intake (discuss with GP first), and '
        'raising the head of your bed slightly.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['ME / Chronic fatigue', 'POTS / Dysautonomia'],
  ),
  _Advice(
    id: 'me_04',
    title: 'Brain fog strategies',
    body: 'Cognitive symptoms in ME/CFS are real neurological effects, '
        'not anxiety or inattention. Strategies: do cognitively demanding '
        'tasks at your best time of day; break tasks into tiny steps; '
        'use written lists and reminders; rest your eyes and reduce '
        'sensory input regularly; accept that some days will be harder.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['ME / Chronic fatigue', 'Fibromyalgia'],
  ),
  _Advice(
    id: 'me_05',
    title: 'Avoiding GET for ME/CFS',
    body: 'Graded Exercise Therapy (GET) as traditionally applied — '
        'progressively increasing exercise — is not recommended for ME/CFS '
        'by NICE (2021 guidelines). If a clinician suggests this, you can '
        'refer them to the NICE NG206 guideline. Pacing — managing activity '
        'within your energy envelope — is the current recommended approach.',
    category: 'Advocacy',
    catColor: _purple,
    catIcon: Icons.shield_outlined,
    conditions: ['ME / Chronic fatigue'],
  ),

  // ── Hypermobility / EDS ──────────────────────────────────

  _Advice(
    id: 'heds_01',
    title: 'Joint protection basics',
    body: 'Protect hypermobile joints by avoiding end-range positions '
        '(e.g. locking elbows or knees fully straight). Use larger joints '
        'for tasks where possible (push doors with your shoulder, carry bags '
        'in the crook of your elbow). Stabilising rather than stretching '
        'is the priority with hypermobility.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Hypermobility / EDS'],
  ),
  _Advice(
    id: 'heds_02',
    title: 'Proprioception and stabilising exercises',
    body: 'Proprioception — your body\'s sense of joint position — is '
        'often reduced in hypermobility. Exercises that build stability '
        'around joints (rather than flexibility) help prevent dislocations '
        'and subluxations. A physiotherapist experienced in EDS/HSD is '
        'the ideal guide — ask for a specialist referral.',
    category: 'Movement',
    catColor: _green,
    catIcon: Icons.directions_walk_rounded,
    conditions: ['Hypermobility / EDS'],
  ),
  _Advice(
    id: 'heds_03',
    title: 'Compression and support',
    body: 'Compression garments (gloves, stockings, sleeves) can reduce '
        'joint pain and instability and support circulation. Sports tape '
        'and kinesiology tape can support specific joints. Ask a physio '
        'to show you appropriate taping techniques for your problem areas.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Hypermobility / EDS', 'POTS / Dysautonomia'],
  ),
  _Advice(
    id: 'heds_04',
    title: 'EDS and medical appointments',
    body: 'Be specific about joint instability rather than just "flexibility". '
        'Mention any dislocations, subluxations, or clicks. Note how it '
        'affects daily function — not just what moves. The Ehlers-Danlos '
        'Society has GP information sheets you can print and bring. '
        'Ask to be referred to a clinician with EDS/HSD experience.',
    category: 'Appointments',
    catColor: _blue,
    catIcon: Icons.calendar_today_rounded,
    conditions: ['Hypermobility / EDS'],
  ),

  // ── POTS / Dysautonomia ──────────────────────────────────

  _Advice(
    id: 'pots_01',
    title: 'Managing POTS symptoms day to day',
    body: 'Rise slowly from lying or sitting. Avoid prolonged standing — '
        'shifting weight, marching on the spot, or leaning against a wall '
        'can help. Eat smaller, more frequent meals. Cool environments '
        'help most people. Avoid alcohol. Compression garments covering '
        'legs and abdomen are often effective.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['POTS / Dysautonomia'],
  ),
  _Advice(
    id: 'pots_02',
    title: 'Salt and fluid loading in POTS',
    body: 'Increasing sodium and fluid intake increases blood volume and '
        'reduces POTS symptoms for many people. Typical guidance is 2–3 '
        'litres of water and 3–5g extra sodium per day — but this must '
        'be discussed with your GP or cardiologist first, as it\'s not '
        'appropriate for everyone (especially those with heart or kidney conditions).',
    category: 'Nutrition',
    catColor: _green,
    catIcon: Icons.restaurant_rounded,
    conditions: ['POTS / Dysautonomia'],
  ),

  // ── Arthritis ────────────────────────────────────────────

  _Advice(
    id: 'arth_01',
    title: 'Managing joint stiffness',
    body: 'Morning stiffness is common in arthritis. Gentle movement '
        'before getting up — ankle circles, wrist rotations, knee bends — '
        'can reduce stiffness. A warm shower or bath before activity helps. '
        'Avoid staying still for long periods during the day.',
    category: 'Movement',
    catColor: _green,
    catIcon: Icons.directions_walk_rounded,
    conditions: ['Arthritis'],
  ),
  _Advice(
    id: 'arth_02',
    title: 'Protecting your joints',
    body: 'Use assistive devices (jar openers, trolleys, ergonomic tools) '
        'to reduce joint strain. Spread tasks across the day rather than '
        'doing everything at once. Ask your GP for an occupational therapy '
        'referral — OTs can assess your home and suggest adaptations.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Arthritis', 'Hypermobility / EDS'],
  ),

  // ── IBS / IBD / Crohn's / Coeliac ────────────────────────

  _Advice(
    id: 'gut_01',
    title: 'Food and symptom diary',
    body: 'Keeping a food diary for 2–4 weeks — logging what you eat, '
        'when, and symptoms that follow — helps identify personal trigger '
        'foods. Apps or a notebook both work. Bring the diary to your '
        'dietitian or gastroenterologist appointment.',
    category: 'Nutrition',
    catColor: _green,
    catIcon: Icons.restaurant_rounded,
    conditions: ['Crohn\'s disease', 'IBS / IBD', 'Coeliac disease'],
  ),
  _Advice(
    id: 'gut_02',
    title: 'Low-FODMAP basics for IBS',
    body: 'A low-FODMAP diet (reducing fermentable carbohydrates) is '
        'evidence-supported for IBS. It\'s a temporary elimination and '
        'reintroduction process, not a permanent restriction. It should '
        'ideally be done with a registered dietitian — ask your GP for '
        'a referral. Doing it unsupported often leads to unnecessary '
        'long-term restriction.',
    category: 'Nutrition',
    catColor: _green,
    catIcon: Icons.restaurant_rounded,
    conditions: ['IBS / IBD'],
  ),
  _Advice(
    id: 'gut_03',
    title: 'Stress and the gut connection',
    body: 'The gut-brain axis means stress and anxiety directly affect '
        'gut function. This is not "all in your head" — it\'s a real '
        'physiological connection. Techniques that reduce the stress '
        'response (breathing exercises, pacing, reducing overcommitment) '
        'can meaningfully reduce gut symptoms for many people.',
    category: 'Mental health',
    catColor: _purple,
    catIcon: Icons.self_improvement_rounded,
    conditions: ['Crohn\'s disease', 'IBS / IBD'],
  ),
  _Advice(
    id: 'gut_04',
    title: 'Coeliac: cross-contamination matters',
    body: 'For coeliac disease, even tiny amounts of gluten cause '
        'intestinal damage — even if you feel no immediate symptoms. '
        'Use separate toasters, chopping boards, and utensils. Check '
        'labels on all packaged foods. Be cautious at restaurants — '
        '"gluten-free" on a menu doesn\'t always mean safe preparation. '
        'Coeliac UK has a restaurant card you can show staff.',
    category: 'Nutrition',
    catColor: _green,
    catIcon: Icons.restaurant_rounded,
    conditions: ['Coeliac disease'],
  ),
  _Advice(
    id: 'gut_05',
    title: 'Building a flare kit for IBD',
    body: 'Prepare for flares in advance: have your rescue medication '
        'prescribed and accessible; keep a list of who to contact '
        '(IBD nurse, GP, out-of-hours); note your typical flare symptoms '
        'so you can recognise when to seek help earlier; and have '
        'easily digestible foods stocked. Know the red-flag symptoms '
        '(blood, severe pain, fever) that need urgent review.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Crohn\'s disease', 'IBS / IBD'],
  ),

  // ── Endometriosis / PCOS ─────────────────────────────────

  _Advice(
    id: 'endo_01',
    title: 'Tracking your cycle and symptoms',
    body: 'Recording symptoms alongside your menstrual cycle can reveal '
        'patterns that help with diagnosis and treatment decisions. '
        'Note pain scores, location, bloating, fatigue, and any other '
        'symptoms for at least 3 cycles. This data is valuable to a '
        'gynaecologist or endometriosis specialist.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Endometriosis', 'PCOS', 'PMDD'],
  ),
  _Advice(
    id: 'endo_02',
    title: 'Advocating for endometriosis care',
    body: 'Average diagnosis time for endometriosis in the UK is around '
        '8 years. If you\'re dismissed, ask specifically for a referral '
        'to a gynaecologist or BSGE-accredited endometriosis centre. '
        'Keep written records of every appointment and what was said. '
        'Endometriosis UK has resources and a helpline.',
    category: 'Advocacy',
    catColor: _purple,
    catIcon: Icons.shield_outlined,
    conditions: ['Endometriosis'],
  ),
  _Advice(
    id: 'endo_03',
    title: 'Heat for menstrual and pelvic pain',
    body: 'A heat pad or hot water bottle over the lower abdomen or '
        'lower back during a flare can significantly reduce pain for '
        'many people. TENS machines, warm baths, and gentle movement '
        'may also help. Keep a note of what works for you personally.',
    category: 'Pain management',
    catColor: _rose,
    catIcon: Icons.thermostat_rounded,
    conditions: ['Endometriosis', 'PCOS', 'PMDD'],
  ),

  // ── Migraine ─────────────────────────────────────────────

  _Advice(
    id: 'migraine_01',
    title: 'Keeping a migraine diary',
    body: 'Record date, duration, severity, any warning signs (aura, '
        'mood changes, yawning, food cravings), possible triggers, '
        'medication taken and how long before it worked. Three months '
        'of diary data is enough for a meaningful pattern review with '
        'your GP and supports consideration of preventive treatment.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Migraine'],
  ),
  _Advice(
    id: 'migraine_02',
    title: 'Medication overuse headache',
    body: 'Taking pain relief (including triptans, paracetamol, or NSAIDs) '
        'on more than 10–15 days per month can itself cause daily headaches — '
        'medication overuse headache (MOH). If you\'re using acute migraine '
        'medication frequently, discuss preventive options with your GP '
        'rather than increasing acute use.',
    category: 'Medications',
    catColor: _rose,
    catIcon: Icons.medication_rounded,
    conditions: ['Migraine'],
  ),
  _Advice(
    id: 'migraine_03',
    title: 'Prodrome: acting early',
    body: 'Many people experience a prodrome phase — mood changes, '
        'yawning, neck stiffness, food cravings — hours before head '
        'pain starts. Taking medication (if prescribed) or resting '
        'during prodrome often reduces the severity of the full attack. '
        'Learning to recognise your personal early warning signs is worth '
        'tracking in a diary.',
    category: 'Pain management',
    catColor: _rose,
    catIcon: Icons.thermostat_rounded,
    conditions: ['Migraine'],
  ),
  _Advice(
    id: 'migraine_04',
    title: 'Common migraine triggers',
    body: 'Common triggers include dehydration, skipped meals, disrupted '
        'sleep, bright or flickering light, strong scents, stress (and '
        'the let-down after stress), alcohol (especially red wine and '
        'beer), hormonal changes, and weather changes. Triggers are '
        'highly individual — your diary will identify yours.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Migraine'],
  ),

  // ── ADHD ─────────────────────────────────────────────────

  _Advice(
    id: 'adhd_01',
    title: 'Body doubling for focus',
    body: 'Body doubling means working alongside another person — in '
        'person, on video call, or even a YouTube "study with me" stream. '
        'The presence of others helps many ADHD brains engage with tasks '
        'that feel impossible alone. You don\'t need to interact — '
        'just being in proximity is enough.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['ADHD'],
  ),
  _Advice(
    id: 'adhd_02',
    title: 'ADHD and sleep',
    body: 'ADHD is strongly linked to delayed sleep phase — a natural '
        'tendency for later sleep and wake times. Combined with racing '
        'thoughts and difficulty transitioning to sleep, poor sleep '
        'is common. Light exposure management (morning light, evening '
        'dimming), consistent timing, and removing screens from the '
        'bedroom can help. Discuss persistent sleep problems with your prescriber.',
    category: 'Sleep',
    catColor: _purple,
    catIcon: Icons.bedtime_rounded,
    conditions: ['ADHD'],
  ),
  _Advice(
    id: 'adhd_03',
    title: 'Managing hyperfocus',
    body: 'Hyperfocus can be a strength — but losing hours without '
        'eating, drinking, or resting causes crashes. Set alarms or '
        'timers that interrupt hyperfocus states. Tell someone to check '
        'in on you. Use transition warnings ("10 minutes left") to '
        'help your brain prepare to shift attention.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['ADHD'],
  ),
  _Advice(
    id: 'adhd_04',
    title: 'Working with your ADHD medication',
    body: 'ADHD medication effectiveness depends on timing, dose, and '
        'consistency. Note when your medication peaks and wears off, '
        'and plan demanding tasks accordingly. Discuss timing with your '
        'prescriber if wearing off causes difficult evenings. Food can '
        'affect absorption — check your medication\'s specific guidance.',
    category: 'Medications',
    catColor: _rose,
    catIcon: Icons.medication_rounded,
    conditions: ['ADHD'],
  ),
  _Advice(
    id: 'adhd_05',
    title: 'Executive function tools',
    body: 'External structure replaces what the ADHD brain struggles to '
        'generate internally. Tools that help: visual timers (Time Timer); '
        'physical task boards (sticky notes on a wall); one trusted to-do '
        'list kept in one place; "if-then" plans ("if I finish this, '
        'then I do that"); and habit stacking (anchoring new habits to '
        'existing ones).',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['ADHD', 'Autism', 'Dyspraxia'],
  ),

  // ── Autism ───────────────────────────────────────────────

  _Advice(
    id: 'autism_01',
    title: 'Managing sensory overload',
    body: 'Identify your overload triggers (noise, light, crowds, '
        'textures, smells) and plan around them where possible. '
        'Useful strategies: noise-cancelling headphones, sunglasses '
        'indoors, fidget tools, weighted blankets, pre-planning '
        'sensory rest after demanding situations, and having a '
        '"safe space" to decompress.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Autism', 'ADHD'],
  ),
  _Advice(
    id: 'autism_02',
    title: 'Medical appointments and communication',
    body: 'You can request adjustments for medical appointments: a '
        'quieter waiting area, a written summary of what was discussed, '
        'extra time, having a support person with you, or communicating '
        'by letter/email rather than phone. You can prepare written notes '
        'in advance and ask for written responses rather than verbal ones.',
    category: 'Appointments',
    catColor: _blue,
    catIcon: Icons.calendar_today_rounded,
    conditions: ['Autism', 'ADHD', 'Dyspraxia'],
  ),
  _Advice(
    id: 'autism_03',
    title: 'Recovery from meltdown or shutdown',
    body: 'After a meltdown or shutdown, your nervous system needs time '
        'to regulate. This is physiological recovery, not drama. '
        'What helps varies: some people need solitude and silence, '
        'others need gentle sensory input (weighted blanket, specific '
        'textures, familiar sounds). Planning recovery time after '
        'demanding events reduces severity and duration.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Autism'],
  ),
  _Advice(
    id: 'autism_04',
    title: 'Masking and energy cost',
    body: 'Masking — suppressing natural behaviours to appear '
        'neurotypical — has a significant energy cost and is linked '
        'to higher rates of burnout, anxiety, and depression in '
        'autistic people. Reducing masking in safe environments '
        'and building in unmasking time is a legitimate and '
        'important self-care strategy.',
    category: 'Mental health',
    catColor: _purple,
    catIcon: Icons.self_improvement_rounded,
    conditions: ['Autism'],
  ),

  // ── Anxiety / Depression ─────────────────────────────────

  _Advice(
    id: 'mh_01',
    title: 'Breathing to reduce anxiety',
    body: 'Box breathing: inhale for 4 counts, hold for 4, exhale '
        'for 4, hold for 4. Repeat 4–6 times. The extended exhale '
        'activates the parasympathetic nervous system. '
        '4-7-8 breathing (in for 4, hold for 7, out for 8) has a '
        'stronger effect. Practice when calm so it\'s available '
        'when you need it.',
    category: 'Mental health',
    catColor: _purple,
    catIcon: Icons.self_improvement_rounded,
    conditions: ['Anxiety', 'PTSD', 'ADHD'],
  ),
  _Advice(
    id: 'mh_02',
    title: '5-4-3-2-1 grounding',
    body: 'When anxiety or panic is high, name: 5 things you can '
        'see, 4 you can physically feel, 3 you can hear, 2 you can '
        'smell, 1 you can taste. This grounds you in the present '
        'moment and interrupts the anxiety loop. It works even when '
        'you know exactly why you\'re anxious.',
    category: 'Mental health',
    catColor: _purple,
    catIcon: Icons.self_improvement_rounded,
    conditions: ['Anxiety', 'PTSD', 'ADHD', 'Autism'],
  ),
  _Advice(
    id: 'mh_03',
    title: 'Worry time',
    body: 'Set aside 15–20 minutes at the same time each day as '
        '"worry time". When worries arise outside this window, '
        'write them down and return to them later. During worry '
        'time, engage with the worries deliberately. This reduces '
        'the intrusion of worry throughout the day without suppressing it.',
    category: 'Mental health',
    catColor: _purple,
    catIcon: Icons.self_improvement_rounded,
    conditions: ['Anxiety', 'Depression'],
  ),
  _Advice(
    id: 'mh_04',
    title: 'Physical symptoms of anxiety',
    body: 'Anxiety causes real physical symptoms: racing heart, '
        'chest tightness, dizziness, nausea, sweating, trembling, '
        'difficulty breathing. These can overlap with other medical '
        'conditions. If you\'re uncertain whether symptoms are anxiety '
        'or another cause, it\'s always worth discussing with your GP — '
        'but knowing that anxiety can cause these helps reduce '
        'the fear they create, which in turn reduces anxiety.',
    category: 'Mental health',
    catColor: _purple,
    catIcon: Icons.self_improvement_rounded,
    conditions: ['Anxiety'],
  ),
  _Advice(
    id: 'mh_05',
    title: 'Depression: doing the opposite',
    body: 'Depression reduces motivation and makes activities feel '
        'pointless before you start. Behavioural activation — doing '
        'small activities regardless of motivation — can gradually '
        'shift mood. Start with the smallest possible version of something '
        '(not a walk, but putting on shoes; not cooking, but boiling water). '
        'Motivation often follows action rather than preceding it.',
    category: 'Mental health',
    catColor: _purple,
    catIcon: Icons.self_improvement_rounded,
    conditions: ['Depression'],
  ),

  // ── PTSD ─────────────────────────────────────────────────

  _Advice(
    id: 'ptsd_01',
    title: 'Managing PTSD triggers',
    body: 'Identifying your triggers (sensory, situational, relational) '
        'allows you to prepare rather than be caught off guard. '
        'Grounding techniques (5-4-3-2-1, cold water on wrists, '
        'named objects in your bag) create an anchor to the present '
        'when triggered. Trauma-focused therapy (EMDR, trauma-focused CBT) '
        'is recommended — ask your GP for a referral.',
    category: 'Mental health',
    catColor: _purple,
    catIcon: Icons.self_improvement_rounded,
    conditions: ['PTSD'],
  ),

  // ── Diabetes ─────────────────────────────────────────────

  _Advice(
    id: 'diab_01',
    title: 'Recognising and treating hypoglycaemia',
    body: 'Hypo symptoms: shaking, sweating, confusion, hunger, '
        'rapid heartbeat, irritability. Treat immediately with fast-acting '
        'glucose (glucose tablets, full-sugar fizzy drink, fruit juice) '
        'then a slow-release snack. Know your personal threshold and '
        'carry glucose at all times. Tell people you spend time with '
        'what to do if you can\'t help yourself.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Diabetes (Type 1)', 'Diabetes (Type 2)'],
  ),
  _Advice(
    id: 'diab_02',
    title: 'Exercise and blood glucose',
    body: 'Exercise affects blood glucose differently depending on type '
        'and duration — aerobic exercise typically lowers it, while '
        'intense anaerobic exercise can temporarily raise it. Monitor '
        'before, during (for longer sessions), and after. Discuss your '
        'specific activity plans with your diabetes team to adjust '
        'medication or carbohydrate intake accordingly.',
    category: 'Movement',
    catColor: _green,
    catIcon: Icons.directions_walk_rounded,
    conditions: ['Diabetes (Type 1)', 'Diabetes (Type 2)'],
  ),

  // ── Lupus / Autoimmune ───────────────────────────────────

  _Advice(
    id: 'lupus_01',
    title: 'Sun protection with lupus',
    body: 'UV light can trigger lupus flares — even through glass '
        'or on cloudy days. Use SPF 50+ sunscreen daily, UV-protective '
        'clothing, and a broad-brimmed hat when outdoors. '
        'Fluorescent lighting can also trigger photosensitivity in some '
        'people. Vitamin D levels should be monitored and supplemented '
        'if needed, as sun avoidance increases deficiency risk.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Lupus'],
  ),
  _Advice(
    id: 'lupus_02',
    title: 'Recognising a lupus flare early',
    body: 'Early flare signs often include increasing fatigue, '
        'joint pain or swelling, rash changes, and mouth ulcers. '
        'Keeping a symptom diary helps you recognise your pattern. '
        'Contact your rheumatology team early — catching a flare '
        'before it\'s severe often means less intensive treatment.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Lupus', 'MS'],
  ),

  // ── Raynaud's ────────────────────────────────────────────

  _Advice(
    id: 'ray_01',
    title: 'Managing Raynaud\'s attacks',
    body: 'Warm the core first (hands warm faster if your body is '
        'warm). Layer clothing, wear gloves before going out rather '
        'than waiting until cold, use electric gloves or hand warmers '
        'for severe cases. Avoid gripping cold objects (use insulated '
        'cups, wear gloves to reach into the freezer). Avoid smoking '
        'and caffeine — both constrict blood vessels.',
    category: 'Daily living',
    catColor: _teal,
    catIcon: Icons.edit_note_rounded,
    conditions: ['Raynaud\'s'],
  ),

  // ── Sleep (cross-condition) ──────────────────────────────

  _Advice(
    id: 'sleep_01',
    title: 'Sleep hygiene fundamentals',
    body: 'Consistent sleep and wake times (even at weekends) anchor '
        'your body clock. A cool (16–18°C), dark, quiet room supports '
        'sleep onset. Avoid screens 30–60 minutes before bed. Avoid '
        'caffeine after 2pm. A brief wind-down routine signals sleep '
        'is coming — the same sequence each night works better than '
        'a perfect routine.',
    category: 'Sleep',
    catColor: _purple,
    catIcon: Icons.bedtime_rounded,
    conditions: ['general'],
  ),
  _Advice(
    id: 'sleep_02',
    title: 'When sleep problems persist',
    body: 'If you\'ve had sleep problems for more than 4 weeks, speak '
        'to your GP. Mention: how long it takes to fall asleep, '
        'how often you wake, how you feel in the morning, and any '
        'other symptoms (snoring, leg sensations, pain). CBT for '
        'insomnia (CBT-I) is the most effective long-term treatment '
        'and is available via referral or apps like Sleepio.',
    category: 'Sleep',
    catColor: _purple,
    catIcon: Icons.bedtime_rounded,
    conditions: ['general'],
  ),
];

// ── Screen ────────────────────────────────────────────────────

class AdviceHubScreen extends StatefulWidget {
  const AdviceHubScreen({super.key});

  @override
  State<AdviceHubScreen> createState() => _AdviceHubScreenState();
}

class _AdviceHubScreenState extends State<AdviceHubScreen> {
  static const _bookmarksKey  = 'nova_advice_bookmarks';
  static const _profileKey    = 'nova_health_profile';

  Set<String>  _bookmarks         = {};
  Set<String>  _profileConditions = {};
  String       _search            = '';
  String       _filter            = 'for_you';
  bool         _loading           = true;

  final _searchCtrl = TextEditingController();

  // ── Lifecycle ──────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Bookmarks
    final rawBookmarks = prefs.getStringList(_bookmarksKey) ?? [];
    final bookmarks    = rawBookmarks.toSet();

    // Profile conditions
    Set<String> profileConditions = {};
    final rawProfile = prefs.getString(_profileKey);
    if (rawProfile != null) {
      try {
        final d = jsonDecode(rawProfile) as Map<String, dynamic>;
        final condList  = List<String>.from((d['conditions']       as List?) ?? []);
        final customList = List<String>.from((d['customConditions'] as List?) ?? []);
        profileConditions = {...condList, ...customList};
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _bookmarks         = bookmarks;
      _profileConditions = profileConditions;
      _loading           = false;
      // Default: 'for_you' if profile has conditions, else 'all'
      _filter = profileConditions.isNotEmpty ? 'for_you' : 'all';
    });
  }

  Future<void> _toggleBookmark(String id) async {
    setState(() {
      if (_bookmarks.contains(id)) {
        _bookmarks.remove(id);
      } else {
        _bookmarks.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarksKey, _bookmarks.toList());
  }

  // ── Derived ────────────────────────────────────────────

  bool _matchesProfile(_Advice a) =>
      a.conditions.contains('general') ||
      a.conditions.any((c) => _profileConditions.contains(c));

  bool _matchesSearch(_Advice a) {
    if (_search.isEmpty) return true;
    final q = _search.toLowerCase();
    return a.title.toLowerCase().contains(q) ||
        a.body.toLowerCase().contains(q) ||
        a.category.toLowerCase().contains(q) ||
        a.conditions.any((c) => c.toLowerCase().contains(q));
  }

  List<_Advice> get _filtered {
    return _allAdvice.where((a) {
      if (!_matchesSearch(a)) return false;
      if (_filter == 'for_you')   return _matchesProfile(a);
      if (_filter == 'bookmarked') return _bookmarks.contains(a.id);
      if (_filter == 'all')       return true;
      // Condition-specific filter
      return a.conditions.contains(_filter);
    }).toList();
  }

  /// Conditions from the user's profile that have at least one card.
  List<String> get _availableConditionFilters {
    return _profileConditions
        .where((c) => _allAdvice.any((a) => a.conditions.contains(c)))
        .toList()
      ..sort();
  }

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: const Text(
          'Advice Hub',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Bookmark shortcut
          _filter != 'bookmarked'
              ? IconButton(
                  icon: const Icon(Icons.bookmark_border_rounded),
                  color: _muted,
                  tooltip: 'Bookmarked',
                  onPressed: () => setState(() => _filter = 'bookmarked'),
                )
              : IconButton(
                  icon: const Icon(Icons.bookmark_rounded),
                  color: _amber,
                  onPressed: () => setState(() =>
                      _filter = _profileConditions.isNotEmpty ? 'for_you' : 'all'),
                ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : Column(
              children: [
                _buildSearch(),
                _buildFilterChips(),
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: _text, fontSize: 14),
        cursorColor: _blue,
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'Search advice…',
          hintStyle: TextStyle(color: _muted.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search_rounded,
              color: _muted.withValues(alpha: 0.6), size: 20),
          suffixIcon: _search.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                  },
                  child: Icon(Icons.close_rounded,
                      color: _muted.withValues(alpha: 0.6), size: 18),
                )
              : null,
          filled: true,
          fillColor: _panel,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _blue.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = <_FilterChipDef>[
      if (_profileConditions.isNotEmpty)
        const _FilterChipDef('for_you', 'For You', Icons.auto_awesome_rounded, _blue),
      const _FilterChipDef('all', 'All', Icons.grid_view_rounded, _muted),
      ..._availableConditionFilters.map((c) => _FilterChipDef(c, c, null, _purple)),
      _FilterChipDef('bookmarked', 'Saved  ${_bookmarks.isNotEmpty ? "(${_bookmarks.length})" : ""}',
          Icons.bookmark_rounded, _amber),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c    = chips[i];
          final sel  = _filter == c.id;
          return GestureDetector(
            onTap: () => setState(() => _filter = c.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: sel ? c.color.withValues(alpha: 0.16) : _panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? c.color.withValues(alpha: 0.55) : _border,
                  width: sel ? 1.2 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (c.icon != null) ...[
                    Icon(c.icon, size: 13, color: sel ? c.color : _muted),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    c.label,
                    style: TextStyle(
                      color: sel ? c.color : _muted,
                      fontSize: 12.5,
                      fontWeight:
                          sel ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    final cards = _filtered;

    if (cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _filter == 'bookmarked'
                    ? Icons.bookmark_border_rounded
                    : Icons.search_off_rounded,
                color: _muted.withValues(alpha: 0.35),
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                _filter == 'bookmarked'
                    ? 'No bookmarks yet'
                    : _search.isNotEmpty
                        ? 'No results for "$_search"'
                        : 'No advice cards here',
                style: const TextStyle(
                    color: _muted, fontSize: 15, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _filter == 'bookmarked'
                    ? 'Tap the bookmark icon on any card to save it here.'
                    : 'Try a different filter or clear the search.',
                style: TextStyle(
                    color: _muted.withValues(alpha: 0.6), fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Group by category when not searching
    if (_search.isEmpty) {
      return _buildGroupedList(cards);
    }
    return _buildFlatList(cards);
  }

  Widget _buildGroupedList(List<_Advice> cards) {
    // Build ordered category groups preserving first-seen order
    final seen       = <String>{};
    final categories = <String>[];
    for (final c in cards) {
      if (seen.add(c.category)) categories.add(c.category);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      itemCount: categories.length + (_filter == 'for_you' ? 1 : 0),
      itemBuilder: (_, i) {
        // "For You" banner at top
        if (_filter == 'for_you' && i == 0) return _forYouBanner();
        final catIdx = _filter == 'for_you' ? i - 1 : i;
        final cat    = categories[catIdx];
        final group  = cards.where((c) => c.category == cat).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _categoryHeader(group.first),
            ...group.map(_buildCard),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildFlatList(List<_Advice> cards) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      itemCount: cards.length,
      itemBuilder: (_, i) => _buildCard(cards[i]),
    );
  }

  Widget _forYouBanner() {
    final count = _profileConditions.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _blue.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: _blue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              count > 0
                  ? 'Showing advice relevant to your $count recorded '
                    '${count == 1 ? "condition" : "conditions"}, plus general tips.'
                  : 'General self-management advice.',
              style: const TextStyle(
                  color: _muted, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryHeader(_Advice sample) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: sample.catColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(sample.catIcon, color: sample.catColor, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          sample.category.toUpperCase(),
          style: TextStyle(
            color: sample.catColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ]),
    );
  }

  Widget _buildCard(_Advice a) {
    final bookmarked = _bookmarks.contains(a.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: bookmarked
              ? _amber.withValues(alpha: 0.35)
              : _border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetail(a),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category dot
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: a.catColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      a.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted.withValues(alpha: 0.85),
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Condition tags
                    if (!a.conditions.contains('general'))
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: a.conditions
                            .where((c) => c != 'general')
                            .map((c) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _purple.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: _purple.withValues(alpha: 0.25)),
                                  ),
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                        color: _purple.withValues(alpha: 0.9),
                                        fontSize: 10),
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
              // Bookmark button
              GestureDetector(
                onTap: () => _toggleBookmark(a.id),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                    bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: bookmarked ? _amber : _muted.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(_Advice a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isBookmarked = _bookmarks.contains(a.id);
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            builder: (_, ctrl) => Container(
              decoration: const BoxDecoration(
                color: _panel,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: a.catColor.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(a.catIcon,
                              color: a.catColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.category.toUpperCase(),
                                style: TextStyle(
                                  color: a.catColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                a.title,
                                style: const TextStyle(
                                  color: _text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bookmark in modal
                        GestureDetector(
                          onTap: () {
                            _toggleBookmark(a.id);
                            setModalState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: isBookmarked
                                  ? _amber
                                  : _muted.withValues(alpha: 0.5),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Body
                  Expanded(
                    child: ListView(
                      controller: ctrl,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      children: [
                        Text(
                          a.body,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 15,
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!a.conditions.contains('general')) ...[
                          Text(
                            'RELEVANT TO',
                            style: TextStyle(
                              color: _muted.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: a.conditions
                                .map((c) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _purple.withValues(alpha: 0.10),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                                _purple.withValues(alpha: 0.28)),
                                      ),
                                      child: Text(
                                        c,
                                        style: TextStyle(
                                          color: _purple.withValues(alpha: 0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        // Disclaimer
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _panel2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: _muted.withValues(alpha: 0.5),
                                  size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'General self-management information only. '
                                  'Not a substitute for professional medical advice. '
                                  'Always discuss changes with your care team.',
                                  style: TextStyle(
                                    color: _muted.withValues(alpha: 0.6),
                                    fontSize: 11.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Filter chip definition ────────────────────────────────────

class _FilterChipDef {
  final String id;
  final String label;
  final IconData? icon;
  final Color color;
  const _FilterChipDef(this.id, this.label, this.icon, this.color);
}
