import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'themes/theme_data.dart'; 

class IntrusionState {
  String id;
  TextEditingController thoughtCtrl = TextEditingController();
  TextEditingController themeCtrl = TextEditingController();
  double beliefStrength = 0.0;
  CognitiveDistortion? distortion;

  IntrusionState({required this.id});

  void dispose() {
    thoughtCtrl.dispose();
    themeCtrl.dispose();
  }
}

class AppData with ChangeNotifier {
  List<Session> sessions = [];
  ThemeMode themeMode = ThemeMode.system;
  Locale locale = const Locale('en', 'US');
  ThemeType currentTheme = ThemeType.mirror;
  bool isHighPerformance = true;

  String anchorPhraseEn = "You are safe. This is just a feeling.";
  String anchorPhrasePt = "Você está seguro. Isso é apenas um sentimento.";

  bool isCrisisMode = false;
  Session? currentEditingSession;

  Timer? _urgeTimer;
  int urgeSeconds = 0;
  bool isTimerRunning = false;

  TextEditingController triggerCtrl = TextEditingController();
  ContextTag selectedContext = ContextTag.internal;
  TriggerType? selectedTriggerType;
  
  List<IntrusionState> activeIntrusions = [IntrusionState(id: const Uuid().v4())];

  double anxietyBefore = 0.0;
  double anxietyPeak = 0.0;
  double anxietyAfter = 0.0;
  double senseOfControl = 0.0;
  
  double urgeBefore = 0.0;
  double urgePeak = 0.0;
  double urgeAfter = 0.0;

  List<TextEditingController> compulsionUrgesCtrls = [TextEditingController()];
  List<CompulsionAction> selectedActions = [];
  bool resisted = false;
  bool partial = false;
  FeelingStatus? selectedFeeling;

  TextEditingController predictedOutcomeCtrl = TextEditingController();
  TextEditingController actualOutcomeCtrl = TextEditingController();
  double fearConfidence = 0.0;
  double surpriseLevel = 0.0;
  TextEditingController recoveryMinutesCtrl = TextEditingController();

  int crisisStep = 0;
  int crisisSeconds = 0;
  bool isCrisisTimerRunning = false;
  Timer? _crisisTimer;
  bool isStandardCrisis = false;
  
  bool get isPostCrisisLog => isStandardCrisis;

