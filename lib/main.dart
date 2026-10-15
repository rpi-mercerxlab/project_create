import 'package:flutter/material.dart';
import 'services/ai_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:async';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class LuxiColors {
  static const background = Color(0xFF000000);
  static const buttonPurple = Color(0xFF38205F);
  static const sky = Color(0xFFCFEBFF);
  static const vividBlue = Color(0xFF5460FF);
  static const lavender = Color(0xFFD9C7FF);
  static const cyan = Color(0xFFC7F3FF);
  static const slate = Color(0xFF374166);
  static const important = Color(0xFF1424FF);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFD7DCE5);
  static const completed = Color(0xFFE3E5EB);
  static const checkGreen = Color(0xFFC5E0CA);
  static const mutedText = Color(0xFF62697A);
  static const codeBackground = Color(0xFF20263A);
}

class _TopicColors {
  const _TopicColors({required this.accent, required this.ink, required this.surface});

  final Color accent;
  final Color ink;
  final Color surface;
}

_TopicColors _topicColors(String category) => switch (category) {
      'ELECTRONICS' => const _TopicColors(
          accent: LuxiColors.vividBlue,
          ink: LuxiColors.slate,
          surface: LuxiColors.cyan,
        ),
      'CODING' => const _TopicColors(
          accent: LuxiColors.important,
          ink: LuxiColors.important,
          surface: LuxiColors.sky,
        ),
      'SIMULATION' => const _TopicColors(
          accent: LuxiColors.vividBlue,
          ink: LuxiColors.slate,
          surface: LuxiColors.lavender,
        ),
      'ANALYSIS' => const _TopicColors(
          accent: LuxiColors.slate,
          ink: LuxiColors.slate,
          surface: LuxiColors.cyan,
        ),
      _ => const _TopicColors(
          accent: LuxiColors.slate,
          ink: LuxiColors.slate,
          surface: LuxiColors.sky,
        ),
    };

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: LuxiColors.important,
      brightness: Brightness.light,
    ).copyWith(
      primary: LuxiColors.important,
      onPrimary: Colors.white,
      secondary: LuxiColors.vividBlue,
      surface: LuxiColors.card,
      onSurface: LuxiColors.slate,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luxi Home',
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: LuxiColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: LuxiColors.background,
          foregroundColor: LuxiColors.sky,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const MyHomePage(title: 'Luxi Home'),
    );
  }
}


