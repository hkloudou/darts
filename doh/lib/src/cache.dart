// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:async';

import '../model/doh_response.dart';
import '../model/doh_enum.dart';
import 'dart:developer' as developer;

/// DNS response record cache
/// 
/// Manages in-memory cache for DNS response records with TTL expiration and LRU cleanup.
/// Cache is organized by record type and domain name for efficient query and update operations.
/// 
/// Features:
/// - TTL-based automatic expiration
/// - LRU cache cleanup strategy
/// - Memory usage monitoring
/// - Statistics collection
class DohAnswerCache {
  /// Cache storage structure: type -> domain -> record list
  final Map<int, SplayTreeMap<String, List<DoHAnswer>>> _cache =
      <int, SplayTreeMap<String, List<DoHAnswer>>>{};

  /// LRU access records: domain+type -> last access time
  final Map<String, int> _accessTimes = <String, int>{};

  /// Cache configuration
  int _maxEntries = 1000; // Maximum cache entries
  int _maxMemoryMB = 50; // Maximum memory usage (MB)
  Duration _defaultTtl = const Duration(hours: 1); // Default TTL
  Timer? _cleanupTimer;

  /// Statistics
  int _hitCount = 0;
  int _missCount = 0;
  int _evictionCount = 0;

  /// Create new cache instance
  /// 
  /// [maxEntries] Maximum cache entries, default 1000
  /// [maxMemoryMB] Maximum memory usage (MB), default 50MB
  /// [defaultTtl] Default TTL time, default 1 hour
  /// [cleanupInterval] Cleanup interval, default 5 minutes
  DohAnswerCache({
    int maxEntries = 1000,
    int maxMemoryMB = 50,
    Duration defaultTtl = const Duration(hours: 1),
    Duration cleanupInterval = const Duration(minutes: 5),
  })  : _maxEntries = maxEntries,
        _maxMemoryMB = maxMemoryMB,
        _defaultTtl = defaultTtl {
    // Start periodic cleanup task
    _startCleanupTimer(cleanupInterval);
  }

  /// Get total cache entry count
  int get entryCount {
    int count = 0;
    for (final map in _cache.values) {
      for (final records in map.values) {
        count += records.length;
      }
    }
    return count;
  }

  /// Get cache hit rate
  double get hitRate {
    final total = _hitCount + _missCount;
    return total > 0 ? _hitCount / total : 0.0;
  }

  /// Get cache statistics
  Map<String, dynamic> get statistics => {
        'entryCount': entryCount,
        'hitCount': _hitCount,
        'missCount': _missCount,
        'hitRate': hitRate,
        'evictionCount': _evictionCount,
        'typeCount': _cache.length,
        'memoryUsageEstimateKB': _estimateMemoryUsage(),
      };

  /// Configure cache parameters
  void configure({
    int? maxEntries,
    int? maxMemoryMB,
    Duration? defaultTtl,
  }) {
    if (maxEntries != null) _maxEntries = maxEntries;
    if (maxMemoryMB != null) _maxMemoryMB = maxMemoryMB;
    if (defaultTtl != null) _defaultTtl = defaultTtl;

    // If limits are lowered, immediately trigger cleanup
    if (maxEntries != null && entryCount > _maxEntries) {
      _performLruCleanup();
    }
  }

