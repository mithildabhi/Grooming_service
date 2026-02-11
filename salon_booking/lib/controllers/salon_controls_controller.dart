// lib/controllers/salon_controls_controller.dart
// Pure UI controller with dummy data — no API logic

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class DummyStaff {
  final int id;
  final String name;
  final String role;
  final String avatarUrl;

  DummyStaff({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl = '',
  });
}

class DummyService {
  final int id;
  final String name;
  final String category;
  final double price;

  DummyService({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });
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
  final RxList<DummyStaff> staffList = <DummyStaff>[].obs;

  // ═══════════ SERVICE DURATIONS ═══════════
  final RxMap<int, int> serviceDurations = <int, int>{}.obs;
  final RxMap<int, int> serviceBufferTimes = <int, int>{}.obs;
  final RxList<DummyService> serviceList = <DummyService>[].obs;

  // ═══════════ BLOCKOUT DATES ═══════════
  final RxList<DateTime> blockoutDates = <DateTime>[].obs;

  // ═══════════ LOADING FLAGS ═══════════
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initShopHours();
    _initDummyStaff();
    _initDummyServices();
    _initBlockouts();
  }

  // ────────── SHOP HOURS ──────────

  void _initShopHours() {
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
    Future.delayed(const Duration(seconds: 1), () {
      isSaving.value = false;
      Get.snackbar(
        'Saved',
        'Shop hours updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF121A22),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  // ────────── STAFF SCHEDULES ──────────

  void _initDummyStaff() {
    staffList.value = [
      DummyStaff(id: 1, name: 'Raju Sharma', role: 'Senior Stylist'),
      DummyStaff(id: 2, name: 'Priya Patel', role: 'Beautician'),
      DummyStaff(id: 3, name: 'Amit Kumar', role: 'Barber'),
      DummyStaff(id: 4, name: 'Sunita Devi', role: 'Nail Technician'),
    ];

    for (final staff in staffList) {
      staffSchedules[staff.id] = _defaultStaffSchedule();
    }
  }

  List<StaffDaySchedule> _defaultStaffSchedule() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days.map((day) {
      return StaffDaySchedule(
        day: day,
        isWorking: day != 'Sunday',
        shiftStart: const TimeOfDay(hour: 10, minute: 0),
        shiftEnd: const TimeOfDay(hour: 18, minute: 0),
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
    Future.delayed(const Duration(seconds: 1), () {
      isSaving.value = false;
      Get.snackbar(
        'Saved',
        'Staff schedule updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF121A22),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  // ────────── SERVICE DURATIONS ──────────

  void _initDummyServices() {
    serviceList.value = [
      DummyService(id: 1, name: "Men's Haircut", category: 'Hair', price: 200),
      DummyService(id: 2, name: 'Beard Trim', category: 'Grooming', price: 100),
      DummyService(id: 3, name: 'Hair Coloring', category: 'Hair', price: 800),
      DummyService(id: 4, name: 'Facial', category: 'Skin', price: 500),
      DummyService(id: 5, name: 'Manicure', category: 'Nails', price: 350),
      DummyService(
        id: 6,
        name: 'Head Massage',
        category: 'Relaxation',
        price: 300,
      ),
      DummyService(id: 7, name: 'Shave', category: 'Grooming', price: 150),
    ];

    for (final svc in serviceList) {
      serviceDurations[svc.id] = 30; // default 30 min
      serviceBufferTimes[svc.id] = 0; // default 0 buffer
    }
  }

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

  void _initBlockouts() {
    blockoutDates.value = [
      DateTime(2026, 3, 14), // Holi
      DateTime(2026, 8, 15), // Independence Day
      DateTime(2026, 10, 2), // Gandhi Jayanti
    ];
  }

  void addBlockoutDate(DateTime date) {
    if (!blockoutDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    )) {
      blockoutDates.add(date);
      blockoutDates.sort();
    }
  }

  void removeBlockoutDate(int index) {
    blockoutDates.removeAt(index);
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

      // 3. Calculate Staff Capacity
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
}
