import 'package:dod_partner/model/my_ordermodel.dart';
import 'package:intl/intl.dart';


class OrderHelper{

  static String recurringScheduleHumanRange(
      RecurringBooking booking, {
        String Function(RouteModel route)? pickupTimeExtractor,
        String Function(RouteModel route)? dropTimeExtractor,
      }) {
    final timeFmt = DateFormat('hh:mm a');

    String _ordinal(int d) {
      if (d >= 11 && d <= 13) return '${d}th';
      switch (d % 10) {
        case 1:
          return '${d}st';
        case 2:
          return '${d}nd';
        case 3:
          return '${d}rd';
        default:
          return '${d}th';
      }
    }

    final _pickupExtractor = pickupTimeExtractor ??
            (RouteModel r) {
          try {
            return (r as dynamic).pickup_time?.toString() ?? '';
          } catch (_) {
            try {
              return (r as dynamic).toJson()['pickup_time']?.toString() ?? '';
            } catch (_) {
              return '';
            }
          }
        };

    final _dropExtractor = dropTimeExtractor ??
            (RouteModel r) {
          try {
            return (r as dynamic).drop_time?.toString() ?? '';
          } catch (_) {
            try {
              return (r as dynamic).toJson()['drop_time']?.toString() ?? '';
            } catch (_) {
              return '';
            }
          }
        };

    // date parsers (reuse your logic)
    DateTime? _parseDate(String s) {
      if (s.trim().isEmpty) return null;
      final iso = DateTime.tryParse(s);
      if (iso != null) return DateTime(iso.year, iso.month, iso.day);
      final candidates = ['MM/dd/yyyy', 'yyyy-MM-dd', 'dd/MM/yyyy'];
      for (final fmt in candidates) {
        try {
          final dt = DateFormat(fmt).parseStrict(s);
          return DateTime(dt.year, dt.month, dt.day);
        } catch (_) {}
      }
      return null;
    }

    DateTime? _parseTimeOfDay(String t) {
      if (t.trim().isEmpty) return null;
      final patterns = ['h:mm a', 'hh:mm a', 'H:mm', 'HH:mm'];
      for (final p in patterns) {
        try {
          final dt = DateFormat(p).parseLoose(t);
          return dt;
        } catch (_) {}
      }
      return null;
    }

    DateTime? _combine(DateTime dateOnly, String timeString) {
      final tt = _parseTimeOfDay(timeString);
      if (tt == null) return null;
      return DateTime(dateOnly.year, dateOnly.month, dateOnly.day, tt.hour, tt.minute);
    }

    // if no routes, try parsing full datetimes in start/end
    if (booking.routes.isEmpty) {
      final startIso = DateTime.tryParse(booking.startDate);
      final endIso = DateTime.tryParse(booking.endDate);
      if (startIso != null && endIso != null) {
        // fall back to explicit range with ordinals/months
        final sDay = _ordinal(startIso.day);
        final sMonth = DateFormat('MMMM').format(startIso);
        final sYear = startIso.year;
        final sTime = timeFmt.format(startIso).toLowerCase();

        final eDay = _ordinal(endIso.day);
        final eMonth = DateFormat('MMMM').format(endIso);
        final eYear = endIso.year;
        final eTime = timeFmt.format(endIso).toLowerCase();

        if (startIso.year == endIso.year && startIso.month == endIso.month) {
          if (startIso.day == endIso.day && sTime == eTime) {
            return '$sDay $sMonth, $sYear at $sTime';
          }
          if (sTime == eTime) {
            return '${startIso.day} to $eDay $sMonth, $sYear at $sTime';
          }
          return '$sDay $sMonth, $sYear at $sTime to $eDay $eMonth, $eYear at $eTime';
        } else {
          return '$sDay $sMonth, $sYear at $sTime to $eDay $eMonth, $eYear at $eTime';
        }
      }
      return 'Schedule not available';
    }

    // normal flow: use first route pickup + last route drop
    final first = booking.routes.first;
    final last = booking.routes.last;

    final pickupStr = _pickupExtractor(first);
    final dropStr = _dropExtractor(last);

    final startDateOnly = _parseDate(booking.startDate);
    final endDateOnly = _parseDate(booking.endDate);

    DateTime? startDt;
    DateTime? endDt;

    if (startDateOnly != null && pickupStr.isNotEmpty) {
      startDt = _combine(startDateOnly, pickupStr);
    } else {
      // fallback to full ISO parse
      final p = DateTime.tryParse(booking.startDate);
      if (p != null) startDt = p;
    }

    if (endDateOnly != null && dropStr.isNotEmpty) {
      // Note: when you asked earlier to use the "first date" for both times,
      // comment the next line and use startDateOnly instead of endDateOnly.
      endDt = _combine(endDateOnly, dropStr);
    } else {
      final p = DateTime.tryParse(booking.endDate);
      if (p != null) endDt = p;
    }

    if (startDt == null || endDt == null) return 'Schedule not available';

    // Build human-friendly strings
    final sDayOrd = _ordinal(startDt.day);
    final eDayOrd = _ordinal(endDt.day);
    final sMonth = DateFormat('MMMM').format(startDt);
    final eMonth = DateFormat('MMMM').format(endDt);
    final sYear = startDt.year;
    final eYear = endDt.year;

    final sTime = timeFmt.format(startDt).toLowerCase();
    final eTime = timeFmt.format(endDt).toLowerCase();

    // CASES:
    // 1) same day & same time -> "3rd September, 2025 at 12:00 am"
    if (startDt.year == endDt.year && startDt.month == endDt.month && startDt.day == endDt.day) {
      if (sTime == eTime) {
        return '$sDayOrd $sMonth, $sYear at $sTime';
      } else {
        return '$sDayOrd $sMonth, $sYear at $sTime to $eTime';
      }
    }

    // 2) same month & year
    if (startDt.year == endDt.year && startDt.month == endDt.month) {
      if (sTime == eTime) {
        // "3rd to 4th September, 2025 at 12:00 am"
        return '${startDt.day} to $eDayOrd $sMonth, $sYear at $sTime';
      } else {
        // "3rd September, 2025 at 9:00 am to 4th September, 2025 at 12:00 pm"
        return '$sDayOrd $sMonth, $sYear at $sTime to $eDayOrd $sMonth, $sYear at $eTime';
      }
    }

    return '$sDayOrd $sMonth, $sYear at $sTime to $eDayOrd $eMonth, $eYear at $eTime';
  }


  static int rec(RecurringBooking booking) {
    try {
      final String pt = booking.routes.first.pickupTime.trim(); // "9:00 AM"
      final String dt = booking.routes.first.dropTime.trim();   // "12:00 PM"

      print(pt);
      print(dt);

      // Parse times like "9:00 AM"
      final timeFormat = DateFormat("h:mm a");

      // Convert to a time-of-day DateTime (dummy date)
      final start = timeFormat.parse(pt);
      final end = timeFormat.parse(dt);

      // Make real DateTimes on the same date
      final now = DateTime.now();
      final startDt = DateTime(now.year, now.month, now.day, start.hour, start.minute);
      final endDt = DateTime(now.year, now.month, now.day, end.hour, end.minute);

      // Calculate difference in hours
      return endDt.difference(startDt).inHours;
    } catch (e) {
      return 0;
    }
  }

}