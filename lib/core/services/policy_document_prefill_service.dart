import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/domain/entities/extracted_policy_data.dart';

class PolicyDocumentPrefillService {
  const PolicyDocumentPrefillService();

  ExtractedPolicyData parse(String rawText, {DateTime? now}) {
    final prepared = _PreparedPolicyText.from(rawText);
    final warnings = <String>{};
    final confidenceScores = <double>[];

    final policyNumber = _resolveTextField(
      fieldName: 'policy number',
      candidates: _extractPolicyNumberCandidates(prepared),
      warnings: warnings,
      confidenceScores: confidenceScores,
    );
    final companyName = _resolveTextField(
      fieldName: 'company name',
      candidates: _extractCompanyCandidates(prepared),
      warnings: warnings,
      confidenceScores: confidenceScores,
    );
    final policyHolderName = _resolveTextField(
      fieldName: 'policy holder name',
      candidates: _extractPolicyHolderCandidates(prepared),
      warnings: warnings,
      confidenceScores: confidenceScores,
    );
    final premiumAmount = _resolveAmountField(
      fieldName: 'premium amount',
      candidates: _extractPremiumCandidates(prepared),
      warnings: warnings,
      confidenceScores: confidenceScores,
    );
    final paymentFrequency = _resolveTextField(
      fieldName: 'payment frequency',
      candidates: _extractPaymentFrequencyCandidates(prepared),
      warnings: warnings,
      confidenceScores: confidenceScores,
    );
    final vehicleNumber = _resolveTextField(
      fieldName: 'vehicle number',
      candidates: _extractVehicleNumberCandidates(prepared),
      warnings: warnings,
      confidenceScores: confidenceScores,
    );
    final vehicleModel = _resolveTextField(
      fieldName: 'vehicle model',
      candidates: _extractVehicleModelCandidates(prepared),
      warnings: warnings,
      confidenceScores: confidenceScores,
    );

    final rangeCandidate = _resolveDateRangeCandidate(
      _extractDateRangeCandidates(prepared),
      warnings,
      confidenceScores,
    );

    var startDateMs = _resolveDateField(
      fieldName: 'start date',
      candidates: _extractStartDateCandidates(prepared, rangeCandidate),
      warnings: warnings,
      confidenceScores: confidenceScores,
    );
    var endDateMs = _resolveDateField(
      fieldName: 'end date',
      candidates: _extractEndDateCandidates(prepared, rangeCandidate),
      warnings: warnings,
      confidenceScores: confidenceScores,
    );

    if (startDateMs != null &&
        endDateMs != null &&
        !DateTime.fromMillisecondsSinceEpoch(
          endDateMs,
        ).isAfter(DateTime.fromMillisecondsSinceEpoch(startDateMs))) {
      if (rangeCandidate != null &&
          DateTime.fromMillisecondsSinceEpoch(rangeCandidate.endDateMs).isAfter(
            DateTime.fromMillisecondsSinceEpoch(rangeCandidate.startDateMs),
          )) {
        startDateMs = rangeCandidate.startDateMs;
        endDateMs = rangeCandidate.endDateMs;
      } else {
        warnings.add('Policy end date must be after start date.');
        startDateMs = null;
        endDateMs = null;
      }
    }

    final insuranceType = _detectInsuranceType(prepared, warnings);
    final status = _deriveStatus(
      startDateMs: startDateMs,
      endDateMs: endDateMs,
      now: now,
    );

    if (insuranceType != null) {
      confidenceScores.add(0.76);
    }
    if (status != null) {
      confidenceScores.add(0.72);
    }

    const double? parseConfidence = null;

    final result = ExtractedPolicyData(
      policyNumber: policyNumber,
      companyName: companyName,
      insuranceType: insuranceType,
      policyHolderName: policyHolderName,
      startDateMs: startDateMs,
      endDateMs: endDateMs,
      premiumAmount: premiumAmount,
      paymentFrequency: paymentFrequency,
      vehicleNumber: vehicleNumber,
      vehicleModel: vehicleModel,
      status: status,
      rawText: prepared.rawText,
      warnings: warnings.isEmpty ? null : warnings.toList(growable: false),
      parseConfidence: parseConfidence,
    );

    if (!result.hasStructuredData && prepared.rawText.isNotEmpty) {
      final fallbackResult = ExtractedPolicyData(
        policyNumber: result.policyNumber,
        companyName: result.companyName,
        insuranceType: result.insuranceType,
        policyHolderName: result.policyHolderName,
        startDateMs: result.startDateMs,
        endDateMs: result.endDateMs,
        premiumAmount: result.premiumAmount,
        paymentFrequency: result.paymentFrequency,
        vehicleNumber: result.vehicleNumber,
        vehicleModel: result.vehicleModel,
        status: result.status,
        rawText: result.rawText,
        warnings: <String>[
          ...?result.warnings,
          'No reliable structured values found.',
        ],
        parseConfidence: result.parseConfidence,
      );

      _debugLogResult(prepared, fallbackResult);
      return fallbackResult;
    }

    _debugLogResult(prepared, result);
    return result;
  }

  String? _resolveTextField({
    required String fieldName,
    required List<_FieldCandidate<String>> candidates,
    required Set<String> warnings,
    required List<double> confidenceScores,
  }) {
    final resolved = _resolveCandidate(
      fieldName: fieldName,
      candidates: candidates,
      warnings: warnings,
      keyOf: (value) => value.toLowerCase(),
    );
    if (resolved.score != null) {
      confidenceScores.add(resolved.score!);
    }
    return resolved.value;
  }

  int? _resolveDateField({
    required String fieldName,
    required List<_FieldCandidate<int>> candidates,
    required Set<String> warnings,
    required List<double> confidenceScores,
  }) {
    final resolved = _resolveCandidate(
      fieldName: fieldName,
      candidates: candidates,
      warnings: warnings,
      keyOf: (value) => value.toString(),
    );
    if (resolved.score != null) {
      confidenceScores.add(resolved.score!);
    }
    return resolved.value;
  }

  double? _resolveAmountField({
    required String fieldName,
    required List<_FieldCandidate<double>> candidates,
    required Set<String> warnings,
    required List<double> confidenceScores,
  }) {
    final distinctAcceptedValues = candidates
        .where((candidate) => candidate.score >= _minimumAcceptedScore)
        .map((candidate) => _amountKey(candidate.value))
        .toSet();
    if (distinctAcceptedValues.length > 1) {
      warnings.add('Conflicting $fieldName values found.');
      return null;
    }

    final resolved = _resolveCandidate(
      fieldName: fieldName,
      candidates: candidates,
      warnings: warnings,
      keyOf: _amountKey,
    );
    if (resolved.score != null) {
      confidenceScores.add(resolved.score!);
    }
    return resolved.value;
  }