  /// Update records in cache
  /// 
  /// This method clears all old records of the same domain and type, then adds new records.
  /// This ensures cache consistency and avoids stale data interference.
  void updateRecords(List<DoHAnswer> records) {
    if (records.isEmpty) return;

    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final processedTypes = <int, Set<String>>{};

      for (final record in records) {
        // Ensure record has valid TTL
        if (record.validUntil <= currentTime) {
          record.validUntil = currentTime + (_defaultTtl.inMilliseconds);
        }

        // Initialize type cache
        _cache[record.type] ??= SplayTreeMap<String, List<DoHAnswer>>();
        
        processedTypes[record.type] ??= <String>{};

        // If this is the first record for this type+domain, clear old records
        if (processedTypes[record.type]!.add(record.name)) {
          _cache[record.type]![record.name] = <DoHAnswer>[record];
        } else {
          // Add to existing record list
          _cache[record.type]![record.name]!.add(record);
        }

        // Update access time
        _updateAccessTime(record.name, record.type);
      }

      developer.log(
        'Updated cache with ${records.length} records',
        name: 'doh.cache',
      );

      // Check if cleanup is needed
      _checkAndCleanup();
    } catch (e) {
      developer.log(
        'Failed to update cache: $e',
        name: 'doh.cache',
        level: 900, // WARNING
      );
    }
  }

  /// Look up records from cache
  /// 
  /// [name] Domain name
  /// [type] DNS record type
  /// 
  /// Returns list of matching valid records, automatically filters expired records
  List<T> lookup<T extends DoHAnswer>(String name, DohRequestType type) {
    final resType = dohRequestTypeMap[type];
    if (resType == null) {
      _missCount++;
      return [];
    }

    final typeCache = _cache[resType];
    if (typeCache == null) {
      _missCount++;
      return [];
    }

    final records = typeCache[name];
    if (records == null || records.isEmpty) {
      _missCount++;
      return [];
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    // Filter expired records
    records.removeWhere((record) {
      final expired = record.validUntil < currentTime;
      if (expired) {
        developer.log(
          'Removed expired record for $name ($type)',
          name: 'doh.cache',
        );
      }
      return expired;
    });

    if (records.isEmpty) {
      // If all records are expired, remove this entry
      typeCache.remove(name);
      _missCount++;
      return [];
    }

    // Update access time
    _updateAccessTime(name, resType);
    _hitCount++;

    // Safe type casting
    try {
      return records.cast<T>();
    } catch (e) {
      developer.log(
        'Type cast error in cache lookup: $e',
        name: 'doh.cache',
        level: 900, // WARNING
      );
      return [];
    }
  }

  /// Remove cache for specific domain and type
  void kick(String name, DohRequestType type) {
    final resType = dohRequestTypeMap[type];
    if (resType == null) return;

    final removed = _cache[resType]?.remove(name);
    if (removed != null) {
      _accessTimes.remove(_makeAccessKey(name, resType));
      developer.log(
        'Kicked cache for $name ($type)',
        name: 'doh.cache',
      );
    }
  }

  /// Clear all cache for specific type
  void clearType(DohRequestType type) {
    final resType = dohRequestTypeMap[type];
    if (resType == null) return;

    final typeCache = _cache[resType];
    if (typeCache != null) {
      // Clean up access time records
      for (final name in typeCache.keys) {
        _accessTimes.remove(_makeAccessKey(name, resType));
      }
      typeCache.clear();
      developer.log(
        'Cleared all cache for type $type',
        name: 'doh.cache',
      );
    }
  }

  /// Clear all cache
  void clearAll() {
    final entryCount = this.entryCount;
    _cache.clear();
    _accessTimes.clear();
    _hitCount = 0;
    _missCount = 0;
    _evictionCount = 0;

    developer.log(
      'Cleared all cache ($entryCount entries)',
      name: 'doh.cache',
    );
  }

  /// Manually clean up expired records
  int cleanupExpired() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    int removedCount = 0;

    for (final typeCache in _cache.values) {
      final expiredKeys = <String>[];
      
      for (final entry in typeCache.entries) {
        final name = entry.key;
        final records = entry.value;
        
        // Remove expired records
        records.removeWhere((record) {
          final expired = record.validUntil < currentTime;
          if (expired) removedCount++;
          return expired;
        });

        // If no records left for this domain, mark for deletion
        if (records.isEmpty) {
          expiredKeys.add(name);
        }
      }

      // Remove empty domain entries
      for (final key in expiredKeys) {
        typeCache.remove(key);
        _accessTimes.remove(_makeAccessKey(key, 0)); // type doesn't matter for removal
      }
    }

    if (removedCount > 0) {
      developer.log(
        'Cleaned up $removedCount expired records',
        name: 'doh.cache',
      );
    }

    return removedCount;
  }

  /// Release resources
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    clearAll();
  }

  /// Start periodic cleanup timer
  void _startCleanupTimer(Duration interval) {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(interval, (_) {
      cleanupExpired();
      _checkAndCleanup();
    });
  }

  /// Update access time
  void _updateAccessTime(String name, int type) {
    _accessTimes[_makeAccessKey(name, type)] = DateTime.now().millisecondsSinceEpoch;
  }

  /// Generate access time record key
  String _makeAccessKey(String name, int type) => '$name:$type';

  /// Check if cleanup is needed and perform cleanup
  void _checkAndCleanup() {
    if (entryCount > _maxEntries || _estimateMemoryUsage() > _maxMemoryMB * 1024) {
      _performLruCleanup();
    }
  }

  /// Perform LRU cleanup
  void _performLruCleanup() {
    if (_accessTimes.isEmpty) return;

    // Sort by access time, remove least recently used records
    final sortedEntries = _accessTimes.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final targetRemovalCount = (entryCount * 0.1).ceil(); // Remove 10% of records
    int removedCount = 0;

    for (final entry in sortedEntries) {
      if (removedCount >= targetRemovalCount) break;

      final parts = entry.key.split(':');
      if (parts.length != 2) continue;

      final name = parts[0];
      final type = int.tryParse(parts[1]);
      if (type == null) continue;

      final typeCache = _cache[type];
      if (typeCache != null && typeCache.remove(name) != null) {
        _accessTimes.remove(entry.key);
        removedCount++;
        _evictionCount++;
      }
    }

    if (removedCount > 0) {
      developer.log(
        'LRU cleanup removed $removedCount entries',
        name: 'doh.cache',
      );
    }
  }

  /// Estimate memory usage (KB)
  int _estimateMemoryUsage() {
    int totalSize = 0;
    for (final typeCache in _cache.values) {
      for (final records in typeCache.values) {
        for (final record in records) {
          // Rough estimate of memory usage per record
          totalSize += record.name.length * 2; // UTF-16 characters
          totalSize += record.data.length * 2;
          totalSize += 64; // Other fields and object overhead
        }
      }
    }
    return (totalSize / 1024).ceil(); // Convert to KB
  }
}