final List<Orb> orbs = List.generate(23, (_) => Orb());
Size _orbViewport = const Size(400, 800);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _orbController;
  bool _isLoading = false; // still useful to disable button

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(() {
        setState(() {
          for (var orb in orbs) {
            orb.move(_orbViewport.width, _orbViewport.height);
          }
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  Future<void> _goToSuggestPage() async {
    setState(() {
      _isLoading = true;
      for (var orb in orbs) {
        orb.mode = BubbleMode.falling;
      }
    });

    // Let orbs fall and settle
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    setState(() {
      for (var orb in orbs) {
        if (orb.mode == BubbleMode.waiting) {
          orb.mode = BubbleMode.rising;
        }
      }
    });

    _orbController.stop();

    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SuggestPage()));

    if (mounted) {
      setState(() {
        for (var orb in orbs) {
          orb.mode = BubbleMode.idle;
        }
        _isLoading = false;
      });
      _orbController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ColoredBox(color: LuxiColors.background),
          LayoutBuilder(builder: (context, constraints) {
            _orbViewport = constraints.biggest;
            return Stack(children: orbs.map((orb) => Positioned(
              left: orb.x * constraints.maxWidth - orb.size / 2,
              top: orb.y * constraints.maxHeight - orb.size / 2,
              child: _OrbBubble(orb: orb),
            )).toList());
          }),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to Luxi",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: LuxiColors.sky),
                ),
                const SizedBox(height: 50),
                Container(
                  decoration: BoxDecoration(
                    color: LuxiColors.buttonPurple,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: LuxiColors.buttonPurple.withValues(alpha: 0.42),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _goToSuggestPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LuxiColors.buttonPurple,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    ),
                    child: const Text(
                      "START PROJECT",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
enum BubbleMode { idle, falling, waiting, rising }

class SectionLine {
  final String text;
  final bool isBullet;
  final bool isNumbered;
  final bool isCheckbox;
  bool isChecked;

  SectionLine(this.text, {this.isBullet = false, this.isNumbered = false, this.isCheckbox = false, this.isChecked = false});
}

class Orb {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double dx = Random().nextDouble() * 0.0022 - 0.0011;
  double dy = Random().nextDouble() * 0.002 - 0.001;
  double size = 40 + Random().nextDouble() * 80;
  int layer = Random().nextInt(3);
  late Color color;
  BubbleMode mode = BubbleMode.idle;
  DateTime? waitStartTime;

  Orb() {
    color = Colors.white.withValues(alpha: 0.55);
  }

 void move(double width, double height) {
    if (width <= 0 || height <= 0) return;
    final horizontalRadius = size / width;
    final verticalRadius = size / height;
    switch (mode) {
      case BubbleMode.idle:
        x += dx;
        y += dy;
        if (x < horizontalRadius || x > 1 - horizontalRadius) dx = -dx;
        if (y < verticalRadius || y > 1 - verticalRadius) dy = -dy;
        break;

      case BubbleMode.falling:
        y += 0.006 + 0.002 * sin(y * height / 35);
        x += dx * 0.65;
        if (y > 1 - verticalRadius) {
          y = 1 - verticalRadius;
          mode = BubbleMode.waiting;
          waitStartTime = DateTime.now();
        }
        break;

      case BubbleMode.waiting:
        if (waitStartTime != null && 
            DateTime.now().difference(waitStartTime!).inMilliseconds > 1200) {
          mode = BubbleMode.rising;
        }
        break;

      case BubbleMode.rising:
        y -= 0.006 + 0.0025 * sin(y * height / 50);
        x += dx * 0.5;
        if (y < -verticalRadius) mode = BubbleMode.idle;
        break;
    }
  }
}

class _OrbBubble extends StatelessWidget {
  const _OrbBubble({required this.orb});

  final Orb orb;

  @override
  Widget build(BuildContext context) => Container(
        width: orb.size,
        height: orb.size,
        decoration: BoxDecoration(
          color: const Color(0xFF9C78FF).withValues(alpha: 0.25),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: const Color(0xFF9C78FF).withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 3)],
        ),
      );
}

class Project {
  final String title;
  final String description;
  Project({required this.title, required this.description});
}

class ProjectStep {
  const ProjectStep({required this.number, required this.title, required this.instructions, required this.checkpoint, required this.category});

  final int number;
  final String title;
  final String instructions;
  final String checkpoint;
  final String category;
}

class InstructionSection {
  const InstructionSection({required this.title, required this.text});

  final String title;
  final String text;
}

class SuggestPage extends StatefulWidget {
  const SuggestPage({super.key});

  @override
  State<SuggestPage> createState() => _SuggestPageState();
}

class _SuggestPageState extends State<SuggestPage> with SingleTickerProviderStateMixin {
  final List<String> fixedCourses = ["ECSE2100", "ECSE4090", "ECSE4490"];//["ENGR2350", "ECSE2610", "ECSE2500"];
  String _outline = '';
  String _expandedText = '';
  String? _error;
  final Set<String> _completedSteps = {};
  bool _isLoading = true;
  bool _isExpanding = false;
  bool _isRepairingSteps = false;
  final ValueNotifier<int> _orbFrame = ValueNotifier(0);
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;

  late Timer _orbTimer;
  
  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),   // Longer to sync with rising orbs
    );
    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.linear),
    );

    _orbTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      for (final orb in orbs) {
        orb.move(_orbViewport.width, _orbViewport.height);
      }
      _orbFrame.value++;
    });
    _getSuggestion();
  }

  @override
  void dispose() {
    _finishOrbLoadingAnimation();
    _revealController.dispose();
    _orbTimer.cancel();
    _orbFrame.dispose();
    super.dispose();
  }

  void _startOrbLoadingAnimation({bool resetToFalling = false}) {
    for (final orb in orbs) {
      orb.waitStartTime = null;
      if (resetToFalling) {
        orb.mode = BubbleMode.falling;
      } else if (orb.mode == BubbleMode.idle) {
        orb.mode = BubbleMode.rising;
      }
    }
  }

  void _finishOrbLoadingAnimation() {
    for (final orb in orbs) {
      orb.waitStartTime = null;
      if (orb.mode != BubbleMode.idle) orb.mode = BubbleMode.rising;
    }
  }

  List<String> splitSections(String text) {
    return text.split(RegExp(r'(?=## )'));
  }

  Map<String, List<SectionLine>> parseAIResponse(String text) {
    final sections = <String, List<SectionLine>>{};
    String currentSection = '';
    final lines = text.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (RegExp(r'^(Materials|Steps|Instructions|Learning Outcomes)', caseSensitive: false).hasMatch(line)) {
        currentSection = line.replaceAll(':', '').trim();
        sections[currentSection] = [];
        continue;
      }

      if (currentSection.isEmpty) continue;
      bool isStep = line.toLowerCase().startsWith("step");
      bool isBullet = line.startsWith('- ');
      bool isNumbered = RegExp(r'^\d+\.').hasMatch(line);
      bool isCheckbox = line.startsWith('[ ]') || line.startsWith('[x]');

      sections[currentSection]!.add(
        SectionLine(
          line,
          isBullet: isBullet,
          isNumbered: isNumbered,
          isCheckbox: isCheckbox,
        ),
      );
    }
    return sections;
  }
  List<ProjectStep> _parseSteps(String text, {bool includeLastPartial = true}) {
    final steps = <ProjectStep>[];
    final heading = RegExp(r'^\s*(?:#{1,6}\s*)?(?:step\s*)?(\d+)(?:\s*\[(ELECTRONICS|CODING|SIMULATION|BUILD|ANALYSIS)\])?\s*[:.)\-–—]\s*(?:\[(ELECTRONICS|CODING|SIMULATION|BUILD|ANALYSIS)\]\s*)?(.+)$', caseSensitive: false);
    final checkpoint = RegExp(r'^\s*(?:[-*]\s*)?\*{0,2}checkpoint\*{0,2}:?\*{0,2}\s*(.*)$', caseSensitive: false);
    int? number;
    String title = '';
    String category = 'BUILD';
    final body = StringBuffer();
    String checkpointText = '';
    var inCodeBlock = false;

    void saveStep() {
      if (number == null) return;
      steps.add(ProjectStep(
        number: number,
        title: title,
        instructions: body.toString().trim(),
        checkpoint: checkpointText,
        category: category == 'BUILD' ? _guessStepCategory('$title ${body.toString()}') : category,
      ));
    }

    for (final line in text.split('\n')) {
      if (line.trimLeft().startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        if (number != null) body.writeln(line);
        continue;
      }
      final match = inCodeBlock ? null : heading.firstMatch(line);
      if (match != null) {
        saveStep();
        number = int.tryParse(match.group(1)!);
        final explicitCategory = (match.group(2) ?? match.group(3))?.toUpperCase();
        title = match.group(4)!.trim();
        category = explicitCategory ?? _guessStepCategory(title);
        body.clear();
        checkpointText = '';
        continue;
      }
      if (number == null) continue;
      final check = inCodeBlock
          ? null
          : checkpoint.firstMatch(_plainMarkdownLabel(line));
      if (check != null) {
        checkpointText = check.group(1)!.trim();
      } else {
        body.writeln(line);
      }
    }
    if (includeLastPartial) saveStep();
    return steps;
  }

  String _guessStepCategory(String text) {
    final value = text.toLowerCase();
    if (RegExp(r'\b(simulat|ltspice|matlab|simulink|waveform|virtual instrument)\w*\b').hasMatch(value)) return 'SIMULATION';
    if (RegExp(r'\b(cod(e|ing)|program|firmware|sketch|python|arduino ide|script|software)\w*\b').hasMatch(value)) return 'CODING';
    if (RegExp(r'\b(wir(e|ing)|circuit|breadboard|resistor|capacitor|component|solder|voltage|current|sensor|load cell)\w*\b').hasMatch(value)) return 'ELECTRONICS';
    if (RegExp(r'\b(measur|calculat|plot|analy[sz]|data|result|test)\w*\b').hasMatch(value)) return 'ANALYSIS';
    return 'BUILD';
  }

  List<ProjectStep> _mergeSteps(List<ProjectStep> outlineSteps, List<ProjectStep> detailedSteps) {
    final remaining = {for (final step in detailedSteps) step.number: step};
    final merged = <ProjectStep>[];
    for (final outlineStep in outlineSteps) {
      final detail = remaining.remove(outlineStep.number);
      if (detail == null) {
        merged.add(outlineStep);
      } else {
        merged.add(ProjectStep(
          number: outlineStep.number,
          title: outlineStep.title,
          instructions: detail.instructions,
          checkpoint: detail.checkpoint,
          category: detail.category,
        ));
      }
    }
    merged.addAll(remaining.values);
    return merged;
  }

  String _plainMarkdownLabel(String value) =>
      value.replaceAll(RegExp(r'[*_`~]'), '').trim();

  String _stepInstructionsPrompt(String outline, List<ProjectStep> steps) {
    final requestedSteps = steps
        .map((step) => '${step.number}. ${step.title}')
        .join('\n');
    return '''You are writing beginner-ready instructions for one part of an engineering project.

FULL PROJECT OUTLINE:
$outline

Write instructions ONLY for these steps, preserving their exact numbers, titles, and order:
$requestedSteps

For each requested step, use exactly this format:
## Step N [CATEGORY]: Exact title from the outline
### WHAT YOU NEED
List exact parts/tools/software, quantities, values, and versions needed for this step.
### DO THIS
1. Give one concrete action, including exact values, text, connections, or controls.
2. Give the next concrete action.
3. Give the next concrete action.
### HOW TO DO IT
Explain unfamiliar terms and operations in beginner language. Do not assume the reader knows how to use the hardware or software.
### CHECK YOUR RESULT
Describe something observable that confirms the step worked.
### IF IT DOES NOT WORK
Give a specific likely cause and an action to fix it.
Checkpoint: State one specific observable result that means this step is complete.
### INCLUDE AN UNDERSTANDING SECTION 
Give the user a checkpoint on whether they actually understand the step. Include a short question or example that tests and tries to prvoe their understanding of the concept behind the step they just performed. Explain the relation to that course, and how related ideas can be related to the other courses a student is taking (if possible).
Choose CATEGORY from ELECTRONICS, CODING, SIMULATION, BUILD, or ANALYSIS. Add the details that fit the category:
- ELECTRONICS: state when power must be disconnected; name both endpoints for each wire; include pin labels, polarity, and a safe power-up check.
- CODING: identify the exact app/IDE, file name and location, provide complete runnable code (not fragments) when code is needed, explain how to run/upload it, and describe expected output.
- SIMULATION: name the software and exact menus/buttons; specify every component/model, parameter value, connection, analysis/run setting, and which graph/result to inspect. Explain how to create and save the model.
- ANALYSIS: name the data to collect, show formulas with units, walk through each calculation, and explain how to interpret the result and check it for mistakes.
- BUILD: give dimensions, materials, tool use, assembly order, and a stability/safety check where applicable.

Never leave a section blank. Do not refer to another or future step. Do not tell the reader to search the web or look up missing information. Do not omit, renumber, reorder, combine, or add steps. Return only the requested step sections in Markdown.''';
  }

  List<ProjectStep> _stepsNeedingInstructions(List<ProjectStep> outlineSteps, List<ProjectStep> detailedSteps) {
    final detailsByNumber = {for (final step in detailedSteps) step.number: step};
    return outlineSteps.where((step) {
      final detail = detailsByNumber[step.number];
      if (detail == null || detail.checkpoint.trim().isEmpty) return true;
      final sections = _instructionSections(detail.instructions);
      const requiredSections = [
        'WHAT YOU NEED',
        'DO THIS',
        'HOW TO DO IT',
        'CHECK YOUR RESULT',
        'IF IT DOES NOT WORK',
        'UNDERSTANDING CHECKPOINT',
      ];
      for (final required in requiredSections) {
        if (!sections.any(
          (section) =>
              section.title == required && section.text.trim().isNotEmpty,
        )) {
          return true;
        }
      }
      final doThis = sections.firstWhere((section) => section.title == 'DO THIS').text;
      final actions = RegExp(r'^\s*(?:[-*+]\s+|\d+[.)]\s+)', multiLine: true)
          .allMatches(doThis)
          .length;
      return actions < 3;
    }).toList();
  }

  List<InstructionSection> _instructionSections(String instructions) {
    final sectionHeading = RegExp(
      r'^###\s*(WHAT YOU NEED|DO THIS|HOW TO DO IT|CHECK YOUR RESULT|IF IT DOES NOT WORK)\s*:?\s*$',
      multiLine: true,
      caseSensitive: false,
    );
    final sections = <InstructionSection>[];
    String title = 'OVERVIEW';
    final body = StringBuffer();
    for (final line in instructions.split('\n')) {
      final match = sectionHeading.firstMatch(_plainMarkdownLabel(line).trimRight());
      if (match != null) {
        if (body.toString().trim().isNotEmpty) {
          sections.add(InstructionSection(title: title, text: body.toString().trim()));
        }
        title = match.group(1)!.toUpperCase();
        body.clear();
      } else {
        body.writeln(line);
      }
    }
    if (body.toString().trim().isNotEmpty) {
      sections.add(InstructionSection(title: title, text: body.toString().trim()));
    }
    return sections;
  }

  Future<void> _getSuggestion() async {
    if (!mounted) return;
    var currentStage = 'the project outline';
    setState(() {
      _isLoading = true;
      _isExpanding = false;
      _isRepairingSteps = false;
      _outline = '';
      _expandedText = '';
      _error = null;
      _completedSteps.clear();
      _revealController.reset();
      _startOrbLoadingAnimation(resetToFalling: true);
    });

    try {
      final outline = await askAI(
        '''You are an expert beginner-friendly engineering tutor.

Create a project based on:
${fixedCourses.join(", ")}

Choose as many steps as this project actually needs. There is no maximum and no target count; do not stop at 11 or any other conventional number. Include every necessary phase in chronological order: prerequisites, planning/design, setup, build/model, coding, simulation or analysis when relevant, integration, testing, troubleshooting, and final verification. Never start in the middle of a project. Use continuous numbering with one clear, actionable title per step.

Return ONLY:
- Title
- Overview
- Materials
- Numbered step titles (NO explanations)''',
        fixedCourses,
      );

      if (!mounted) return;
      final outlineSteps = _parseSteps(outline);
      if (outlineSteps.isEmpty) {
        throw const FormatException(
          'The response did not contain any numbered project steps. Please try again.',
        );
      }
      setState(() {
        _outline = outline;
        _isLoading = false;
        _isExpanding = true;
      });

      var lastPaint = DateTime.fromMillisecondsSinceEpoch(0);
      var washStarted = false;
      currentStage = 'the detailed step instructions';
      final expectedCharacters = max(4000, outlineSteps.length * 2500);
      final completedBatches = <String>[];
      var expanded = '';
      String? lastBatchFailure;
      const batchSize = 3;
      for (var start = 0; start < outlineSteps.length; start += batchSize) {
        final batch = outlineSteps.skip(start).take(batchSize).toList();
        final batchPrompt = _stepInstructionsPrompt(outline, batch);
        try {
          final batchText = await askAI(
            batchPrompt,
            fixedCourses,
            includeCourseCatalog: false,
            onProgress: (partial) {
              if (!mounted) return;
              if (!washStarted) {
                washStarted = true;
                for (final orb in orbs) {
                  orb.mode = BubbleMode.rising;
                }
              }
              final visibleText = [...completedBatches, partial].join('\n\n');
              final target = (visibleText.length / expectedCharacters).clamp(0.0, 1.0).toDouble();
              if (target > _revealController.value + 0.006) {
                _revealController.animateTo(target, duration: const Duration(milliseconds: 120), curve: Curves.linear);
              }
              final now = DateTime.now();
              if (now.difference(lastPaint).inMilliseconds < 250) return;
              lastPaint = now;
              setState(() => _expandedText = visibleText);
            },
          );
          completedBatches.add(batchText);
        } catch (error) {
          // Keep going so one overloaded request does not discard later batches.
          lastBatchFailure ??= error.toString();
        }
        expanded = completedBatches.join('\n\n');
        if (mounted) setState(() => _expandedText = expanded);
      }
      if (!mounted) return;
      var incompleteSteps = _stepsNeedingInstructions(outlineSteps, _parseSteps(expanded));
      if (incompleteSteps.isNotEmpty) {
        setState(() {
          _expandedText = expanded;
          _isRepairingSteps = true;
        });
        currentStage = 'filling in incomplete step instructions';
        const repairBatchSize = 3;
        for (var start = 0; start < incompleteSteps.length; start += repairBatchSize) {
          final batch = incompleteSteps.skip(start).take(repairBatchSize).toList();
          final previousText = expanded;
          try {
            final repair = await askAI(
              _stepInstructionsPrompt(outline, batch),
              fixedCourses,
              includeCourseCatalog: false,
              onProgress: (partial) {
                if (!mounted) return;
                setState(() => _expandedText = '$previousText\n\n$partial');
              },
            );
            expanded = '$previousText\n\n$repair';
          } catch (error) {
            lastBatchFailure ??= error.toString();
          }
          if (mounted) setState(() => _expandedText = expanded);
        }
        incompleteSteps = _stepsNeedingInstructions(outlineSteps, _parseSteps(expanded));
      }
      if (mounted) {
        setState(() {
          _expandedText = expanded;
          _isExpanding = false;
          _isRepairingSteps = false;
          if (incompleteSteps.isNotEmpty) {
            final lastError = lastBatchFailure == null
                ? ''
                : ' Last service error: ${lastBatchFailure!.replaceFirst('Exception: ', '')}.';
            _error = 'The finished step directions are still here. ${incompleteSteps.length} step(s) still need directions. Use “Retry unfinished steps” to fill them in.$lastError';
          }
        });
        _revealController.animateTo(1, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isExpanding = false;
          _isRepairingSteps = false;
          _error = 'Could not create $currentStage: ${error.toString().replaceFirst('Exception: ', '')}';
        });
      }
      if (_outline.isNotEmpty) {
        _revealController.animateTo(1, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
      }
    } finally {
      _finishOrbLoadingAnimation();
    }
  }
  Future<void> _retryExpansion() async {
    final outline = _outline;
    if (outline.isEmpty) {
      await _getSuggestion();
      return;
    }

    final outlineSteps = _parseSteps(outline);
    final previousText = _expandedText;
    final missing = _stepsNeedingInstructions(
      outlineSteps,
      _parseSteps(previousText),
    );

    if (missing.isEmpty) {
      setState(() {
        _error = null;
        _isExpanding = false;
        _isRepairingSteps = false;
      });
      return;
    }

    setState(() {
      _error = null;
      _isExpanding = true;
      _isRepairingSteps = true;
    });
    _startOrbLoadingAnimation();

    try {
      var updatedText = previousText;
      String? lastBatchFailure;
      const batchSize = 3;
      for (var start = 0; start < missing.length; start += batchSize) {
        final batch = missing.skip(start).take(batchSize).toList();
        final batchBase = updatedText;
        try {
          final response = await askAI(
            _stepInstructionsPrompt(outline, batch),
            fixedCourses,
            includeCourseCatalog: false,
            onProgress: (partial) {
              if (!mounted) return;
              setState(() {
                _expandedText = batchBase.isEmpty
                    ? partial
                    : '$batchBase\n\n$partial';
              });
            },
          );
          updatedText = batchBase.isEmpty
              ? response
              : '$batchBase\n\n$response';
        } catch (error) {
          // Attempt the remaining missing batches even if this one is still unavailable.
          lastBatchFailure ??= error.toString();
        }
        if (mounted) setState(() => _expandedText = updatedText);
      }
      if (!mounted) return;
      final stillMissing = _stepsNeedingInstructions(
        outlineSteps,
        _parseSteps(updatedText),
      );

      setState(() {
        _expandedText = updatedText;
        _isExpanding = false;
        _isRepairingSteps = false;
        _error = stillMissing.isEmpty
            ? null
            : '${stillMissing.length} step(s) still need instructions. Your completed directions are still here; retry to request only the remaining steps.${lastBatchFailure == null ? '' : ' Last service error: ${lastBatchFailure!.replaceFirst('Exception: ', '')}'}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isExpanding = false;
        _isRepairingSteps = false;
        _error = 'Could not finish these steps: $error';
      });
    } finally {
      _finishOrbLoadingAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxiColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Project Suggestions'),
        backgroundColor: LuxiColors.background.withValues(alpha: 0.97),
        actions: [
          IconButton(
            tooltip: 'Generate another project',
            onPressed: (_isLoading || _isExpanding) ? null : _getSuggestion,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _orbViewport = constraints.biggest;
          final outlineSteps = _parseSteps(_outline);
          final steps = _mergeSteps(
            outlineSteps,
            _parseSteps(_expandedText, includeLastPartial: !_isExpanding),
          );
          final completedCount = steps.asMap().entries
              .where((entry) => _completedSteps.contains(
                    '${entry.key}-${entry.value.number}-${entry.value.title.trim()}',
                  ))
              .length;
          return Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: LuxiColors.background)),
              if (_outline.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_error == null) const CircularProgressIndicator(color: LuxiColors.important),
                        if (_error != null) const Icon(Icons.error_outline, size: 36, color: LuxiColors.vividBlue),
                        const SizedBox(height: 18),
                        Text(
                          _error ?? 'Creating your project…',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: LuxiColors.sky),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _getSuggestion,
                            style: FilledButton.styleFrom(
                              backgroundColor: LuxiColors.important,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Try again'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _revealAnimation,
                    builder: (context, _) => ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) {
                      if (_revealAnimation.value >= 0.999) {
                        return const LinearGradient(colors: [Colors.white, Colors.white]).createShader(bounds);
                      }
                      final cutoff = _revealAnimation.value.clamp(0.0, 1.0).toDouble();
                      final feather = (cutoff + 0.045).clamp(0.0, 1.0).toDouble();
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: const [Colors.white, Colors.white, Colors.transparent],
                        stops: [0.0, cutoff, feather],
                      ).createShader(bounds);
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 92, 18, 28),
                      children: [
                        Card(
                          color: LuxiColors.card,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: LuxiColors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: MarkdownBody(
                              data: _outline,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                h1: const TextStyle(fontSize: 24, height: 1.2, fontWeight: FontWeight.bold, color: LuxiColors.slate),
                                h2: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: LuxiColors.slate),
                                p: const TextStyle(height: 1.5, color: LuxiColors.slate),
                                listBullet: const TextStyle(fontSize: 16, color: LuxiColors.vividBlue),
                              ),
                            ),
                          ),
                        ),
                        if (steps.isNotEmpty)
                          Card(
                            color: LuxiColors.card,
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: LuxiColors.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'YOUR PROGRESS  ·  $completedCount OF ${steps.length} STEPS',
                                    style: const TextStyle(
                                      color: LuxiColors.slate,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: completedCount / steps.length,
                                      minHeight: 8,
                                      backgroundColor: LuxiColors.sky,
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        LuxiColors.important,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_isExpanding || _isLoading)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: LuxiColors.important),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(_isRepairingSteps
                                      ? 'Filling in missing step directions…'
                                      : 'Writing the step-by-step instructions…'),
                                ),
                              ],
                            ),
                          ),
                        if (steps.isNotEmpty)
                          ...steps.asMap().entries.map((entry) {
                            final stepIndex = entry.key;
                            final step = entry.value;
                            final stepId = '$stepIndex-${step.number}-${step.title.trim()}';
                            final isComplete = _completedSteps.contains(stepId);
                            final topicColors = _topicColors(step.category);
                            final categoryColor = topicColors.accent;
                            final cardColor = isComplete ? LuxiColors.completed : LuxiColors.card;
                            return Card(
                              key: ValueKey('step-card-$stepId'),
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              elevation: 0,
                              color: cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: LuxiColors.border),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  key: PageStorageKey('step-$stepId'),
                                  maintainState: true,
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                                  childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                                  iconColor: categoryColor,
                                  collapsedIconColor: categoryColor,
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: isComplete ? LuxiColors.checkGreen : categoryColor,
                                    child: isComplete
                                        ? const Icon(Icons.check, size: 18, color: LuxiColors.slate)
                                        : Text('${step.number}', style: const TextStyle(fontSize: 13, color: Colors.white)),
                                  ),
                                  title: Text(
                                    'Step ${step.number}: ${step.title}',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: isComplete ? LuxiColors.mutedText : LuxiColors.slate,
                                      decoration: isComplete ? TextDecoration.lineThrough : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: topicColors.surface.withValues(
                                          alpha: isComplete ? 0.55 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        step.category,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.7,
                                          color: isComplete ? LuxiColors.mutedText : topicColors.ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                  children: [
                                    if (step.instructions.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Text(
                                          _isExpanding ? 'Writing detailed directions for this step…' : 'Detailed directions are missing. Retry the unfinished steps below.',
                                          style: const TextStyle(color: LuxiColors.important, fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ..._instructionSections(step.instructions).map((section) {
                                      final labelColor = switch (section.title) {
                                        'WHAT YOU NEED' => LuxiColors.slate,
                                        'DO THIS' => LuxiColors.important,
                                        'HOW TO DO IT' => LuxiColors.slate,
                                        'CHECK YOUR RESULT' => LuxiColors.slate,
                                        'IF IT DOES NOT WORK' => LuxiColors.important,
                                        _ => categoryColor,
                                      };
                                      final labelSurface = switch (section.title) {
                                        'WHAT YOU NEED' => LuxiColors.cyan,
                                        'DO THIS' => LuxiColors.sky,
                                        'HOW TO DO IT' => LuxiColors.lavender,
                                        'CHECK YOUR RESULT' => LuxiColors.cyan,
                                        'IF IT DOES NOT WORK' => LuxiColors.lavender,
                                        _ => topicColors.surface,
                                      };
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: labelSurface,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                section.title,
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.65, color: labelColor),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            MarkdownBody(
                                              data: section.text,
                                              selectable: true,
                                              styleSheet: MarkdownStyleSheet(
                                                h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: LuxiColors.slate),
                                                h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: LuxiColors.slate),
                                                h3: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: LuxiColors.slate),
                                                p: TextStyle(height: 1.5, color: isComplete ? LuxiColors.mutedText : LuxiColors.slate),
                                                listBullet: TextStyle(color: labelColor),
                                                code: const TextStyle(color: LuxiColors.cyan, fontSize: 13),
                                                codeblockDecoration: BoxDecoration(color: LuxiColors.codeBackground, borderRadius: BorderRadius.circular(8)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    const Divider(color: LuxiColors.border),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          value: isComplete,
                                          activeColor: LuxiColors.checkGreen,
                                          checkColor: LuxiColors.slate,
                                          onChanged: (bool? checked) => setState(() {
                                            if (checked == true) {
                                              _completedSteps.add(stepId);
                                            } else {
                                              _completedSteps.remove(stepId);
                                            }
                                          }),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Text(
                                              'CHECKPOINT\n${step.checkpoint.isEmpty ? 'Complete the actions above and confirm the result before checking this off.' : step.checkpoint}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1.4,
                                                fontWeight: FontWeight.w600,
                                                color: isComplete ? LuxiColors.mutedText : LuxiColors.slate,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        if (_expandedText.isNotEmpty && steps.isEmpty)
                          Card(
                            color: const Color.fromARGB(255, 55, 36, 92),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: MarkdownBody(data: _expandedText, selectable: true),
                            ),
                          ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Some project steps need another try. $_error',
                                  style: const TextStyle(color: LuxiColors.sky),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: (_isLoading || _isExpanding) ? null : _retryExpansion,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Retry unfinished steps'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  ),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _orbFrame,
                    builder: (context, frame, child) => Stack(
                      children: orbs.map((orb) => Positioned(
                        left: orb.x * constraints.maxWidth - orb.size / 2,
                        top: orb.y * constraints.maxHeight - orb.size / 2,
                        child: _OrbBubble(orb: orb),
                      )).toList(),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _WashPainter(
                      animation: _revealController,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WashPainter extends CustomPainter {
  _WashPainter({required this.animation, required this.width, required this.height}) : super(repaint: animation);

  final Animation<double> animation;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value >= 1) return;
    final y = height * (1 - animation.value);
    final rect = Rect.fromLTWH(0, y - 30, width, 60);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, Color(0xAA9C78FF), Colors.transparent],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _WashPainter oldDelegate) =>
      oldDelegate.width != width || oldDelegate.height != height;
}