  _DateRangeCandidate? _resolveDateRangeCandidate(
    List<_DateRangeCandidate> candidates,
    Set<String> warnings,
    List<double> confidenceScores,
  ) {
    if (candidates.isEmpty) {
      return null;
    }

    final sorted = [...candidates]
      ..sort((left, right) => right.score.compareTo(left.score));
    final best = sorted.first;
    final second = sorted.length > 1 ? sorted[1] : null;
    if (best.score < _minimumAcceptedScore) {
      return null;
    }
    if (second != null &&
        second.startDateMs != best.startDateMs &&
        second.endDateMs != best.endDateMs &&
        second.score >= best.score - _ambiguityWindow &&
        second.score >= _minimumAcceptedScore) {
      warnings.add('Multiple possible policy period values found.');
      return null;
    }
    confidenceScores.add(best.score);
    return best;
  }

  _ResolvedValue<T> _resolveCandidate<T>({
    required String fieldName,
    required List<_FieldCandidate<T>> candidates,
    required Set<String> warnings,
    required String Function(T value) keyOf,
  }) {
    if (candidates.isEmpty) {
      return _ResolvedValue<T>();
    }

    final deduped = <String, _FieldCandidate<T>>{};
    for (final candidate in candidates) {
      final key = keyOf(candidate.value);
      final existing = deduped[key];
      if (existing == null || candidate.score > existing.score) {
        deduped[key] = candidate;
      }
    }

    final sorted = deduped.values.toList(growable: false)
      ..sort((left, right) => right.score.compareTo(left.score));
    final best = sorted.first;
    final second = sorted.length > 1 ? sorted[1] : null;

    if (best.score < _minimumAcceptedScore) {
      return _ResolvedValue<T>();
    }

    if (second != null &&
        second.score >= best.score - _ambiguityWindow &&
        second.score >= _minimumAcceptedScore) {
      warnings.add('Multiple possible $fieldName values found.');
      return _ResolvedValue<T>();
    }

    return _ResolvedValue<T>(value: best.value, score: best.score);
  }

  List<_FieldCandidate<String>> _extractPolicyNumberCandidates(
    _PreparedPolicyText prepared,
  ) {
    final candidates = <_FieldCandidate<String>>[];

    for (final raw in _extractRawLabelCandidates(
      prepared,
      _policyNumberLabels,
      inlineScore: 0.96,
      nextLineScore: 0.93,
    )) {
      final cleaned = _cleanPolicyNumber(raw.value);
      if (cleaned != null) {
        candidates.add(
          _FieldCandidate<String>(
            value: cleaned,
            score: raw.score + _policyNumberQualityBoost(cleaned),
            sourceLine: raw.sourceLine,
          ),
        );
      }
    }

    for (final raw in _extractRawLabelCandidates(
      prepared,
      _proposalNumberLabels,
      inlineScore: 0.71,
      nextLineScore: 0.68,
    )) {
      final cleaned = _cleanPolicyNumber(raw.value);
      if (cleaned != null) {
        candidates.add(
          _FieldCandidate<String>(
            value: cleaned,
            score: raw.score + 0.01,
            sourceLine: raw.sourceLine,
          ),
        );
      }
    }

    return candidates;
  }

  List<_FieldCandidate<String>> _extractCompanyCandidates(
    _PreparedPolicyText prepared,
  ) {
    final candidates = <_FieldCandidate<String>>[];

    for (final raw in _extractRawLabelCandidates(
      prepared,
      _companyNameLabels,
      inlineScore: 0.96,
      nextLineScore: 0.92,
      stopAtKnownLabelBoundary: false,
    )) {
      final cleaned = _cleanCompanyName(raw.value);
      if (cleaned == null) {
        continue;
      }
      final insurerBoost = _companyKeywordBoost(cleaned);
      candidates.add(
        _FieldCandidate<String>(
          value: cleaned,
          score: raw.score + insurerBoost,
          sourceLine: raw.sourceLine,
        ),
      );
    }

    for (final line in prepared.lines) {
      final knownInsurer = _matchKnownInsurer(line.text);
      if (knownInsurer == null) {
        continue;
      }
      candidates.add(
        _FieldCandidate<String>(
          value: knownInsurer,
          score: 0.84,
          sourceLine: line.text,
        ),
      );
    }

    return candidates;
  }

  List<_FieldCandidate<String>> _extractPolicyHolderCandidates(
    _PreparedPolicyText prepared,
  ) {
    final candidates = <_FieldCandidate<String>>[];

    for (final raw in _extractRawLabelCandidates(
      prepared,
      _policyHolderLabels,
      inlineScore: 0.96,
      nextLineScore: 0.94,
    )) {
      final cleaned = _cleanPersonLikeValue(raw.value);
      if (cleaned == null) {
        continue;
      }
      var score = raw.score;
      if (cleaned.split(' ').length >= 2) {
        score += 0.03;
      }
      candidates.add(
        _FieldCandidate<String>(
          value: cleaned,
          score: score,
          sourceLine: raw.sourceLine,
        ),
      );
    }

    for (final line in prepared.lines) {
      if (!_containsAny(line.lowered, _policyHolderContextPatterns)) {
        continue;
      }

      final joined = _joinContinuationLines(prepared, line.index + 1);
      if (joined == null) {
        continue;
      }

      final cleaned = _cleanPersonLikeValue(joined);
      if (cleaned == null) {
        continue;
      }

      candidates.add(
        _FieldCandidate<String>(
          value: cleaned,
          score: 0.76,
          sourceLine: '${line.text} | $joined',
        ),
      );
    }

    return candidates;
  }

