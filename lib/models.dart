import 'package:uuid/uuid.dart';

enum ContextTag { location, social, internal, work, other }
enum TriggerType { thought, memory, sensation, image, event, interaction, uncertainty, urge }
enum SessionType { standard, exposure, crisis }
enum FeelingStatus { muchBetter, better, same, worse, muchWorse }

enum CognitiveDistortion { none, catastrophizing, allOrNothing, mindReading, fortuneTelling, emotionalReasoning, overgeneralization }

enum CompulsionAction { physical, mental, avoidance, checking, reassurance }
enum ExposureType { inVivo, imaginal, interoceptive }

class Intrusion {
  final String id;
  final String sessionId;
  final String thoughtText;
  final int beliefStrengthBefore; 
  final int beliefStrengthAfter; 
  final String? themeTag; 
  final CognitiveDistortion? distortion;

  Intrusion({
    required this.id,
    required this.sessionId,
    required this.thoughtText,
    this.beliefStrengthBefore = 0,
    this.beliefStrengthAfter = 0,
    this.themeTag,
    this.distortion,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'thoughtText': thoughtText,
    'beliefStrengthBefore': beliefStrengthBefore,
    'beliefStrengthAfter': beliefStrengthAfter,
    'themeTag': themeTag,
    'distortion': distortion?.index,
  };

  factory Intrusion.fromJson(Map<String, dynamic> json) => Intrusion(
    id: json['id'] ?? const Uuid().v4(),
    sessionId: json['sessionId'] ?? '',
    thoughtText: json['thoughtText'] ?? '',
    beliefStrengthBefore: json['beliefStrengthBefore'] ?? 0,
    beliefStrengthAfter: json['beliefStrengthAfter'] ?? 0,
    themeTag: json['themeTag'],
    distortion: json['distortion'] != null ? CognitiveDistortion.values[json['distortion']] : null,
  );
}

class DistressMetrics {
  final String sessionId;
  final int anxietyBefore; 
  final int anxietyPeak;
  final int anxietyAfter;
  final int senseOfControl; 
  final int urgeBefore;
  final int urgePeak;
  final int urgeAfter;

  DistressMetrics({
    required this.sessionId,
    this.anxietyBefore = 0,
    this.anxietyPeak = 0,
    this.anxietyAfter = 0,
    this.senseOfControl = 0,
    this.urgeBefore = 0,
    this.urgePeak = 0,
    this.urgeAfter = 0,
  });

  int get anxietyDrop => anxietyPeak - anxietyAfter;

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'anxietyBefore': anxietyBefore,
    'anxietyPeak': anxietyPeak,
    'anxietyAfter': anxietyAfter,
    'senseOfControl': senseOfControl,
    'urgeBefore': urgeBefore,
    'urgePeak': urgePeak,
    'urgeAfter': urgeAfter,
  };

  factory DistressMetrics.fromJson(Map<String, dynamic> json) => DistressMetrics(
    sessionId: json['sessionId'] ?? '',
    anxietyBefore: json['anxietyBefore'] ?? 0,
    anxietyPeak: json['anxietyPeak'] ?? 0,
    anxietyAfter: json['anxietyAfter'] ?? 0,
    senseOfControl: json['senseOfControl'] ?? 0,
    urgeBefore: json['urgeBefore'] ?? 0,
    urgePeak: json['urgePeak'] ?? 0,
    urgeAfter: json['urgeAfter'] ?? 0,
  );
}

class ResponseMechanism {
  final String sessionId;
  final List<String> compulsionUrges;
  final List<CompulsionAction> compulsionActions;
  final int delaySeconds;
  final bool resisted;
  final bool partial;

  ResponseMechanism({
    required this.sessionId,
    required this.compulsionUrges,
    required this.compulsionActions,
    this.delaySeconds = 0,
    this.resisted = false,
    this.partial = false,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'compulsionUrges': compulsionUrges,
    'compulsionActions': compulsionActions.map((e) => e.index).toList(),
    'delaySeconds': delaySeconds,
    'resisted': resisted,
    'partial': partial,
  };

  factory ResponseMechanism.fromJson(Map<String, dynamic> json) => ResponseMechanism(
    sessionId: json['sessionId'] ?? '',
    compulsionUrges: List<String>.from(json['compulsionUrges'] ?? []),
    compulsionActions: (json['compulsionActions'] as List? ?? [])
        .map((e) => CompulsionAction.values[e as int])
        .toList(),
    delaySeconds: json['delaySeconds'] ?? 0,
    resisted: json['resisted'] ?? false,
    partial: json['partial'] ?? false,
  );
}

class Learning {
  final String sessionId;
  final String predictedOutcome;
  final String actualOutcome;
  final int fearConfidence; 
  final int surpriseLevel; 
  final int recoveryMinutes;

