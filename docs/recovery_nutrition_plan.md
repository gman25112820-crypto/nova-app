\# Nova Recovery \& Nutrition Module Plan



\## Project Context



Project directory:



C:\\Users\\Garet\\nova\_app



Current active branch:



nova-fab



Target files to inspect later:



\- lib/fab/screens/recovery\_screen.dart

\- lib/fab/screens/nutrition\_screen.dart

\- lib/fab/screens/cooking\_screen.dart

\- lib/fab/screens/sleep\_screen.dart



Important rule:



Do not overwrite active Claude work on the Fabulously Me world scene, feeling check-in, calm plan, character consistency, local stories, or navigation hub.



\---



\## Purpose



This document captures the Recovery and Nutrition module direction so the ideas can be used later without blindly editing the current screens.



Nova should support gentle tracking, pacing, reflection, and preparation. It should not give medical advice, diagnose conditions, prescribe supplements, or replace a GP, physio, dietitian, pain clinic, or emergency care.



\---



\## Recovery Screen Scope



\### Core Components



\- Daily recovery check-in

\- Back pain / sciatica pain log

\- Flare-up tracker

\- Sleep and fatigue score

\- Energy and mood impact

\- Trigger tracker

\- What helped tracker

\- Pacing notes

\- Gentle routine notes

\- GP / clinician export summary later



\### Suggested Recovery Check-In Fields



\- Date

\- Pain score 0–10

\- Pain type: lower back, sciatica, nerve pain, hip, leg, stiffness, flare

\- Trigger: sitting, standing, walking, bending, poor sleep, stress, unknown

\- What helped: medication, rest, heat, movement, stretching, lying down, breathing, distraction

\- What made it worse

\- Energy score 0–10

\- Mood impact

\- Safe next action

\- Notes



\### Recovery Principle



Progress should not mean “do more every day”.



For chronic back pain or nerve damage, progress can mean:



\- pacing better

\- stopping before a flare

\- recovering faster after a bad day

\- avoiding known triggers

\- asking for help earlier

\- keeping evidence clearer for appointments



\---



\## Nutrition Screen Scope



\### Core Components



\- No-BS food log

\- Simple meal history

\- Trigger food notes

\- Allergy and intolerance ledger

\- Bad-day meal ideas

\- Batch cooking notes

\- Slow cooker / air fryer meals

\- Shopping helper later

\- Dietitian / GP export summary later



\### Suggested Nutrition Fields



\- Date

\- Meal

\- Ingredients

\- Energy before / after

\- Pain or flare impact

\- Digestion impact

\- Mood impact

\- Trigger suspected: yes/no

\- Allergy/intolerance concern

\- Prep effort: low / medium / high

\- Repeat meal: yes/no

\- Notes



\---



\## Cooking / Meal Prep Module



\### Active Meal Prep Log



Personal example:



Creamy Greek Yogurt \& Egg Frittatas



Ingredients:



\- 8 eggs

\- 3 tbsp Greek yogurt

\- chestnut mushrooms

\- brown onions

\- garlic

\- greens

\- blistered tomatoes



Method:



\- Cooked at 160°C for around 12 minutes

\- Divided into 2 uniform round tins

\- Sliced into multi-day wedges

\- Stored for quick cold fridge retrieval



Use in app as:



\- personal meal prep example

\- repeatable batch meal template

\- not medical/dietary advice



\---



\## Gaz Personal Test Baseline



This section is a personal experiment/log only. It must not be presented as a general Nova recommendation.



Date:



18 May 2026



Current personal notes:



\- Creatine loading phase noted as day 2 of 5

\- Personal intake note: 15g–20g staggered daily

\- Personal hydration target noted: 3.5 to 4 litres daily

\- Current active movement loop:

&#x20; - Cat-Cow spinal decompressions, 20 reps

&#x20; - Glute Bridges, 2x15

&#x20; - Bird-Dogs, 2x15

&#x20; - Sit-up variants, 3x10

&#x20; - Leg Raises with lumbar support, 2x20

&#x20; - Daily baseline target: 35+ press-ups



Safety wording:



These are personal notes only. Nova should not recommend supplement doses, hydration targets, exercise volume, or recovery routines to other users without professional guidance.



\---



\## Shared Recovery + Nutrition Engine



The Recovery and Nutrition modules should share a simple daily pattern:



1\. How do I feel today?

2\. What did I eat / do / sleep like?

3\. What changed pain, energy, or mood?

4\. What helped?

5\. What should I do next safely?

6\. What evidence should be saved for later?



Shared outputs:



\- Daily summary

\- Weekly pattern

\- Trigger list

\- Helpful actions list

\- GP/clinician export later



\---



\## Safety Boundaries



Nova should not:



\- diagnose

\- prescribe medication

\- prescribe supplements

\- tell users to ignore severe symptoms

\- replace emergency care

\- replace GP, physio, dietitian, or specialist advice

\- present personal experiments as general guidance



Nova can:



\- help users track patterns

\- help users prepare notes

\- encourage pacing

\- suggest contacting appropriate support when worried

\- help format information for appointments



\---



\## Next Technical Steps



After Claude finishes the current Fabulously Me work:



1\. Run git status --short

2\. Run git diff --stat

3\. Run flutter analyze

4\. Run flutter run -d chrome

5\. Confirm the correct Fabulously Me route loads

6\. Inspect recovery\_screen.dart

7\. Inspect nutrition\_screen.dart

8\. Decide whether to update screens or create module notes first

9\. Commit only intentional Dart/app changes

10\. Leave temporary Python helper scripts untracked unless deliberately keeping them



\---



\## Inspection Commands



Use these from:



C:\\Users\\Garet\\nova\_app



```cmd

findstr /n /i "class recovery nutrition food meal allergy intolerance diet trigger sleep fatigue pain flare" lib\\fab\\screens\\\*.dart