  List<_FieldCandidate<double>> _extractPremiumCandidates(
    _PreparedPolicyText prepared,
  ) {
    final candidates = <_FieldCandidate<double>>[];

    for (final config in _premiumLabelConfigs) {
      for (final raw in _extractRawLabelCandidates(
        prepared,
        <String>[config.label],
        inlineScore: config.baseScore,
        nextLineScore: config.baseScore - 0.03,
      )) {
        if (_containsAny(raw.loweredSourceLine, _premiumRejectedLinePatterns) &&
            !config.isTotalLike) {
          continue;
        }

        final amounts = _extractAmounts(
          raw.value,
        ).where(_isLikelyPremium).toList();
        if (amounts.isEmpty) {
          continue;
        }

        final selectedAmount = amounts.reduce(
          (left, right) => left > right ? left : right,
        );
        candidates.add(
          _FieldCandidate<double>(
            value: selectedAmount,
            score:
                config.baseScore + _premiumAmountQualityBoost(selectedAmount),
            sourceLine: raw.sourceLine,
          ),
        );
      }
    }

    return candidates;
  }

  List<_FieldCandidate<String>> _extractPaymentFrequencyCandidates(
    _PreparedPolicyText prepared,
  ) {
    final candidates = <_FieldCandidate<String>>[];

    for (final raw in _extractRawLabelCandidates(
      prepared,
      _paymentFrequencyLabels,
      inlineScore: 0.93,
      nextLineScore: 0.89,
    )) {
      final cleaned = _cleanPaymentFrequency(raw.value);
      if (cleaned != null) {
        candidates.add(
          _FieldCandidate<String>(
            value: cleaned,
            score: raw.score,
            sourceLine: raw.sourceLine,
          ),
        );
      }
    }

    return candidates;
  }

  List<_FieldCandidate<String>> _extractVehicleNumberCandidates(
    _PreparedPolicyText prepared,
  ) {
    final candidates = <_FieldCandidate<String>>[];

    for (final raw in _extractRawLabelCandidates(
      prepared,
      _vehicleNumberLabels,
      inlineScore: 0.96,
      nextLineScore: 0.93,
    )) {
      final cleaned = _cleanVehicleNumber(raw.value);
      if (cleaned != null) {
        candidates.add(
          _FieldCandidate<String>(
            value: cleaned,
            score: raw.score + 0.02,
            sourceLine: raw.sourceLine,
          ),
        );
      }
    }

    for (final line in prepared.lines) {
      final cleaned = _cleanVehicleNumber(line.text);
      if (cleaned == null) {
        continue;
      }
      final score = _containsAny(line.lowered, _vehicleContextPatterns)
          ? 0.82
          : 0.62;
      candidates.add(
        _FieldCandidate<String>(
          value: cleaned,
          score: score,
          sourceLine: line.text,
        ),
      );
    }

    return candidates;
  }

  List<_FieldCandidate<String>> _extractVehicleModelCandidates(
    _PreparedPolicyText prepared,
  ) {
    final candidates = <_FieldCandidate<String>>[];

    for (final raw in _extractRawLabelCandidates(
      prepared,
      _vehicleModelLabels,
      inlineScore: 0.95,
      nextLineScore: 0.92,
    )) {
      final cleaned = _cleanVehicleModel(raw.value);
      if (cleaned == null) {
        continue;
      }
      candidates.add(
        _FieldCandidate<String>(
          value: cleaned,
          score: raw.score + _vehicleModelQualityBoost(cleaned),
          sourceLine: raw.sourceLine,
        ),
      );
    }

    for (final line in prepared.lines) {
      final cleaned = _cleanVehicleModel(line.text);
      if (cleaned == null) {
        continue;
      }
      if (!_containsAny(line.lowered, _vehicleBrandPatterns)) {
        continue;
      }

      candidates.add(
        _FieldCandidate<String>(
          value: cleaned,
          score: 0.74 + _vehicleModelQualityBoost(cleaned),
          sourceLine: line.text,
        ),
      );
    }

    return candidates;
  }

  List<_DateRangeCandidate> _extractDateRangeCandidates(
    _PreparedPolicyText prepared,
  ) {
    final candidates = <_DateRangeCandidate>[];

    for (final raw in _extractRawLabelCandidates(
      prepared,
      _dateRangeLabels,
      inlineScore: 0.95,
      nextLineScore: 0.91,
    )) {
      final tokens = _extractDateTokens(raw.value);
      if (tokens.length < 2) {
        continue;
      }
      final startDate = _tryParseDate(tokens.first);
      final endDate = _tryParseDate(tokens.last);
      if (startDate == null || endDate == null || !endDate.isAfter(startDate)) {
        continue;
      }
      candidates.add(
        _DateRangeCandidate(
          startDateMs: startDate.millisecondsSinceEpoch,
          endDateMs: endDate.millisecondsSinceEpoch,
          score: raw.score,
          sourceLine: raw.sourceLine,
        ),
      );
    }

    for (final line in prepared.lines) {
      if (!line.lowered.contains('from') || !line.lowered.contains('to')) {
        continue;
      }
      final tokens = _extractDateTokens(line.text);
      if (tokens.length < 2) {
        continue;
      }
      final startDate = _tryParseDate(tokens.first);
      final endDate = _tryParseDate(tokens.last);
      if (startDate == null || endDate == null || !endDate.isAfter(startDate)) {
        continue;
      }
      candidates.add(
        _DateRangeCandidate(
          startDateMs: startDate.millisecondsSinceEpoch,
          endDateMs: endDate.millisecondsSinceEpoch,
          score: 0.88,
          sourceLine: line.text,
        ),
      );
    }

    return candidates;
  }

  List<_FieldCandidate<int>> _extractStartDateCandidates(
    _PreparedPolicyText prepared,
    _DateRangeCandidate? rangeCandidate,
  ) {
    final candidates = <_FieldCandidate<int>>[];

    for (final raw in _extractRawLabelCandidates(
      prepared,
      _startDateLabels,
      inlineScore: 0.94,
      nextLineScore: 0.9,
    )) {
      final tokens = _extractDateTokens(raw.value);
      if (tokens.isEmpty) {
        continue;
      }
      final date = _tryParseDate(tokens.first);
      if (date == null) {
        continue;
      }
      candidates.add(
        _FieldCandidate<int>(
          value: date.millisecondsSinceEpoch,
          score: raw.score,
          sourceLine: raw.sourceLine,
        ),
      );
    }

    if (rangeCandidate != null) {
      candidates.add(
        _FieldCandidate<int>(
          value: rangeCandidate.startDateMs,
          score: rangeCandidate.score,
          sourceLine: rangeCandidate.sourceLine,
        ),
      );
    }

    return candidates;
  }