  Learning({
    required this.sessionId,
    this.predictedOutcome = '',
    this.actualOutcome = '',
    this.fearConfidence = 0,
    this.surpriseLevel = 0,
    this.recoveryMinutes = 0,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'predictedOutcome': predictedOutcome,
    'actualOutcome': actualOutcome,
    'fearConfidence': fearConfidence,
    'surpriseLevel': surpriseLevel,
    'recoveryMinutes': recoveryMinutes,
  };

  factory Learning.fromJson(Map<String, dynamic> json) => Learning(
    sessionId: json['sessionId'] ?? '',
    predictedOutcome: json['predictedOutcome'] ?? '',
    actualOutcome: json['actualOutcome'] ?? '',
    fearConfidence: json['fearConfidence'] ?? 0,
    surpriseLevel: json['surpriseLevel'] ?? 0,
    recoveryMinutes: json['recoveryMinutes'] ?? 0,
  );
}

class Session {
  final String id;
  final DateTime timestamp;
  final DateTime? editedAt;
  final String triggerText;
  final ContextTag contextTag;
  final TriggerType? triggerType;
  final SessionType sessionType;
  final int durationSeconds;
  final FeelingStatus? feeling; 
  
  final List<Intrusion> intrusions; 
  final DistressMetrics distress;
  final ResponseMechanism response;
  final Learning learning;
  
  final String? theme;
  final String? notes;

  Session({
    required this.id,
    required this.timestamp,
    this.editedAt,
    required this.triggerText,
    required this.contextTag,
    this.triggerType,
    this.sessionType = SessionType.standard,
    this.durationSeconds = 0,
    this.feeling,
    required this.intrusions,
    required this.distress,
    required this.response,
    required this.learning,
    this.theme,
    this.notes,
  });

  Session copyWith({
    DateTime? editedAt,
    String? triggerText,
    ContextTag? contextTag,
    TriggerType? triggerType,
    SessionType? sessionType,
    int? durationSeconds,
    FeelingStatus? feeling,
    List<Intrusion>? intrusions,
    DistressMetrics? distress,
    ResponseMechanism? response,
    Learning? learning,
    String? theme,
    String? notes,
  }) {
    return Session(
      id: id,
      timestamp: timestamp,
      editedAt: editedAt ?? this.editedAt,
      triggerText: triggerText ?? this.triggerText,
      contextTag: contextTag ?? this.contextTag,
      triggerType: triggerType ?? this.triggerType,
      sessionType: sessionType ?? this.sessionType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      feeling: feeling ?? this.feeling,
      intrusions: intrusions ?? this.intrusions,
      distress: distress ?? this.distress,
      response: response ?? this.response,
      learning: learning ?? this.learning,
      theme: theme ?? this.theme,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'editedAt': editedAt?.toIso8601String(),
    'triggerText': triggerText,
    'contextTag': contextTag.index,
    'triggerType': triggerType?.index,
    'sessionType': sessionType.index,
    'durationSeconds': durationSeconds,
    'feeling': feeling?.index, 
    'intrusions': intrusions.map((e) => e.toJson()).toList(),
    'distress': distress.toJson(),
    'response': response.toJson(),
    'learning': learning.toJson(),
    'theme': theme,
    'notes': notes,
  };

  factory Session.fromJson(Map<String, dynamic> json) {
    List<Intrusion> parsedIntrusions = [];
    if (json['intrusions'] != null) {
      parsedIntrusions = (json['intrusions'] as List).map((e) => Intrusion.fromJson(e)).toList();
    } else if (json['intrusion'] != null) {
      parsedIntrusions = [Intrusion.fromJson(json['intrusion'])];
    }

    return Session(
      id: json['id'] ?? const Uuid().v4(),
      timestamp: DateTime.parse(json['timestamp']),
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      triggerText: json['triggerText'] ?? '',
      contextTag: ContextTag.values[json['contextTag'] ?? 0],
      triggerType: json['triggerType'] != null ? TriggerType.values[json['triggerType']] : null,
      sessionType: json['sessionType'] != null ? SessionType.values[json['sessionType']] : SessionType.standard,
      durationSeconds: json['durationSeconds'] ?? 0,
      feeling: json['feeling'] != null ? FeelingStatus.values[json['feeling']] : null, 
      intrusions: parsedIntrusions,
      distress: DistressMetrics.fromJson(json['distress'] ?? {}),
      response: ResponseMechanism.fromJson(json['response'] ?? {}),
      learning: Learning.fromJson(json['learning'] ?? {}),
      theme: json['theme'],
      notes: json['notes'],
    );
  }
}