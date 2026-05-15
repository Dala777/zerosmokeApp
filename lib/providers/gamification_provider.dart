import 'package:flutter/material.dart';
import '../models/emotional_entry.dart';
import '../models/support_contact.dart';
import '../models/dynamic_achievement.dart';
import '../models/reward_item.dart';
import '../services/gamification_service.dart';

class GamificationProvider extends ChangeNotifier {
  final GamificationService _service;

  List<EmotionalEntry> _emotionalEntries = [];
  List<SupportContact> _supportContacts = [];
  List<DynamicAchievement> _dynamicAchievements = [];
  List<RewardItem> _rewards = [];
  int _motivationPoints = 0;
  bool _isLoading = false;
  String _errorMessage = '';

  GamificationProvider(this._service);

  List<EmotionalEntry> get emotionalEntries => _emotionalEntries;
  List<SupportContact> get supportContacts => _supportContacts;
  List<DynamicAchievement> get dynamicAchievements => _dynamicAchievements;
  List<RewardItem> get rewards => _rewards;
  int get motivationPoints => _motivationPoints;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void clear() {
    _emotionalEntries = [];
    _supportContacts = [];
    _dynamicAchievements = [];
    _rewards = [];
    _motivationPoints = 0;
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Emotional Journal
  Future<void> loadEmotionalEntries() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _service.getEmotionalEntries();
      if (res['success']) {
        _emotionalEntries = (res['data'] as List)
            .map((e) => EmotionalEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveEmotionalEntry(EmotionalEntry entry) async {
    try {
      final res = await _service.saveEmotionalEntry(entry);
      if (res['success']) {
        final saved = EmotionalEntry.fromJson(Map<String, dynamic>.from(res['data']));
        _emotionalEntries.insert(0, saved);
        notifyListeners();
        return true;
      }
      _errorMessage = res['message'] ?? '';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // Support Network
  Future<void> loadSupportContacts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _service.getSupportContacts();
      if (res['success']) {
        _supportContacts = (res['data'] as List)
            .map((c) => SupportContact.fromJson(Map<String, dynamic>.from(c)))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSupportContact(SupportContact contact) async {
    try {
      final res = await _service.saveSupportContact(contact);
      if (res['success']) {
        final saved = SupportContact.fromJson(Map<String, dynamic>.from(res['data']));
        _supportContacts.insert(0, saved);
        notifyListeners();
        return true;
      }
      _errorMessage = res['message'] ?? '';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> deleteSupportContact(String id) async {
    try {
      final res = await _service.deleteSupportContact(id);
      if (res['success']) {
        _supportContacts.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      }
      _errorMessage = res['message'] ?? '';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // Rewards
  Future<void> loadRewards() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _service.getRewards();
      if (res['success']) {
        _rewards = (res['data'] as List)
            .map((r) => RewardItem.fromJson(Map<String, dynamic>.from(r)))
            .toList();
        _motivationPoints = res['points'] ?? 0;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unlockReward(String code) async {
    try {
      final res = await _service.unlockReward(code);
      if (res['success']) {
        await loadRewards();
        return true;
      }
      _errorMessage = res['message'] ?? '';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // Dynamic Achievements
  Future<void> loadDynamicAchievements() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _service.getDynamicAchievements();
      if (res['success']) {
        _dynamicAchievements = (res['data'] as List)
            .map((a) => DynamicAchievement.fromJson(Map<String, dynamic>.from(a)))
            .toList();
        _motivationPoints = res['motivationPoints'] ?? 0;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        loadEmotionalEntries(),
        loadSupportContacts(),
        loadDynamicAchievements(),
        loadRewards(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