  List<_FieldCandidate<int>> _extractEndDateCandidates(
    _PreparedPolicyText prepared,
    _DateRangeCandidate? rangeCandidate,
  ) {
    final candidates = <_FieldCandidate<int>>[];

    for (final raw in _extractRawLabelCandidates(
      prepared,
      _endDateLabels,
      inlineScore: 0.94,
      nextLineScore: 0.9,
    )) {
      final tokens = _extractDateTokens(raw.value);
      if (tokens.isEmpty) {
        continue;
      }
      final date = _tryParseDate(tokens.last);
      if (date == null) {
        continue;
      }
      candidates.add(
        _FieldCandidate<int>(
          value: date.millisecondsSinceEpoch,
          score: raw.score,
          sourceLine: raw.sourceLine,
        ),
      );
    }

    if (rangeCandidate != null) {
      candidates.add(
        _FieldCandidate<int>(
          value: rangeCandidate.endDateMs,
          score: rangeCandidate.score,
          sourceLine: rangeCandidate.sourceLine,
        ),
      );
    }

    return candidates;
  }

  String? _detectInsuranceType(
    _PreparedPolicyText prepared,
    Set<String> warnings,
  ) {
    final matches = <String>{};
    final text = prepared.loweredText;

    if (_containsAny(text, _commercialVehicleKeywords)) {
      matches.add('Commercial Vehicle');
    }
    if (_containsAny(text, _bikeKeywords)) {
      matches.add('Bike');
    }
    if (_containsAny(text, _carKeywords)) {
      matches.add('Car');
    }
    if (_containsAny(text, _healthKeywords)) {
      matches.add('Health');
    }
    if (_containsAny(text, _termKeywords)) {
      matches.add('Term');
    }
    if (_containsAny(text, _lifeKeywords)) {
      matches.add('Life');
    }

    if (matches.contains('Term') && matches.contains('Life')) {
      matches.remove('Life');
    }

    if (matches.length > 1) {
      warnings.add('Conflicting insurance type keywords found.');
      return null;
    }

    if (matches.isEmpty) {
      return null;
    }

    return matches.first;
  }

  String? _deriveStatus({
    required int? startDateMs,
    required int? endDateMs,
    DateTime? now,
  }) {
    final today = _atStartOfDay(now ?? DateTime.now());
    final startDate = startDateMs == null
        ? null
        : _atStartOfDay(DateTime.fromMillisecondsSinceEpoch(startDateMs));
    final endDate = endDateMs == null
        ? null
        : _atStartOfDay(DateTime.fromMillisecondsSinceEpoch(endDateMs));

    if (endDate != null && endDate.isBefore(today)) {
      return 'Expired';
    }
    if (startDate != null && startDate.isAfter(today)) {
      return 'Pending';
    }
    if (startDate != null &&
        endDate != null &&
        !today.isBefore(startDate) &&
        !today.isAfter(endDate)) {
      return 'Active';
    }
    return null;
  }

  void _debugLogResult(_PreparedPolicyText prepared, ExtractedPolicyData result) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('Policy parser input:\n${prepared.rawText}');
    debugPrint(
      'Policy parser result: '
      'policyNumber=${result.policyNumber}, '
      'companyName=${result.companyName}, '
      'policyHolderName=${result.policyHolderName}, '
      'insuranceType=${result.insuranceType}, '
      'startDateMs=${result.startDateMs}, '
      'endDateMs=${result.endDateMs}, '
      'premiumAmount=${result.premiumAmount}, '
      'vehicleNumber=${result.vehicleNumber}, '
      'vehicleModel=${result.vehicleModel}, '
      'status=${result.status}, '
      'warnings=${result.warnings}',
    );
  }
}

class _PreparedPolicyText {
  const _PreparedPolicyText({
    required this.rawText,
    required this.lines,
    required this.loweredText,
  });

  factory _PreparedPolicyText.from(String rawText) {
    final trimmed = rawText.trim();
    final rawLines = trimmed
        .replaceAll('â‚¹', 'Rs ')
        .replaceAll('\t', ' ')
        .split(RegExp(r'\r?\n'));

    final lines = <_PreparedLine>[];
    String? previousKey;
    for (var index = 0; index < rawLines.length; index++) {
      final normalized = _normalizeLine(rawLines[index]);
      if (normalized.isEmpty) {
        continue;
      }
      final line = _PreparedLine(
        text: normalized,
        lowered: normalized.toLowerCase(),
        index: lines.length,
      );
      final key = line.lowered;
      if (key == previousKey) {
        continue;
      }
      lines.add(line);
      previousKey = key;
    }

    return _PreparedPolicyText(
      rawText: trimmed,
      lines: lines,
      loweredText: lines.map((line) => line.lowered).join('\n'),
    );
  }

  final String rawText;
  final List<_PreparedLine> lines;
  final String loweredText;
}

class _PreparedLine {
  const _PreparedLine({
    required this.text,
    required this.lowered,
    required this.index,
  });

  final String text;
  final String lowered;
  final int index;
}

class _RawLabelCandidate {
  const _RawLabelCandidate({
    required this.value,
    required this.score,
    required this.sourceLine,
    required this.loweredSourceLine,
  });

  final String value;
  final double score;
  final String sourceLine;
  final String loweredSourceLine;
}

class _FieldCandidate<T> {
  const _FieldCandidate({
    required this.value,
    required this.score,
    required this.sourceLine,
  });

  final T value;
  final double score;
  final String sourceLine;
}

class _ResolvedValue<T> {
  const _ResolvedValue({this.value, this.score});

  final T? value;
  final double? score;
}

class _DateRangeCandidate {
  const _DateRangeCandidate({
    required this.startDateMs,
    required this.endDateMs,
    required this.score,
    required this.sourceLine,
  });

  final int startDateMs;
  final int endDateMs;
  final double score;
  final String sourceLine;
}

class _PremiumLabelConfig {
  const _PremiumLabelConfig(
    this.label,
    this.baseScore, {
    this.isTotalLike = false,
  });

  final String label;
  final double baseScore;
  final bool isTotalLike;
}

const double _minimumAcceptedScore = 0.68;
const double _ambiguityWindow = 0.05;

const List<String> _policyNumberLabels = <String>[
  'policy number',
  'policy no',
  'policy #',
  'policy / certificate no',
  'policy / certificate number',
  'policy certificate no',
  'certificate no',
  'certificate number',
];

const List<String> _proposalNumberLabels = <String>[
  'proposal no',
  'proposal number',
];

const List<String> _companyNameLabels = <String>[
  'company name',
  'insurance company',
  'insurer',
  'insurer name',
  'company',
];

