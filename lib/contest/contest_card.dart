import 'package:flutter/material.dart';
import 'dart:async';

class ContestCard extends StatefulWidget {
  final String title;
  final String description;
  final String date;
  final String time;      // start time  e.g. "14:00:00"
  final String endTime;   // end time    e.g. "16:00:00"
  final String category;
  final String duration;
  final VoidCallback? onAnalysisTap;
  final VoidCallback? onRegisterTap;
  final bool isRegistered;

  const ContestCard({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.endTime,
    required this.category,
    required this.duration,
    this.onAnalysisTap,
    this.onRegisterTap,
    this.isRegistered = false,
  }) : super(key: key);

  @override
  _ContestCardState createState() => _ContestCardState();
}

class _ContestCardState extends State<ContestCard> {
  late Timer _timer;

  // Derived every tick
  bool _isRunning = false;
  bool _isCompleted = false;
  Duration _remainingToStart = Duration.zero;

  late DateTime _startDt;
  late DateTime _endDt;

  @override
  void initState() {
    super.initState();
    _parseDates();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _tick());
    });
  }

  void _parseDates() {
    try {
      _startDt = DateTime.parse('${widget.date} ${widget.time}');
    } catch (_) {
      _startDt = DateTime.now();
    }
    try {
      _endDt = DateTime.parse('${widget.date} ${widget.endTime}');
    } catch (_) {
      _endDt = DateTime.now();
    }
  }

  void _tick() {
    final now = DateTime.now();
    _isCompleted = now.isAfter(_endDt);
    _isRunning = !_isCompleted && now.isAfter(_startDt);
    _remainingToStart = now.isBefore(_startDt)
        ? _startDt.difference(now)
        : Duration.zero;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final mins = d.inMinutes % 60;
    final secs = d.inSeconds % 60;
    if (days > 0) return '$days day${days > 1 ? 's' : ''} ${hours}h ${mins}m';
    if (hours > 0) return '${hours}h ${mins}m ${secs}s';
    if (mins > 0) return '${mins}m ${secs}s';
    return '${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final Color statusBg = _isCompleted
        ? const Color(0xFFF0F0F0)
        : _isRunning
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFE3F2FD);
    final Color statusBorder = _isCompleted
        ? Colors.grey.shade400
        : _isRunning
            ? Colors.green.shade400
            : Colors.blue.shade300;
    final Color statusText = _isCompleted
        ? Colors.grey.shade600
        : _isRunning
            ? Colors.green.shade700
            : Colors.blue.shade700;
    final String statusLabel =
        _isCompleted ? 'Completed' : _isRunning ? 'Live' : 'Upcoming';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + status badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(widget.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusBorder),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          color: statusText,
                          fontWeight: FontWeight.w600,
                          fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ── Description ──
            Text(widget.description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 10),

            // ── Meta ──
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                _meta(Icons.calendar_today_outlined, widget.date),
                _meta(Icons.access_time_outlined, widget.time),
                _meta(Icons.category_outlined, widget.category),
                _meta(Icons.timer_outlined, widget.duration),
              ],
            ),

            // ── Countdown (upcoming only) ──
            if (!_isCompleted && !_isRunning) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_bottom_rounded,
                        size: 15, color: Colors.orange.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Starts in: ${_formatDuration(_remainingToStart)}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),
            ],

            // ── Register button (upcoming + running) ──
            if (!_isCompleted) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: widget.isRegistered
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Registered'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade600,
                          side: BorderSide(color: Colors.green.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: widget.onRegisterTap,
                        icon: const Icon(Icons.app_registration, size: 16),
                        label: const Text('Register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
              ),
            ],

            // ── View Analysis (completed only) ──
            if (_isCompleted && widget.onAnalysisTap != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onAnalysisTap,
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: const Text('View Analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}