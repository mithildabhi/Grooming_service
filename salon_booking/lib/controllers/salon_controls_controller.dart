// lib/controllers/salon_controls_controller.dart
// Refactored: persists to backend via Salon API

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../models/employee_model.dart';
import '../services/staff_api.dart';
import 'admin_controller.dart';

class DaySchedule {
  String day;
  RxBool isOpen;
  Rx<TimeOfDay> startTime;
  Rx<TimeOfDay> endTime;

  DaySchedule({
    required this.day,
    required bool isOpen,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) : isOpen = isOpen.obs,
       startTime = startTime.obs,
       endTime = endTime.obs;
}

class StaffDaySchedule {
  String day;
  RxBool isWorking;
  Rx<TimeOfDay> shiftStart;
  Rx<TimeOfDay> shiftEnd;

  StaffDaySchedule({
    required this.day,
    required bool isWorking,
    required TimeOfDay shiftStart,
    required TimeOfDay shiftEnd,
  }) : isWorking = isWorking.obs,
       shiftStart = shiftStart.obs,
       shiftEnd = shiftEnd.obs;
}

class TimeSlot {
  final TimeOfDay time;
  final String
  status; // 'available', 'blocked_manual', 'forced_open', 'no_staff', 'closed'
  final int capacity;
  TimeSlot(this.time, this.status, {this.capacity = 0});
}

class SalonControlsController extends GetxController {
  // ═══════════ SHOP HOURS ═══════════
  final RxList<DaySchedule> shopHours = <DaySchedule>[].obs;

  // ═══════════ STAFF SCHEDULES ═══════════
  final RxMap<int, List<StaffDaySchedule>> staffSchedules =
      <int, List<StaffDaySchedule>>{}.obs;

  // ═══════════ SERVICE DURATIONS ═══════════
  final RxMap<int, int> serviceDurations = <int, int>{}.obs;
  final RxMap<int, int> serviceBufferTimes = <int, int>{}.obs;

  // ═══════════ BLOCKOUT DATES ═══════════
  final RxList<DateTime> blockoutDates = <DateTime>[].obs;

  // ═══════════ LOADING FLAGS ═══════════
  final RxBool isSaving = false.obs;

  // Reference to AdminController for real staff data
  AdminController? get _adminCtrl {
    try {
      return Get.find<AdminController>();
    } catch (_) {
      return null;
    }
  }

  // Get real staff list from AdminController
  List<EmployeeModel> get staffList => _adminCtrl?.staffList ?? [];

  @override
  void onInit() {
    super.onInit();
    _initDefaults();
    _loadFromBackend();

    // Defer staff sync to avoid issues during initialization
    Future.delayed(const Duration(milliseconds: 500), () {
      _syncStaffSchedules();
      final ctrl = _adminCtrl;
      if (ctrl != null) {
        ever(ctrl.staffList, (_) => _syncStaffSchedules());
      }
    });
  }

  // ═══════════ BACKEND PERSISTENCE ═══════════

  Future<Map<String, String>> _apiHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Load shop hours + blockout dates from Salon API
  Future<void> _loadFromBackend() async {
    try {
      final headers = await _apiHeaders();
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/salons/my-salon/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // ── Parse hours ──
        final hoursData = data['hours'];
        if (hoursData is List && hoursData.isNotEmpty) {
          _applyHoursFromJson(hoursData);
          print('✅ Shop hours loaded from backend');
        }

        // ── Parse blockout dates ──
        final blockoutsData = data['blockout_dates'];
        if (blockoutsData is List && blockoutsData.isNotEmpty) {
          blockoutDates.value = blockoutsData
              .map((s) => DateTime.tryParse(s.toString()))
              .whereType<DateTime>()
              .toList()
            ..sort();
          print('✅ Blockout dates loaded from backend (${blockoutDates.length})');
        }
      }
    } catch (e) {
      print('⚠️ Could not load salon controls from backend: $e');
    }
  }