const List<String> _policyHolderLabels = <String>[
  'policy holder name',
  'policyholder name',
  'policy holder',
  'name of insured',
  'insured name',
  'insured',
  'insured member',
  'proposer name',
  'name of proposer',
  'life assured',
  'policy holder / insured',
  'customer name',
  'owner name',
];

const List<String> _startDateLabels = <String>[
  'policy start date',
  'start date',
  'policy period from',
  'od period from',
  'valid from',
  'effective from',
  'risk start date',
  'commencement date',
  'commencement',
  'date of commencement',
];

const List<String> _endDateLabels = <String>[
  'policy end date',
  'end date',
  'policy period to',
  'od period to',
  'valid to',
  'valid upto',
  'valid up to',
  'valid till',
  'expiry',
  'risk end date',
  'expiry date',
  'date of maturity',
];

const List<String> _dateRangeLabels = <String>[
  'period of insurance',
  'policy period',
  'policy tenure',
  'validity',
  'period',
];

const List<String> _paymentFrequencyLabels = <String>[
  'premium mode',
  'payment frequency',
  'mode of premium payment',
];

const List<String> _vehicleNumberLabels = <String>[
  'vehicle number',
  'registration no',
  'registration number',
  'vehicle registration no',
  'registration mark',
  'regn mark',
  'reg no',
  'regn no',
];

const List<String> _vehicleModelLabels = <String>[
  'vehicle model',
  'make / model',
  'make model',
  'make/model',
  'make & model',
  'make and model',
  'model / variant',
  'model variant',
  'vehicle make',
  'make',
  'model',
  'variant',
];

const List<String> _boundaryOnlyLabels = <String>[
  'date of issue',
  'issue date',
  'application no',
  'application number',
  'sum insured',
  'nominee name',
  'appointee name',
  'branch manager',
  'engine no',
  'engine number',
  'chassis no',
  'chassis number',
  'fuel type',
];

const List<_PremiumLabelConfig> _premiumLabelConfigs = <_PremiumLabelConfig>[
  _PremiumLabelConfig('total premium payable', 0.98, isTotalLike: true),
  _PremiumLabelConfig('total premium', 0.96, isTotalLike: true),
  _PremiumLabelConfig('gross premium', 0.94, isTotalLike: true),
  _PremiumLabelConfig('premium payable', 0.92, isTotalLike: true),
  _PremiumLabelConfig('premium amount', 0.9, isTotalLike: true),
  _PremiumLabelConfig('amount payable', 0.9, isTotalLike: true),
  _PremiumLabelConfig('final premium', 0.88, isTotalLike: true),
  _PremiumLabelConfig('annual premium', 0.85),
  _PremiumLabelConfig('modal premium', 0.84),
  _PremiumLabelConfig('net premium', 0.72),
];

const List<String> _premiumRejectedLinePatterns = <String>[
  r'\bidv\b',
  r'\bsum insured\b',
  r'\bown damage\b',
  r'\bthird party\b',
  r'\bcgst\b',
  r'\bsgst\b',
  r'\bigst\b',
  r'\bgst\b',
  r'\bncb\b',
  r'\bdiscount\b',
  r'\bdeductible\b',
];

const List<String> _policyHolderContextPatterns = <String>[
  r'\binsured\b',
  r'\bpolicy holder\b',
  r'\bpolicyholder\b',
  r'\bproposer\b',
  r'\blife assured\b',
  r'\bcustomer name\b',
  r'\bowner name\b',
];

const List<String> _vehicleContextPatterns = <String>[
  r'\bvehicle\b',
  r'\bregistration\b',
  r'\breg\b',
];

const List<String> _vehicleBrandPatterns = <String>[
  r'\bhyundai\b',
  r'\bmaruti\b',
  r'\bsuzuki\b',
  r'\bhonda\b',
  r'\btata\b',
  r'\bmahindra\b',
  r'\btoyota\b',
  r'\bkia\b',
  r'\brenault\b',
  r'\bnissan\b',
  r'\bskoda\b',
  r'\bvolkswagen\b',
  r'\bmg\b',
  r'\baudi\b',
  r'\bbmw\b',
  r'\bmercedes\b',
  r'\byamaha\b',
  r'\btvs\b',
  r'\bhero\b',
  r'\bbajaj\b',
  r'\broyal enfield\b',
  r'\bktm\b',
  r'\bvespa\b',
  r'\bather\b',
  r'\bola\b',
];

const List<String> _commercialVehicleKeywords = <String>[
  r'\bcommercial vehicle\b',
  r'\bgoods carrying\b',
  r'\bpassenger carrying\b',
  r'\bcommercial package policy\b',
];

const List<String> _bikeKeywords = <String>[
  r'\btwo wheeler\b',
  r'\btwo-wheeler\b',
  r'\bbike\b',
  r'\bscooter\b',
  r'\bmotorcycle\b',
];

const List<String> _carKeywords = <String>[
  r'\bprivate car\b',
  r'\bcar package policy\b',
  r'\bfour wheeler\b',
  r'\bprivate vehicle\b',
];

const List<String> _healthKeywords = <String>[
  r'\bhealth insurance\b',
  r'\bmediclaim\b',
  r'\bfloater\b',
];

const List<String> _termKeywords = <String>[
  r'\bterm insurance\b',
  r'\bpure protection\b',
];

const List<String> _lifeKeywords = <String>[
  r'\blife insurance\b',
  r'\bjeevan\b',
];