  AppData() {
    _loadPreferences();
    if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          isHighPerformance = false;
        }
    }
  }

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  String get currentAnchorPhrase {
    return locale.languageCode == 'pt' ? anchorPhrasePt : anchorPhraseEn;
  }

  void refreshUI() {
    notifyListeners();
  }

  void updateAnchorPhrase(String phrase) {
    if (locale.languageCode == 'pt') {
      anchorPhrasePt = phrase;
    } else {
      anchorPhraseEn = phrase;
    }
    _savePreferences();
    notifyListeners();
  }

  void toggleUrgeTimer() {
    if (isTimerRunning) {
      _urgeTimer?.cancel();
      isTimerRunning = false;
    } else {
      isTimerRunning = true;
      _urgeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        urgeSeconds++;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void resetUrgeTimer() {
    _urgeTimer?.cancel();
    urgeSeconds = 0;
    isTimerRunning = false;
    notifyListeners();
  }

  String get formattedUrgeTime {
    int m = urgeSeconds ~/ 60;
    int s = urgeSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void toggleCrisisMode() {
    isCrisisMode = !isCrisisMode;
    notifyListeners();
  }

  String get formattedCrisisTime {
    int m = crisisSeconds ~/ 60;
    int s = crisisSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void startCrisisTimer() {
    if (isCrisisTimerRunning) return;
    isCrisisTimerRunning = true;
    _crisisTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      crisisSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void endCrisisSession() {
    _crisisTimer?.cancel();
    isCrisisTimerRunning = false;
    crisisStep = 1;
    notifyListeners();
  }

  void proceedToCrisisLog() {
    isCrisisMode = false;
    crisisStep = 0;
    isStandardCrisis = true;
    notifyListeners();
  }

  void quickSaveCrisisAndExit() {
    final String newSessionId = const Uuid().v4();
    final newSession = Session(
       id: newSessionId,
       timestamp: DateTime.now(),
       triggerText: "Crisis Session",
       contextTag: ContextTag.internal,
       sessionType: SessionType.crisis,
       intrusions: [],
       distress: DistressMetrics(sessionId: newSessionId),
       response: ResponseMechanism(sessionId: newSessionId, compulsionUrges: [], compulsionActions: []),
       learning: Learning(sessionId: newSessionId)
    );
    sessions.insert(0, newSession);
    _savePreferences();
    isCrisisMode = false;
    crisisStep = 0;
    crisisSeconds = 0;
    isStandardCrisis = false;
    notifyListeners();
  }

  void addIntrusionField() {
    activeIntrusions.add(IntrusionState(id: const Uuid().v4()));
    notifyListeners();
  }

  void removeIntrusionField(String id) {
    if (activeIntrusions.length > 1) {
      final index = activeIntrusions.indexWhere((i) => i.id == id);
      if (index != -1) {
        activeIntrusions[index].dispose();
        activeIntrusions.removeAt(index);
        notifyListeners();
      }
    }
  }

  void addCompulsionField() {
    compulsionUrgesCtrls.add(TextEditingController());
    notifyListeners();
  }

  void removeCompulsionField(int index) {
    if (compulsionUrgesCtrls.length > 1) {
      compulsionUrgesCtrls[index].dispose();
      compulsionUrgesCtrls.removeAt(index);
      notifyListeners();
    }
  }

  void toggleCompulsionAction(CompulsionAction action) {
    if (selectedActions.contains(action)) {
      selectedActions.remove(action);
    } else {
      selectedActions.add(action);
    }
    notifyListeners();
  }

  void setFeeling(FeelingStatus status) {
    selectedFeeling = status;
    notifyListeners();
  }

  void clearForm() {
    currentEditingSession = null;
    triggerCtrl.clear();
    selectedContext = ContextTag.internal;
    selectedTriggerType = null;
    
    for (var state in activeIntrusions) {
      state.dispose();
    }
    activeIntrusions = [IntrusionState(id: const Uuid().v4())];
    
    anxietyBefore = 0.0;
    anxietyPeak = 0.0;
    anxietyAfter = 0.0;
    senseOfControl = 0.0;

    urgeBefore = 0.0;
    urgePeak = 0.0;
    urgeAfter = 0.0;

    for (var c in compulsionUrgesCtrls) {
      c.dispose();
    }
    compulsionUrgesCtrls = [TextEditingController()];
    selectedActions = [];
    resisted = false;
    partial = false;
    selectedFeeling = null;
    isStandardCrisis = false;
    resetUrgeTimer();

    predictedOutcomeCtrl.clear();
    actualOutcomeCtrl.clear();
    fearConfidence = 0.0;
    surpriseLevel = 0.0;
    recoveryMinutesCtrl.clear();

    notifyListeners();
  }

  void loadSessionToEdit(Session session) {
    currentEditingSession = session;
    
    triggerCtrl.text = session.triggerText;
    selectedContext = session.contextTag;
    selectedTriggerType = session.triggerType;
    isStandardCrisis = session.sessionType == SessionType.crisis;
    
    for (var state in activeIntrusions) {
      state.dispose();
    }
    activeIntrusions.clear();

    if (session.intrusions.isEmpty) {
        activeIntrusions.add(IntrusionState(id: const Uuid().v4()));
    } else {
        for (var intr in session.intrusions) {
            var state = IntrusionState(id: intr.id);
            state.thoughtCtrl.text = intr.thoughtText;
            state.themeCtrl.text = intr.themeTag ?? '';
            state.beliefStrength = intr.beliefStrengthBefore.toDouble();
            state.distortion = intr.distortion;
            activeIntrusions.add(state);
        }
    }
    
    anxietyBefore = session.distress.anxietyBefore.toDouble();
    anxietyPeak = session.distress.anxietyPeak.toDouble();
    anxietyAfter = session.distress.anxietyAfter.toDouble();
    senseOfControl = session.distress.senseOfControl.toDouble();

    urgeBefore = session.distress.urgeBefore.toDouble();
    urgePeak = session.distress.urgePeak.toDouble();
    urgeAfter = session.distress.urgeAfter.toDouble();

    for (var c in compulsionUrgesCtrls) {
      c.dispose();
    }
    compulsionUrgesCtrls.clear();
    if (session.response.compulsionUrges.isEmpty) {
        compulsionUrgesCtrls.add(TextEditingController());
    } else {
        for (var text in session.response.compulsionUrges) {
            compulsionUrgesCtrls.add(TextEditingController(text: text));
        }
    }
    
    selectedActions = List.from(session.response.compulsionActions);
    resisted = session.response.resisted;
    partial = session.response.partial;
    urgeSeconds = session.response.delaySeconds;
    selectedFeeling = session.feeling;

    predictedOutcomeCtrl.text = session.learning.predictedOutcome;
    actualOutcomeCtrl.text = session.learning.actualOutcome;
    surpriseLevel = session.learning.surpriseLevel.toDouble();
    fearConfidence = session.learning.fearConfidence.toDouble();
    recoveryMinutesCtrl.text = session.learning.recoveryMinutes.toString();

    notifyListeners();
  }

  bool saveSession() {
    if (triggerCtrl.text.isEmpty && activeIntrusions.every((i) => i.thoughtCtrl.text.isEmpty)) {
      return false;
    }

    final String newSessionId = currentEditingSession?.id ?? const Uuid().v4();

    List<Intrusion> savedIntrusions = activeIntrusions.where((state) => state.thoughtCtrl.text.isNotEmpty).map((state) {
        return Intrusion(
          id: state.id,
          sessionId: newSessionId,
          thoughtText: state.thoughtCtrl.text,
          beliefStrengthBefore: state.beliefStrength.round(),
          beliefStrengthAfter: state.beliefStrength.round(),
          themeTag: state.themeCtrl.text.isNotEmpty ? state.themeCtrl.text : null,
          distortion: state.distortion,
        );
    }).toList();

    final distress = DistressMetrics(
        sessionId: newSessionId,
        anxietyBefore: anxietyBefore.round(),
        anxietyPeak: anxietyPeak.round(),
        anxietyAfter: anxietyAfter.round(),
        senseOfControl: senseOfControl.round(),
        urgeBefore: urgeBefore.round(),
        urgePeak: urgePeak.round(),
        urgeAfter: urgeAfter.round()
    );

    List<String> urgesList = compulsionUrgesCtrls
        .map((c) => c.text)
        .where((t) => t.isNotEmpty)
        .toList();

    final response = ResponseMechanism(
        sessionId: newSessionId,
        compulsionUrges: urgesList,
        compulsionActions: selectedActions,
        delaySeconds: urgeSeconds,
        resisted: resisted,
        partial: partial
    );

    final learning = Learning(
        sessionId: newSessionId,
        predictedOutcome: predictedOutcomeCtrl.text,
        actualOutcome: actualOutcomeCtrl.text,
        fearConfidence: fearConfidence.round(),
        surpriseLevel: surpriseLevel.round(),
        recoveryMinutes: int.tryParse(recoveryMinutesCtrl.text) ?? 0
    );

    final newSession = Session(
        id: newSessionId,
        timestamp: currentEditingSession?.timestamp ?? DateTime.now(),
        editedAt: currentEditingSession != null ? DateTime.now() : null, 
        triggerText: triggerCtrl.text,
        contextTag: selectedContext,
        triggerType: selectedTriggerType,
        sessionType: isStandardCrisis ? SessionType.crisis : SessionType.standard,
        feeling: selectedFeeling,
        intrusions: savedIntrusions,
        distress: distress,
        response: response,
        learning: learning,
    );

    if (currentEditingSession != null) {
      int index = sessions.indexWhere((s) => s.id == currentEditingSession!.id);
      if (index != -1) {
        sessions[index] = newSession;
      }
    } else {
      sessions.insert(0, newSession);
    }

    _savePreferences();
    clearForm();
    return true;
  }

  void deleteSession(String id) {
    sessions.removeWhere((s) => s.id == id);
    _savePreferences();
    if (currentEditingSession?.id == id) {
      clearForm();
    }
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? themePref = prefs.getString('theme_mode');
    if (themePref == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (themePref == 'light') {
      themeMode = ThemeMode.light;
    }

    final String? langPref = prefs.getString('language_code');
    if (langPref != null) {
      locale = Locale(langPref);
    }

    final int? themeTypeIndex = prefs.getInt('theme_type_index');
    if (themeTypeIndex != null &&
        themeTypeIndex >= 0 &&
        themeTypeIndex < ThemeType.values.length) {
      currentTheme = ThemeType.values[themeTypeIndex];
    }
    
    final String? savedAnchorEn = prefs.getString('anchor_phrase_en');
    if (savedAnchorEn != null && savedAnchorEn.isNotEmpty) {
      anchorPhraseEn = savedAnchorEn;
    }

    final String? savedAnchorPt = prefs.getString('anchor_phrase_pt');
    if (savedAnchorPt != null && savedAnchorPt.isNotEmpty) {
      anchorPhrasePt = savedAnchorPt;
    }

    final String? sessionsJson = prefs.getString('ocd_sessions');
    if (sessionsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        sessions = decoded.map((e) => Session.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error loading sessions: $e");
      }
    }
    
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String sessionsJson = jsonEncode(sessions.map((e) => e.toJson()).toList());
    await prefs.setString('ocd_sessions', sessionsJson);

    String themeStr = 'system';
    if (themeMode == ThemeMode.dark) {
      themeStr = 'dark';
    } else if (themeMode == ThemeMode.light) {
      themeStr = 'light';
    }
    
    await prefs.setString('theme_mode', themeStr);
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setInt('theme_type_index', currentTheme.index);
    
    await prefs.setString('anchor_phrase_en', anchorPhraseEn);
    await prefs.setString('anchor_phrase_pt', anchorPhrasePt);
  }

  Future<void> exportBackup() async {
    final String jsonStr = jsonEncode(sessions.map((e) => e.toJson()).toList());
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    await _shareFile(jsonStr, "ocd_logger_backup_$dateStr.json");
  }

  Future<void> exportSessionTxt(Session session) async {
    StringBuffer txt = StringBuffer();
    txt.writeln("--- OCD Logger Session ---");
    txt.writeln("Date: ${DateFormat('yyyy-MM-dd HH:mm').format(session.timestamp)}");
    if (session.triggerText.isNotEmpty) {
      txt.writeln("Trigger: ${session.triggerText}");
    }
    txt.writeln("Context: ${translateContext(session.contextTag)}");
    
    txt.writeln("\n--- Intrusions ---");
    for (var intr in session.intrusions) {
      txt.writeln("- ${intr.thoughtText} (Belief: ${intr.beliefStrengthBefore}%)");
      if (intr.distortion != null) {
        txt.writeln("  Distortion: ${translateDistortion(intr.distortion!)}");
      }
    }
    
    txt.writeln("\n--- Distress ---");
    txt.writeln("Anxiety (Peak): ${session.distress.anxietyPeak}");
    txt.writeln("Urge (Peak): ${session.distress.urgePeak}");
    
    txt.writeln("\n--- Response ---");
    txt.writeln("Resisted: ${session.response.resisted ? 'Yes' : 'No'}");
    txt.writeln("Delay: ${session.response.delaySeconds}s");
    
    if (session.response.compulsionUrges.isNotEmpty) {
      txt.writeln("Compulsions:");
      for (var c in session.response.compulsionUrges) {
        txt.writeln("  - $c");
      }
    }
    
    txt.writeln("\n--- Learning ---");
    if (session.learning.actualOutcome.isNotEmpty) {
      txt.writeln("Actual Outcome: ${session.learning.actualOutcome}");
    }
    
    final dateStr = DateFormat('yyyyMMdd_HHmm').format(session.timestamp);
    await _shareFile(txt.toString(), "ocd_session_$dateStr.txt");
  }

  Future<bool> importBackup() async {
    try {
      FileType pickerType = FileType.custom;
      List<String>? extensions = ['json'];
      bool shouldLoadBytes = false;

      if (!kIsWeb && Platform.isIOS) {
        // iOS: use any file type and load bytes due to LiveContainer sandbox
        pickerType = FileType.any;
        extensions = null;
        shouldLoadBytes = true;
      } else if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
        // Desktop: just use the path, don't load bytes into memory
        shouldLoadBytes = false;
      } else if (kIsWeb) {
        // Web: load bytes
        shouldLoadBytes = true;
      }

      debugPrint("importBackup - Platform: ${Platform.operatingSystem}, withData: $shouldLoadBytes");

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: pickerType,
        allowedExtensions: extensions,
        withData: shouldLoadBytes,
      );
          
      if (result != null && result.files.isNotEmpty) {
        var file = result.files.single;
        debugPrint("File picked: ${file.name}, path: ${file.path}, hasBytes: ${file.bytes != null}");
        
        if (!file.name.toLowerCase().endsWith('.json')) {
            debugPrint("Invalid file type. Expected .json, got: ${file.name}");
            return false;
        }

        String content;
        
        // Try to read file content - prefer path for desktop, bytes for mobile/web
        if (file.bytes != null && file.bytes!.isNotEmpty) {
          // Bytes available - use them (iOS, Web)
          debugPrint("Reading from file bytes");
          content = utf8.decode(file.bytes!);
        } else if (file.path != null && file.path!.isNotEmpty) {
          // Fallback to path-based reading (Desktop, or iOS if bytes unavailable)
          debugPrint("Reading from file path: ${file.path}");
          try {
            content = await File(file.path!).readAsString();
          } catch (pathError) {
            debugPrint("Failed to read from path: $pathError");
            return false;
          }
        } else {
          // Neither bytes nor path available
          debugPrint("No file content available (both bytes and path are null/empty)");
          return false;
        }

        debugPrint("File content read successfully, decoding JSON...");
        final List<dynamic> jsonList = jsonDecode(content);
        sessions = jsonList.map((e) => Session.fromJson(e)).toList();
        _savePreferences();
        notifyListeners();
        debugPrint("Backup imported successfully. Sessions: ${sessions.length}");
        return true;
      } else {
        debugPrint("No file selected");
      }
      return false;
    } catch (e) {
      debugPrint("Import Error: $e");
      return false;
    }
  }

  Future<void> _shareFile(String content, String fileName) async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      try {
        String? outputFile = await FilePicker.platform
            .saveFile(dialogTitle: 'Save File', fileName: fileName);
        if (outputFile != null) {
          await File(outputFile).writeAsString(content);
        }
      } catch (e) {
        debugPrint("Error saving: $e");
      }
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], text: 'OCD Logger Export');
    }
  }

  String translateContext(ContextTag tag) {
    return t(tag.name);
  }

  String translateTriggerType(TriggerType tag) {
    return t(tag.name);
  }

  String translateFeeling(FeelingStatus feeling) {
    return t(feeling.name);
  }

  String translateDistortion(CognitiveDistortion distortion) {
    return t(distortion.name);
  }

  String t(String key) {
    Map<String, String> pt = {
      'app_title': 'OCD Logger',
      'crisis_mode': 'Modo Crise',
      'trigger': 'Gatilho',
      'trigger_hint': 'O que aconteceu?',
      'context': 'Contexto',
      'trigger_type_optional': 'Tipo de Gatilho (opcional)',
      'was_crisis': 'Foi uma crise?',
      'intrusions': 'Intrusões',
      'intrusion_hint': 'E se...',
      'theme_tag_optional': 'Tag de Tema (opcional)',
      'belief_strength': 'Força da Crença',
      'cognitive_distortion': 'Distorção Cognitiva',
      'add_intrusion': 'Adicionar Intrusão',
      'distress_metrics': 'Métricas de Sofrimento',
      'anxiety': 'Ansiedade',
      'sense_of_control': 'Senso de Controle',
      'urge': 'Urgência',
      'response': 'Resposta / Ritual',
      'urge_timer': 'Timer de Resistência',
      'manual_delay': 'Atraso Manual',
      'edit_manually': 'Editar Manualmente',
      'compulsions': 'Compulsões',
      'add_compulsion': '+ Compulsão',
      'how_feel': 'Como você se sente?',
      'resisted': 'Resistiu?',
      'nice_work': 'Muito Bem',
      'thats_okay': 'Tudo Bem',
      'learning': 'Aprendizado / ERP',
      'prediction': 'Previsão (O que vai acontecer?)',
      'fear_confidence': 'Confiança no Medo',
      'actual': 'Resultado Real',
      'surprise': 'Nível de Surpresa',
      'save': 'Salvar Sessão',
      'update_session': 'Atualizar Sessão',
      'history': 'Histórico',
      'export': 'Exportar', 
      'empty': 'Vazio',
      'no_data': 'Nenhum Dado Ainda',
      'settings': 'Configurações',
      'anchor_label': 'Frase de Âncora',
      'anchor_hint': 'Você está seguro.',
      'visual_styles': 'Estilos Visuais',
      'you_survived': 'Você Sobreviveu',
      'end_session': 'Encerrar Sessão',
      'add_details_now': 'Adicionar Detalhes Agora',
      'save_and_exit': 'Salvar & Sair',
      'editing': 'Editando',
      'edited': 'Editado',
      'delete_session': 'Apagar Sessão',
      'delete_confirm': 'Tem certeza que deseja apagar?',
      'theme_mirror': 'Espelho (Neutro)',
      'theme_midnight': 'Meia-Noite',
      'theme_dawn': 'Amanhecer',
      'theme_ocean': 'Oceano',
      'cancel': 'Cancelar',
      'confirm': 'Confirmar',
      'ok': 'OK',
      'dark_mode': 'Modo Escuro',
      'language': 'Idioma',
      'backup': 'Backup',
      'restore': 'Restaurar',
      'tap_to_start': 'Toque para Iniciar',
      'resisting': 'Resistindo...',
      
      'error': 'Erro',
      'fill_trigger': 'Por favor, preencha o gatilho ou pensamento.',
      'session_logged': 'Sessão registrada com sucesso.',
      'session_updated': 'Sessão atualizada com sucesso.',
      'backup_restored': 'Backup restaurado com sucesso.',

      'none': 'Nenhum',
      'catastrophizing': 'Catastrofização',
      'allOrNothing': 'Tudo ou Nada',
      'mindReading': 'Leitura Mental',
      'fortuneTelling': 'Adivinhação',
      'emotionalReasoning': 'Raciocínio Emocional',
      'overgeneralization': 'Supergeneralização',
      'muchBetter': 'Muito Melhor',
      'better': 'Melhor',
      'same': 'Igual',
      'worse': 'Pior',
      'muchWorse': 'Muito Pior',
      'location': 'Local',
      'social': 'Social',
      'internal': 'Interno',
      'work': 'Trabalho',
      'other': 'Outro',
      'thought': 'Pensamento',
      'memory': 'Lembrança',
      'sensation': 'Sensação',
      'image': 'Imagem',
      'event': 'Evento',
      'interaction': 'Interação',
      'uncertainty': 'Incerteza',
    };
    
    Map<String, String> en = {
      'app_title': 'OCD Logger',
      'crisis_mode': 'Crisis Mode',
      'trigger': 'Trigger',
      'trigger_hint': 'What happened?',
      'context': 'Context',
      'trigger_type_optional': 'Trigger Type (optional)',
      'was_crisis': 'Was this a crisis?',
      'intrusions': 'Intrusions',
      'intrusion_hint': 'What if...',
      'theme_tag_optional': 'Theme Tag (optional)',
      'belief_strength': 'Belief Strength',
      'cognitive_distortion': 'Cognitive Distortion',
      'add_intrusion': 'Add Intrusion',
      'distress_metrics': 'Distress Metrics',
      'anxiety': 'Anxiety',
      'sense_of_control': 'Sense of Control',
      'urge': 'Urge',
      'response': 'Response / Ritual',
      'urge_timer': 'Resistance Timer',
      'manual_delay': 'Manual Delay',
      'edit_manually': 'Edit Manually',
      'compulsions': 'Compulsions',
      'add_compulsion': '+ Compulsion',
      'how_feel': 'How do you feel?',
      'resisted': 'Resisted?',
      'nice_work': 'Nice Work',
      'thats_okay': "That's Okay",
      'learning': 'Learning / ERP',
      'prediction': 'Prediction (What will happen?)',
      'fear_confidence': 'Fear Confidence',
      'actual': 'Actual Outcome',
      'surprise': 'Surprise Level',
      'save': 'Save Session',
      'update_session': 'Update Session',
      'history': 'History',
      'export': 'Export', 
      'empty': 'Empty',
      'no_data': 'No Data Yet',
      'settings': 'Settings',
      'anchor_label': 'Anchor Phrase',
      'anchor_hint': 'You are safe.',
      'visual_styles': 'Visual Styles',
      'you_survived': 'You Survived',
      'end_session': 'End Session',
      'add_details_now': 'Add Details Now',
      'save_and_exit': 'Save & Exit',
      'editing': 'Editing',
      'edited': 'Edited',
      'delete_session': 'Delete Session',
      'delete_confirm': 'Are you sure?',
      'theme_mirror': 'Mirror (Neutral)',
      'theme_midnight': 'Midnight',
      'theme_dawn': 'Dawn',
      'theme_ocean': 'Ocean',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'ok': 'OK',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'backup': 'Backup',
      'restore': 'Restore',
      'tap_to_start': 'Tap to Start',
      'resisting': 'Resisting...',

      'error': 'Error',
      'fill_trigger': 'Please fill in trigger or thought.',
      'session_logged': 'Session logged successfully.',
      'session_updated': 'Session updated successfully.',
      'backup_restored': 'Backup restored successfully.',
      
      'none': 'None',
      'catastrophizing': 'Catastrophizing',
      'allOrNothing': 'All or Nothing',
      'mindReading': 'Mind Reading',
      'fortuneTelling': 'Fortune Telling',
      'emotionalReasoning': 'Emotional Reasoning',
      'overgeneralization': 'Overgeneralization',
      'muchBetter': 'Much Better',
      'better': 'Better',
      'same': 'Same',
      'worse': 'Worse',
      'muchWorse': 'Much Worse',
      'location': 'Location',
      'social': 'Social',
      'internal': 'Internal',
      'work': 'Work',
      'other': 'Other',
      'thought': 'Thought',
      'memory': 'Memory',
      'sensation': 'Sensation',
      'image': 'Image',
      'event': 'Event',
      'interaction': 'Interaction',
      'uncertainty': 'Uncertainty',
    };
    return locale.languageCode == 'pt' ? (pt[key] ?? key) : (en[key] ?? key);
  }
  
  void toggleTheme(ThemeMode mode) {
    themeMode = mode;
    _savePreferences();
    notifyListeners();
  }

  void toggleLanguage() {
    locale = locale.languageCode == 'pt' ? const Locale('en', 'US') : const Locale('pt', 'BR');
    _savePreferences();
    notifyListeners();
  }
  
  void setThemeType(ThemeType type) {
    currentTheme = type;
    _savePreferences();
    notifyListeners();
  }
}