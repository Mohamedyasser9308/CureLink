import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A medicine's commercial names from the bundled local catalog.
class MedicineCatalogEntry {
  const MedicineCatalogEntry({
    required this.commercialNameEn,
    required this.commercialNameAr,
  });

  final String commercialNameEn;
  final String commercialNameAr;
}

/// Loads and searches the bundled Egyptian medicine catalog.
class MedicineCatalogService {
  MedicineCatalogService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/data/egyptian-drugs.json';
  static const defaultLimit = 20;

  final AssetBundle _bundle;
  Future<List<MedicineCatalogEntry>>? _entriesFuture;

  /// Finds entries containing [query] in either commercial name.
  ///
  /// An empty query returns immediately. English comparisons are
  /// case-insensitive. [limit] caps the number of returned results.
  Future<List<MedicineCatalogEntry>> search(
    String query, {
    int limit = defaultLimit,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty || limit <= 0) {
      return const [];
    }

    final entries = await _loadEntries();
    final englishQuery = normalizedQuery.toLowerCase();
    final matches = <MedicineCatalogEntry>[];

    for (final entry in entries) {
      if (entry.commercialNameEn.toLowerCase().contains(englishQuery) ||
          entry.commercialNameAr.contains(normalizedQuery)) {
        matches.add(entry);
        if (matches.length == limit) break;
      }
    }

    return List.unmodifiable(matches);
  }

  Future<List<MedicineCatalogEntry>> _loadEntries() {
    return _entriesFuture ??= _readEntries();
  }

  Future<List<MedicineCatalogEntry>> _readEntries() async {
    try {
      final source = await _bundle.loadString(assetPath);
      final decoded = jsonDecode(source);
      if (decoded is! List<dynamic>) {
        throw const FormatException('The catalog root must be a JSON array.');
      }

      final entries = <MedicineCatalogEntry>[];
      for (var index = 0; index < decoded.length; index++) {
        final record = decoded[index];
        if (record is! Map<String, dynamic> ||
            record['commercial_name_en'] is! String ||
            record['commercial_name_ar'] is! String) {
          throw FormatException(
            'Catalog record at index $index must contain string '
            'commercial_name_en and commercial_name_ar fields.',
          );
        }
        entries.add(
          MedicineCatalogEntry(
            commercialNameEn: record['commercial_name_en'] as String,
            commercialNameAr: record['commercial_name_ar'] as String,
          ),
        );
      }

      return List.unmodifiable(entries);
    } on FormatException catch (error) {
      _entriesFuture = null;
      throw FormatException('Could not parse medicine catalog: $error');
    } on FlutterError catch (error) {
      _entriesFuture = null;
      throw StateError(
        'Could not load medicine catalog asset "$assetPath": ${error.message}',
      );
    } catch (error) {
      _entriesFuture = null;
      throw StateError(
        'Could not load medicine catalog asset "$assetPath": $error',
      );
    }
  }
}