const Map<String, List<String>> _knownInsurers = <String, List<String>>{
  'Life Insurance Corporation of India': <String>[
    r'\blife insurance corporation\b',
    r'\blic\b',
  ],
  'HDFC ERGO General Insurance': <String>[r'\bhdfc ergo\b'],
  'HDFC Life Insurance': <String>[r'\bhdfc life\b'],
  'ICICI Lombard General Insurance': <String>[r'\bicici lombard\b'],
  'ICICI Prudential Life Insurance': <String>[r'\bicici prudential\b'],
  'Bajaj Allianz Insurance': <String>[r'\bbajaj allianz\b'],
  'Tata AIG Insurance': <String>[r'\btata aig\b'],
  'New India Assurance': <String>[r'\bnew india assurance\b'],
  'United India Insurance': <String>[r'\bunited india insurance\b'],
  'National Insurance': <String>[r'\bnational insurance\b'],
  'Oriental Insurance': <String>[r'\boriental insurance\b'],
  'Reliance General Insurance': <String>[r'\breliance general\b'],
  'SBI General Insurance': <String>[r'\bsbi general\b'],
  'SBI Life Insurance': <String>[r'\bsbi life\b'],
  'Star Health Insurance': <String>[r'\bstar health\b'],
  'Care Health Insurance': <String>[r'\bcare health\b'],
  'Niva Bupa Health Insurance': <String>[r'\bniva bupa\b'],
  'Max Life Insurance': <String>[r'\bmax life\b'],
  'Kotak Life Insurance': <String>[r'\bkotak life\b'],
  'Aditya Birla Insurance': <String>[r'\baditya birla\b'],
  'Future Generali Insurance': <String>[r'\bfuture generali\b'],
  'Royal Sundaram Insurance': <String>[r'\broyal sundaram\b'],
  'Cholamandalam Insurance': <String>[r'\bcholamandalam\b', r'\bchola ms\b'],
  'IFFCO Tokio Insurance': <String>[r'\biffco tokio\b'],
};

final String _knownLabelBoundaryPattern = () {
  final labels =
      <String>{
          ..._policyNumberLabels,
          ..._proposalNumberLabels,
          ..._companyNameLabels,
          ..._policyHolderLabels,
          ..._startDateLabels,
          ..._endDateLabels,
          ..._dateRangeLabels,
          ..._paymentFrequencyLabels,
          ..._vehicleNumberLabels,
          ..._vehicleModelLabels,
          ..._premiumLabelConfigs.map((item) => item.label),
          ..._boundaryOnlyLabels,
        }.toList(growable: false)
        ..sort((left, right) => right.length.compareTo(left.length));

  return labels.map(_patternForLabel).join('|');
}();

final RegExp _amountPattern = RegExp(
  r'(?:rs\.?|inr|₹)?\s*([0-9]{1,3}(?:,[0-9]{2,3})*(?:\.\d{1,2})?|[0-9]+(?:\.\d{1,2})?)\s*(?:/-)?',
  caseSensitive: false,
);

final RegExp _numericDatePattern = RegExp(
  r'\b(?:\d{4}[\/\-.]\d{1,2}[\/\-.]\d{1,2}|\d{1,2}[\/\-.]\d{1,2}[\/\-.]\d{2,4})\b',
);

final RegExp _namedDatePattern = RegExp(
  r'\b\d{1,2}(?:st|nd|rd|th)?(?:[ -])(jan|january|feb|february|mar|march|apr|april|may|jun|june|jul|july|aug|august|sep|sept|september|oct|october|nov|november|dec|december)(?:[ -])\d{2,4}\b',
  caseSensitive: false,
);

final RegExp _vehicleNumberPattern = RegExp(
  r'\b[A-Z]{2}\s*[-]?\s*\d{1,2}\s*[-]?\s*[A-Z]{1,3}\s*[-]?\s*\d{1,4}\b',
  caseSensitive: false,
);

