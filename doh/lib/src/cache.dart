// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
// import 'dart:convert';

import '../model/doh_response.dart';
import '../model/doh_enum.dart';

/// Cache for resource records that have been received.
///
/// There can be multiple entries for the same name and type.
///
/// The cache is updated with a list of records, because it needs to remove
/// all entries that correspond to the name and type of the name/type
/// combinations of records that should be updated.  For example, a host may
/// remove one of its IP addresses and report the remaining address as a
/// response - then we need to clear all previous entries for that host before
/// updating the cache.
class DohAnswerCache {
  /// Creates a new DohAnswerCache.
  DohAnswerCache();

  final Map<int, SplayTreeMap<String, List<DoHAnswer>>> _cache =
      <int, SplayTreeMap<String, List<DoHAnswer>>>{};

  /// The number of entries in the cache.
  int get entryCount {
    int count = 0;
    for (final SplayTreeMap<String, List<DoHAnswer>> map in _cache.values) {
      for (final List<DoHAnswer> records in map.values) {
        count += records.length;
      }
    }
    return count;
  }

  /// Update the records in this cache.
  void updateRecords(List<DoHAnswer> records) {
    final Map<int, Set<String>> seenRecordTypes = <int, Set<String>>{};
    for (final DoHAnswer record in records) {
      seenRecordTypes[record.type] ??=
          Set<String>(); // ignore: prefer_collection_literals
      if (seenRecordTypes[record.type]!.add(record.name)) {
        _cache[record.type] ??= SplayTreeMap<String, List<DoHAnswer>>();
        _cache[record.type]![record.name] = <DoHAnswer>[record];
      } else {
        _cache[record.type]![record.name]!.add(record);
      }
      // var a = _cache[record.type]![record.name]! as List<DoHAnswer>;
      // print(json.encode(a));
    }
  }

  /// Get a record from this cache.
  List<T> lookup<T extends DoHAnswer>(String name, DohRequestType type) {
    final int? restype = dohRequestTypeMap[type];
    if (restype == null) {
      return [];
    }
    // assert(ResourceRecordType.debugAssertValid(type));
    // print("cache lookup:$name $type");
    final int time = DateTime.now().millisecondsSinceEpoch;
    final SplayTreeMap<String, List<DoHAnswer>>? candidates = _cache[restype];
    if (candidates == null) {
      // print("candidates==null");
      return [];
    }

    final List<DoHAnswer>? candidateRecords = candidates[name];
    if (candidateRecords == null) {
      // print("candidateRecords==null");
      return [];
    }
    candidateRecords
        .removeWhere((DoHAnswer candidate) => candidate.validUntil < time);
    return candidateRecords.cast<T>();
  }

  /// kick
  void kick(String name, DohRequestType type) {
    final int? restype = dohRequestTypeMap[type];
    if (restype == null) {
      return;
    }
    _cache[restype]?.remove(name);
  }
}