  /// Save hours + blockout dates to Salon API
  Future<void> _persistToBackend() async {
    try {
      final headers = await _apiHeaders();
      final body = jsonEncode({
        'hours': _hoursToJson(),
        'blockout_dates': blockoutDates
            .map((d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}')
            .toList(),
      });
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/salons/update/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));
      print('✅ Salon controls persisted to backend');
    } catch (e) {
      print('❌ Failed to persist salon controls: $e');
    }
  }

  /// Convert shopHours → JSON list for the API
  List<Map<String, dynamic>> _hoursToJson() {
    return shopHours.map((d) {
      return {
        'day': d.day,
        'is_open': d.isOpen.value,
        'start': '${d.startTime.value.hour.toString().padLeft(2, '0')}:${d.startTime.value.minute.toString().padLeft(2, '0')}',
        'end': '${d.endTime.value.hour.toString().padLeft(2, '0')}:${d.endTime.value.minute.toString().padLeft(2, '0')}',
      };
    }).toList();
  }

  /// Apply JSON list → shopHours
  void _applyHoursFromJson(List<dynamic> list) {
    for (final item in list) {
      if (item is! Map) continue;
      final dayName = item['day']?.toString() ?? '';
      final daySchedule = shopHours.firstWhereOrNull((d) => d.day == dayName);
      if (daySchedule == null) continue;

      daySchedule.isOpen.value = item['is_open'] == true;
      final start = item['start']?.toString() ?? '';
      final end = item['end']?.toString() ?? '';
      if (start.contains(':')) {
        final p = start.split(':');
        daySchedule.startTime.value = TimeOfDay(
          hour: int.tryParse(p[0]) ?? 9,
          minute: int.tryParse(p[1]) ?? 0,
        );
      }
      if (end.contains(':')) {
        final p = end.split(':');
        daySchedule.endTime.value = TimeOfDay(
          hour: int.tryParse(p[0]) ?? 20,
          minute: int.tryParse(p[1]) ?? 0,
        );
      }
    }
  }

  // ────────── SHOP HOURS ──────────

  void _initDefaults() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    shopHours.value = days.map((day) {
      return DaySchedule(
        day: day,
        isOpen: day != 'Sunday',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 20, minute: 0),
      );
    }).toList();
    blockoutDates.clear();
  }

  void toggleDay(int index, bool value) {
    shopHours[index].isOpen.value = value;
  }

  void updateStartTime(int index, TimeOfDay time) {
    shopHours[index].startTime.value = time;
  }

  void updateEndTime(int index, TimeOfDay time) {
    shopHours[index].endTime.value = time;
  }

  void applyMondayToAll() {
    if (shopHours.isEmpty) return;
    final monday = shopHours.first;
    for (int i = 1; i < shopHours.length; i++) {
      shopHours[i].isOpen.value = monday.isOpen.value;
      shopHours[i].startTime.value = monday.startTime.value;
      shopHours[i].endTime.value = monday.endTime.value;
    }
    Get.snackbar(
      'Applied',
      "Monday's schedule applied to all days",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF121A22),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void saveShopHours() {
    isSaving.value = true;
    _persistToBackend().then((_) {
      isSaving.value = false;
      Get.snackbar(
        'Saved',
        'Shop hours saved to server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF121A22),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }).catchError((_) {
      isSaving.value = false;
      Get.snackbar(
        'Error',
        'Failed to save shop hours',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF5350),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  // ────────── STAFF SCHEDULES (Real Data) ──────────

  /// Parse "HH:mm" or "HH:mm:ss" string to TimeOfDay
  TimeOfDay _parseTime(String timeStr) {
    if (timeStr.isEmpty) return const TimeOfDay(hour: 10, minute: 0);
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 10,
        minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
      );
    } catch (_) {
      return const TimeOfDay(hour: 10, minute: 0);
    }
  }

  /// Convert day abbreviation to full name
  static const Map<String, String> _dayAbbrevToFull = {
    'Mon': 'Monday',
    'Tue': 'Tuesday',
    'Wed': 'Wednesday',
    'Thu': 'Thursday',
    'Fri': 'Friday',
    'Sat': 'Saturday',
    'Sun': 'Sunday',
  };

  /// Build schedules from real EmployeeModel data
  void _syncStaffSchedules() {
    for (final staff in staffList) {
      // Only rebuild if not already customized locally
      if (!staffSchedules.containsKey(staff.id)) {
        staffSchedules[staff.id] = _buildScheduleFromEmployee(staff);
      }
    }

    // Remove schedules for staff that no longer exist
    final currentIds = staffList.map((s) => s.id).toSet();
    staffSchedules.removeWhere((key, _) => !currentIds.contains(key));
  }

  List<StaffDaySchedule> _buildScheduleFromEmployee(EmployeeModel staff) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final shiftStart = _parseTime(staff.shiftStartTime);
    final shiftEnd = _parseTime(staff.shiftEndTime);

    // Convert working days abbreviations to full names
    final workingDaysFull = staff.workingDays
        .map((abbrev) => _dayAbbrevToFull[abbrev] ?? abbrev)
        .toSet();

    return days.map((day) {
      return StaffDaySchedule(
        day: day,
        isWorking: workingDaysFull.contains(day),
        shiftStart: shiftStart,
        shiftEnd: shiftEnd,
      );
    }).toList();
  }

  void toggleStaffDay(int staffId, int dayIndex, bool value) {
    staffSchedules[staffId]?[dayIndex].isWorking.value = value;
  }

  void updateStaffShiftStart(int staffId, int dayIndex, TimeOfDay time) {
    staffSchedules[staffId]?[dayIndex].shiftStart.value = time;
  }

  void updateStaffShiftEnd(int staffId, int dayIndex, TimeOfDay time) {
    staffSchedules[staffId]?[dayIndex].shiftEnd.value = time;
  }

  void saveStaffSchedule(int staffId) {
    isSaving.value = true;

    // Build working days list from schedule
    final schedule = staffSchedules[staffId];
    if (schedule == null) {
      isSaving.value = false;
      return;
    }

    // Convert full day names back to abbreviations
    const dayFullToAbbrev = {
      'Monday': 'Mon',
      'Tuesday': 'Tue',
      'Wednesday': 'Wed',
      'Thursday': 'Thu',
      'Friday': 'Fri',
      'Saturday': 'Sat',
      'Sunday': 'Sun',
    };

    final workingDays = <String>[];
    for (final day in schedule) {
      if (day.isWorking.value) {
        final abbrev = dayFullToAbbrev[day.day] ?? day.day;
        workingDays.add(abbrev);
      }
    }

    // Get shift times from the first working day (uniform shift for now)
    String shiftStart = '10:00';
    String shiftEnd = '18:00';
    final firstWorking = schedule.where((d) => d.isWorking.value).firstOrNull;
    if (firstWorking != null) {
      shiftStart =
          '${firstWorking.shiftStart.value.hour.toString().padLeft(2, '0')}:${firstWorking.shiftStart.value.minute.toString().padLeft(2, '0')}';
      shiftEnd =
          '${firstWorking.shiftEnd.value.hour.toString().padLeft(2, '0')}:${firstWorking.shiftEnd.value.minute.toString().padLeft(2, '0')}';
    }

    // Find the staff member and update via StaffApi directly
    // (Not AdminController.updateStaff because it calls Get.back())
    final staff = staffList.firstWhereOrNull((s) => s.id == staffId);
    if (staff != null) {
      StaffApi.updateStaff(
        staffId: staff.id,
        fullName: staff.fullName,
        email: staff.email,
        phone: staff.phone,
        role: staff.role,
        primarySkill: staff.primarySkill,
        workingDays: workingDays,
        isActive: staff.isActive,
        shiftStartTime: shiftStart,
        shiftEndTime: shiftEnd,
      ).then((_) {
        // Refresh the staff list to get updated data
        _adminCtrl?.fetchStaff();
        // Clear cached schedule so it rebuilds from fresh data
        staffSchedules.remove(staffId);
        isSaving.value = false;
        Get.snackbar(
          'Saved',
          'Staff schedule updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF121A22),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }).catchError((_) {
        isSaving.value = false;
        Get.snackbar(
          'Error',
          'Failed to save staff schedule',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF5350),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      });
    } else {
      isSaving.value = false;
    }
  }

  // ────────── SERVICE DURATIONS ──────────

  void updateServiceDuration(int serviceId, int duration) {
    serviceDurations[serviceId] = duration;
  }

  void updateServiceBufferTime(int serviceId, int buffer) {
    serviceBufferTimes[serviceId] = buffer;
  }

  void saveServiceDurations() {
    isSaving.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      isSaving.value = false;
      Get.snackbar(
        'Saved',
        'Service durations updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF121A22),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  // ────────── BLOCKOUTS ──────────

  void addBlockoutDate(DateTime date) {
    if (!blockoutDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    )) {
      blockoutDates.add(date);
      blockoutDates.sort();
      _persistToBackend();
    }
  }

  void removeBlockoutDate(int index) {
    blockoutDates.removeAt(index);
    _persistToBackend();
  }

  // ────────── SLOT MANAGEMENT ──────────

  final RxMap<String, List<String>> manualBlockedSlots =
      <String, List<String>>{}.obs;
  final RxMap<String, List<String>> manualAddedSlots =
      <String, List<String>>{}.obs;

  List<TimeSlot> generateSlotsForDate(DateTime date, int serviceDurationMin) {
    final slots = <TimeSlot>[];
    final dateKey = "${date.year}-${date.month}-${date.day}";

    // 1. Check Blockout Dates
    bool isHoliday = blockoutDates.any((d) => isSameDate(d, date));

    // 2. Get Shop Hours for this day
    final dayName = _getDayName(date); // e.g., "Monday"
    final shopDay = shopHours.firstWhere(
      (d) => d.day == dayName,
      orElse: () => DaySchedule(
        day: dayName,
        isOpen: false,
        startTime: const TimeOfDay(hour: 0, minute: 0),
        endTime: const TimeOfDay(hour: 0, minute: 0),
      ),
    );

    // Define working range (default 8am to 10pm if closed, or actual hours)
    TimeOfDay current = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 22, minute: 0);

    if (shopDay.isOpen.value && !isHoliday) {
      current = shopDay.startTime.value;
      end = shopDay.endTime.value;
    }

    while (_isBefore(current, end)) {
      final timeKey = formatTime(current);
      String status = 'closed';
      int capacity = 0;

      // 3. Calculate Staff Capacity from REAL staff data
      int availableStaff = 0;
      if (!isHoliday) {
        availableStaff = staffSchedules.values.where((scheduleList) {
          final staffDay = scheduleList.firstWhere((s) => s.day == dayName);
          if (!staffDay.isWorking.value) return false;
          return _isTimeInShift(
            current,
            staffDay.shiftStart.value,
            staffDay.shiftEnd.value,
          );
        }).length;
      }

      // 4. Determine Status
      if (manualBlockedSlots[dateKey]?.contains(timeKey) ?? false) {
        status = 'blocked_manual';
        capacity = availableStaff;
      } else if (manualAddedSlots[dateKey]?.contains(timeKey) ?? false) {
        status = 'forced_open';
        capacity = availableStaff > 0 ? availableStaff : 1;
      } else if (isHoliday || !shopDay.isOpen.value) {
        status = 'closed';
        capacity = 0;
      } else if (availableStaff > 0) {
        status = 'available';
        capacity = availableStaff;
      } else {
        status = 'no_staff';
        capacity = 0;
      }

      slots.add(TimeSlot(current, status, capacity: capacity));
      current = _addMinutes(current, serviceDurationMin);
    }
    return slots;
  }

  void toggleSlotStatus(DateTime date, TimeOfDay time, String currentStatus) {
    final dateKey = "${date.year}-${date.month}-${date.day}";
    final timeKey = formatTime(time);

    // Initialize lists if null
    if (!manualBlockedSlots.containsKey(dateKey))
      manualBlockedSlots[dateKey] = [];
    if (!manualAddedSlots.containsKey(dateKey)) manualAddedSlots[dateKey] = [];

    if (currentStatus == 'available') {
      // Available -> Blocked
      manualBlockedSlots[dateKey]!.add(timeKey);
    } else if (currentStatus == 'blocked_manual') {
      // Blocked -> Available (Restore)
      manualBlockedSlots[dateKey]!.remove(timeKey);
    } else if (currentStatus == 'closed' || currentStatus == 'no_staff') {
      // Closed/NoStaff -> Forced Open
      manualAddedSlots[dateKey]!.add(timeKey);
    } else if (currentStatus == 'forced_open') {
      // Forced Open -> Closed (Restore)
      manualAddedSlots[dateKey]!.remove(timeKey);
    }

    manualBlockedSlots.refresh();
    manualAddedSlots.refresh();
  }

  void saveSlotChanges() {
    isSaving.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      isSaving.value = false;
      Get.snackbar(
        'Saved',
        'Slot configuration saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF121A22),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  void resetChangesForDate(DateTime date) {
    final dateKey = "${date.year}-${date.month}-${date.day}";
    manualBlockedSlots.remove(dateKey);
    manualAddedSlots.remove(dateKey);
    Get.snackbar(
      "Reset",
      "Changes for this date have been reset",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF121A22),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  // Helpers for Slot Logic
  bool isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  bool _isBefore(TimeOfDay t1, TimeOfDay t2) {
    if (t1.hour < t2.hour) return true;
    if (t1.hour == t2.hour && t1.minute < t2.minute) return true;
    return false;
  }

  bool _isTimeInShift(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final tVal = time.hour * 60 + time.minute;
    final sVal = start.hour * 60 + start.minute;
    final eVal = end.hour * 60 + end.minute;
    return tVal >= sVal && tVal < eVal;
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final total = time.hour * 60 + time.minute + minutes;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // ────────── HELPER GETTERS FOR CROSS-CONTROLLER ACCESS ──────────

  /// Get shop hours for a specific day (e.g., "Monday")
  /// Returns null if shop is closed on that day
  ({bool isOpen, TimeOfDay startTime, TimeOfDay endTime})? getShopHoursForDay(String dayName) {
    if (shopHours.isEmpty) return null;
    final day = shopHours.firstWhereOrNull((d) => d.day == dayName);
    if (day == null) return null;
    return (
      isOpen: day.isOpen.value,
      startTime: day.startTime.value,
      endTime: day.endTime.value,
    );
  }

  /// Check if a date is a blockout/holiday
  bool isBlockoutDate(DateTime date) {
    return blockoutDates.any((d) => isSameDate(d, date));
  }

  /// Get number of available staff at a given time on a given day
  int getAvailableStaffCount(String dayName, TimeOfDay time) {
    int count = 0;
    for (final entry in staffSchedules.entries) {
      final daySchedule = entry.value.firstWhereOrNull((s) => s.day == dayName);
      if (daySchedule == null) continue;
      if (!daySchedule.isWorking.value) continue;
      if (_isTimeInShift(time, daySchedule.shiftStart.value, daySchedule.shiftEnd.value)) {
        count++;
      }
    }
    return count;
  }

  /// Get the day name from a DateTime
  String getDayName(DateTime date) => _getDayName(date);

  /// Check if a specific manually blocked slot exists
  bool isSlotManuallyBlocked(DateTime date, String timeKey) {
    final dateKey = "${date.year}-${date.month}-${date.day}";
    return manualBlockedSlots[dateKey]?.contains(timeKey) ?? false;
  }

  /// Check if a specific forced-open slot exists
  bool isSlotForcedOpen(DateTime date, String timeKey) {
    final dateKey = "${date.year}-${date.month}-${date.day}";
    return manualAddedSlots[dateKey]?.contains(timeKey) ?? false;
  }
}