String _normalizeLine(String value) {
  return value
      .replaceAll('â‚¹', 'Rs ')
      .replaceAll(RegExp(r'[—–]+'), '-')
      .replaceAll(RegExp(r'[|]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _patternForLabel(String label) {
  return RegExp.escape(label).replaceAll(r'\ ', r'\s+');
}

bool _startsWithKnownLabel(String value) {
  return RegExp(
    '^(?:$_knownLabelBoundaryPattern)(?:\\s*[:\\-]?|\\b)',
    caseSensitive: false,
  ).hasMatch(value);
}

List<_RawLabelCandidate> _extractRawLabelCandidates(
  _PreparedPolicyText prepared,
  List<String> labels, {
  required double inlineScore,
  required double nextLineScore,
  bool stopAtKnownLabelBoundary = true,
  bool allowSpaceSeparated = true,
}) {
  final candidates = <_RawLabelCandidate>[];

  for (var index = 0; index < prepared.lines.length; index++) {
    final line = prepared.lines[index];

    for (final label in labels) {
      if (_lineStartsWithLongerLabel(line.text, label, labels)) {
        continue;
      }

      final labelPattern = _patternForLabel(label);
      final exactLabelPattern = RegExp(
        '^$labelPattern\\s*[:\\-]?\$',
        caseSensitive: false,
      );
      if (exactLabelPattern.hasMatch(line.text) &&
          index + 1 < prepared.lines.length &&
          !_startsWithKnownLabel(prepared.lines[index + 1].text)) {
        final nextLine = prepared.lines[index + 1];
        candidates.add(
          _RawLabelCandidate(
            value: nextLine.text,
            score: nextLineScore,
            sourceLine: nextLine.text,
            loweredSourceLine: nextLine.lowered,
          ),
        );

        final joinedValue = _joinContinuationLines(prepared, index + 1);
        if (joinedValue != null && joinedValue != nextLine.text) {
          candidates.add(
            _RawLabelCandidate(
              value: joinedValue,
              score: nextLineScore - 0.03,
              sourceLine: '${nextLine.text} | $joinedValue',
              loweredSourceLine: joinedValue.toLowerCase(),
            ),
          );
        }
      }

      final inlinePattern = stopAtKnownLabelBoundary
          ? RegExp(
              '$labelPattern\\s*[:\\-]\\s*(.+?)(?=(?:\\s+(?:$_knownLabelBoundaryPattern)\\b\\s*[:\\-]?)|\$)',
              caseSensitive: false,
            )
          : RegExp('$labelPattern\\s*[:\\-]\\s*(.+)\$', caseSensitive: false);
      for (final match in inlinePattern.allMatches(line.text)) {
        final value = match.group(1);
        if (value == null || value.trim().isEmpty) {
          continue;
        }
        candidates.add(
          _RawLabelCandidate(
            value: value,
            score: inlineScore,
            sourceLine: line.text,
            loweredSourceLine: line.lowered,
          ),
        );
      }

      if (!allowSpaceSeparated) {
        continue;
      }

      final spacedPattern = RegExp(
        '^$labelPattern\\b\\s+(.+)\$',
        caseSensitive: false,
      );
      final spacedMatch = spacedPattern.firstMatch(line.text);
      if (spacedMatch == null) {
        continue;
      }

      final spacedValue = spacedMatch.group(1);
      if (spacedValue == null || spacedValue.trim().isEmpty) {
        continue;
      }
      if (_looksLikeLongerLabelContinuation(spacedValue)) {
        continue;
      }

      candidates.add(
        _RawLabelCandidate(
          value: spacedValue,
          score: inlineScore - 0.08,
          sourceLine: line.text,
          loweredSourceLine: line.lowered,
        ),
      );
    }
  }

  return candidates;
}

String? _joinContinuationLines(_PreparedPolicyText prepared, int startIndex) {
  if (startIndex >= prepared.lines.length) {
    return null;
  }

  final parts = <String>[];
  for (var index = startIndex; index < prepared.lines.length && parts.length < 3; index++) {
    final line = prepared.lines[index];
    if (_startsWithKnownLabel(line.text) && parts.isNotEmpty) {
      break;
    }
    if (!_isUsefulContinuationLine(line.text)) {
      if (parts.isEmpty) {
        return null;
      }
      break;
    }
    parts.add(line.text);

    final nextIndex = index + 1;
    if (nextIndex >= prepared.lines.length) {
      break;
    }
    final nextLine = prepared.lines[nextIndex];
    if (!_shouldContinueValue(line.text, nextLine.text)) {
      break;
    }
  }

  if (parts.isEmpty) {
    return null;
  }

  return parts.join(' ');
}

bool _isUsefulContinuationLine(String value) {
  final cleaned = value.trim();
  if (cleaned.isEmpty) {
    return false;
  }
  if (_startsWithKnownLabel(cleaned)) {
    return false;
  }
  return true;
}

bool _shouldContinueValue(String currentLine, String nextLine) {
  if (_startsWithKnownLabel(nextLine)) {
    return false;
  }
  if (_containsAny(nextLine.toLowerCase(), _addressLikePatterns)) {
    return false;
  }
  if (currentLine.length >= 48) {
    return false;
  }
  if (nextLine.length <= 2) {
    return false;
  }
  return true;
}

bool _lineStartsWithLongerLabel(
  String line,
  String currentLabel,
  List<String> labels,
) {
  for (final otherLabel in labels) {
    if (otherLabel.length <= currentLabel.length) {
      continue;
    }
    if (!otherLabel.toLowerCase().startsWith(currentLabel.toLowerCase())) {
      continue;
    }
    final pattern = RegExp(
      '^${_patternForLabel(otherLabel)}(?:\\b|\\s*[:\\-])',
      caseSensitive: false,
    );
    if (pattern.hasMatch(line)) {
      return true;
    }
  }
  return false;
}

bool _looksLikeLongerLabelContinuation(String value) {
  final normalized = value.trim().toLowerCase();
  return RegExp(
    r'^(name|number|no|date|period|holder|insured|member|model|variant|from|to)\b',
    caseSensitive: false,
  ).hasMatch(normalized);
}

String? _cleanGenericValue(String value) {
  final cleaned = value
      .replaceAll(RegExp(r'^[\s:;,\-]+|[\s:;,\-]+$'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return cleaned.isEmpty ? null : cleaned;
}

String? _cleanPolicyNumber(String value) {
  final cleaned = _cleanGenericValue(value);
  if (cleaned == null) {
    return null;
  }

  final normalized = cleaned
      .replaceAllMapped(RegExp(r'\s*([/\\-])\s*'), (match) => match.group(1)!)
      .replaceAll(RegExp(r'\s+'), '')
      .toUpperCase();

  if (normalized.length < 6) {
    return null;
  }
  if (_isLikelyVehicleNumber(normalized)) {
    return null;
  }
  if (!RegExp(r'[A-Z]').hasMatch(normalized) &&
      _isLikelyMobileNumber(normalized)) {
    return null;
  }
  if (!RegExp(r'[A-Z0-9]').hasMatch(normalized)) {
    return null;
  }
  if (!RegExp(r'\d').hasMatch(normalized)) {
    return null;
  }
  if (!RegExp(r'[A-Z]').hasMatch(normalized) &&
      normalized.replaceAll(RegExp(r'[^0-9]'), '').length < 8) {
    return null;
  }

  return normalized;
}

double _policyNumberQualityBoost(String value) {
  var score = 0.0;
  if (RegExp(r'[A-Z]').hasMatch(value)) {
    score += 0.02;
  }
  if (value.contains('/') || value.contains('-')) {
    score += 0.01;
  }
  return score;
}

String? _cleanCompanyName(String value) {
  final cleaned = _cleanGenericValue(value);
  if (cleaned == null) {
    return null;
  }
  final lowered = cleaned.toLowerCase();
  if (lowered.length < 3) {
    return null;
  }
  if (_containsAny(lowered, _companyRejectPatterns)) {
    return null;
  }
  if (RegExp(
    r'^(limited|ltd|insurance|company)$',
    caseSensitive: false,
  ).hasMatch(cleaned)) {
    return null;
  }
  return cleaned;
}

double _companyKeywordBoost(String value) {
  return _matchKnownInsurer(value) == null ? 0.0 : 0.03;
}

String? _matchKnownInsurer(String value) {
  final lowered = value.toLowerCase();
  for (final entry in _knownInsurers.entries) {
    for (final pattern in entry.value) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lowered)) {
        return entry.key;
      }
    }
  }
  return null;
}

const List<String> _companyRejectPatterns = <String>[
  r'\baddress\b',
  r'\bbranch\b',
  r'\boffice\b',
  r'\broad\b',
  r'\bstreet\b',
  r'\bphone\b',
  r'\bmobile\b',
  r'\bemail\b',
  r'\bgstin\b',
  r'\bpin code\b',
];

const List<String> _addressLikePatterns = <String>[
  r'\baddress\b',
  r'\broad\b',
  r'\bstreet\b',
  r'\bcolony\b',
  r'\bnagar\b',
  r'\bnear\b',
  r'\bbranch\b',
  r'\boffice\b',
  r'\bpincode\b',
  r'\bpin code\b',
  r'\bmobile\b',
  r'\bphone\b',
  r'\bemail\b',
];

String? _cleanPersonLikeValue(String value) {
  final cleaned = _cleanGenericValue(value);
  if (cleaned == null) {
    return null;
  }

  final lowered = cleaned.toLowerCase();
  if (cleaned.length < 3) {
    return null;
  }
  if (!RegExp(r'[A-Za-z]').hasMatch(cleaned)) {
    return null;
  }
  if (_containsAny(lowered, _personRejectPatterns)) {
    return null;
  }
  if (_matchKnownInsurer(cleaned) != null) {
    return null;
  }
  if (_isLikelyVehicleNumber(cleaned) || _cleanPolicyNumber(cleaned) != null) {
    return null;
  }
  if (_extractAmounts(cleaned).isNotEmpty ||
      _extractDateTokens(cleaned).isNotEmpty) {
    return null;
  }
  if (RegExp(r'\d{3,}').hasMatch(cleaned)) {
    return null;
  }

  return cleaned;
}

const List<String> _personRejectPatterns = <String>[
  r'\bnominee\b',
  r'\bappointee\b',
  r'\bagent\b',
  r'\bmanager\b',
  r'\bbranch\b',
  r'\bbank\b',
  r'\baddress\b',
  r'\bpolicy\b',
  r'\bpremium\b',
  r'\bvehicle\b',
  r'\bregistration\b',
  r'\bcompany\b',
  r'\binsurance\b',
  r'\binsurer\b',
  r'\bemail\b',
  r'\bmobile\b',
];

String? _cleanPaymentFrequency(String value) {
  final cleaned = _cleanGenericValue(value);
  if (cleaned == null) {
    return null;
  }

  final normalized = cleaned.toLowerCase();
  if (normalized.contains('monthly')) {
    return 'Monthly';
  }
  if (normalized.contains('quarter')) {
    return 'Quarterly';
  }
  if (normalized.contains('half')) {
    return 'Half-yearly';
  }
  if (normalized.contains('year')) {
    return 'Yearly';
  }
  if (normalized.contains('single')) {
    return 'Single';
  }
  return null;
}

String? _cleanVehicleNumber(String value) {
  final cleaned = _cleanGenericValue(value);
  if (cleaned == null) {
    return null;
  }

  final match = _vehicleNumberPattern.firstMatch(cleaned.toUpperCase());
  if (match == null) {
    return null;
  }

  final normalized = match.group(0)!.replaceAll(RegExp(r'[^A-Z0-9]'), '');
  if (_isLikelyMobileNumber(normalized) ||
      _cleanPolicyNumber(normalized) == normalized) {
    return null;
  }

  return normalized;
}

bool _isLikelyVehicleNumber(String value) {
  return _vehicleNumberPattern.hasMatch(value.toUpperCase());
}

String? _cleanVehicleModel(String value) {
  final cleaned = _cleanGenericValue(value);
  if (cleaned == null) {
    return null;
  }

  final lowered = cleaned.toLowerCase();
  if (!RegExp(r'[A-Za-z]').hasMatch(cleaned)) {
    return null;
  }
  if (_isLikelyVehicleNumber(cleaned)) {
    return null;
  }
  if (_looksLikeCompactPolicyIdentifier(cleaned)) {
    return null;
  }
  if (_containsAny(lowered, _vehicleModelRejectPatterns)) {
    return null;
  }
  if (RegExp(r'^\d+$').hasMatch(cleaned)) {
    return null;
  }

  return cleaned;
}

bool _looksLikeCompactPolicyIdentifier(String value) {
  final compact = value.replaceAll(RegExp(r'\s+'), '');
  if (compact.contains('/')) {
    return true;
  }
  if (compact.contains('-') &&
      RegExp(r'[A-Z]').hasMatch(compact) &&
      RegExp(r'\d').hasMatch(compact) &&
      !compact.contains('.')) {
    return true;
  }
  if (!value.contains(' ') &&
      RegExp(r'[A-Z]').hasMatch(compact) &&
      RegExp(r'\d').hasMatch(compact) &&
      compact.length >= 6) {
    return true;
  }
  return false;
}

const List<String> _vehicleModelRejectPatterns = <String>[
  r'\bengine\b',
  r'\bchassis\b',
  r'\bpolicy\b',
  r'\bregistration\b',
  r'\bfuel\b',
];

double _vehicleModelQualityBoost(String value) {
  if (value.split(' ').length >= 2) {
    return 0.02;
  }
  return 0.0;
}

List<String> _extractDateTokens(String value) {
  final cleaned = value.replaceAll(
    RegExp(r'(\d)(st|nd|rd|th)\b', caseSensitive: false),
    r'$1',
  );
  final tokens = <String>[
    ..._numericDatePattern.allMatches(cleaned).map((match) => match.group(0)!),
    ..._namedDatePattern.allMatches(cleaned).map((match) => match.group(0)!),
  ];
  return tokens.toSet().toList(growable: false);
}

DateTime? _tryParseDate(String value) {
  final cleaned = value
      .replaceAll(',', '')
      .replaceAll(RegExp(r'(\d)(st|nd|rd|th)\b', caseSensitive: false), r'$1')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  const patterns = <String>[
    'd/M/yyyy',
    'dd/MM/yyyy',
    'd-M-yyyy',
    'dd-MM-yyyy',
    'd.M.yyyy',
    'dd.MM.yyyy',
    'yyyy/M/d',
    'yyyy/MM/dd',
    'yyyy-M-d',
    'yyyy-MM-dd',
    'yyyy.M.d',
    'yyyy.MM.dd',
    'd MMM yyyy',
    'dd MMM yyyy',
    'd MMMM yyyy',
    'dd MMMM yyyy',
    'd-MMM-yyyy',
    'dd-MMM-yyyy',
    'd-MMMM-yyyy',
    'dd-MMMM-yyyy',
  ];

  for (final pattern in patterns) {
    try {
      final parsed = DateFormat(pattern, 'en_US').parseStrict(cleaned);
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (_) {
      continue;
    }
  }

  return null;
}

Set<double> _extractAmounts(String value) {
  final amounts = <double>{};
  for (final match in _amountPattern.allMatches(value)) {
    final rawAmount = match.group(1);
    if (rawAmount == null) {
      continue;
    }
    final parsed = double.tryParse(rawAmount.replaceAll(',', ''));
    if (parsed != null) {
      amounts.add(parsed);
    }
  }
  return amounts;
}

bool _isLikelyPremium(double value) => value > 0 && value < 10000000;

double _premiumAmountQualityBoost(double value) {
  if (value >= 1000 && value <= 2000000) {
    return 0.02;
  }
  return 0.0;
}

bool _isLikelyMobileNumber(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length == 10 ||
      (digits.length == 12 && digits.startsWith('91'));
}

String _amountKey(double value) => value.toStringAsFixed(2);

DateTime _atStartOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool _containsAny(String text, List<String> patterns) {
  for (final pattern in patterns) {
    if (RegExp(pattern, caseSensitive: false).hasMatch(text)) {
      return true;
    }
  }
  return false;
}
