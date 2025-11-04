import 'package:flutter/material.dart';
import '../models/patient_schedule.dart';
import '../services/patient_schedule_service.dart';
import '../models/patient.dart';

class PatientScheduleScreen extends StatefulWidget {
  final Patient patient;
  final int doctorId;

  const PatientScheduleScreen({
    super.key,
    required this.patient,
    required this.doctorId,
  });

  @override
  State<PatientScheduleScreen> createState() => _PatientScheduleScreenState();
}

class _PatientScheduleScreenState extends State<PatientScheduleScreen> {
  Future<List<PatientSchedule>>? _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _refreshSchedules();
  }

  void _refreshSchedules() {
    setState(() {
      _schedulesFuture = PatientScheduleService.getSchedulesByChild(widget.patient.patientId!);
    });
  }

  Future<void> _toggleIsDone(PatientSchedule schedule) async {
    if (schedule.scheduleId == null) return;

    final newIsDone = !schedule.IsDone;

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await PatientScheduleService.toggleIsDone(schedule.scheduleId!, newIsDone);
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading indicator
      
      // Refresh schedules
      _refreshSchedules();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newIsDone 
              ? 'Dose marked as completed successfully'
              : 'Dose marked as pending'),
            backgroundColor: newIsDone ? Colors.green.shade600 : Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading indicator
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update dose status: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _rescheduleDose(PatientSchedule schedule) async {
    // Show date picker
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: schedule.planDate != null && schedule.planDate!.isNotEmpty
          ? DateTime.tryParse(schedule.planDate!) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.grey.shade800,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && schedule.scheduleId != null) {
      // Format date as YYYY-MM-DD
      final formattedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        await PatientScheduleService.rescheduleDose(schedule.scheduleId!, formattedDate);
        
        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading indicator
        
        // Refresh schedules
        _refreshSchedules();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Dose rescheduled successfully'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading indicator
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reschedule: ${e.toString()}'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Vaccination Schedule',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSchedules,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<PatientSchedule>>(
        future: _schedulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading schedule...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Failed to Load Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final schedules = snapshot.data ?? [];
          
          // Group schedules by planDate (or givenDate if planDate is null, or "Pending" if both null)
          final Map<String?, List<PatientSchedule>> groupedSchedules = {};
          for (var schedule in schedules) {
            String? key;
            // Prioritize planDate for grouping, fallback to givenDate, then null for pending
            if (schedule.planDate != null && schedule.planDate!.isNotEmpty) {
              key = schedule.planDate; // Use planDate as-is for grouping
            } else if (schedule.givenDate != null) {
              // Use givenDate if planDate is not available
              final date = schedule.givenDate!;
              key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            } else {
              key = null; // null means "Pending/Not Scheduled"
            }
            groupedSchedules.putIfAbsent(key, () => []).add(schedule);
          }

          // Sort dates (nulls last) and sort schedules within each group
          final sortedDates = groupedSchedules.keys.toList()
            ..sort((a, b) {
              if (a == null && b == null) return 0;
              if (a == null) return 1;
              if (b == null) return -1;
              return a.compareTo(b);
            });

          if (schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Schedule Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No vaccination schedule found for this patient',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade500, Colors.blue.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: const Icon(
                          Icons.child_care,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patient.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.patient.gender} • ${widget.patient.city ?? 'No city'}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Schedule Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.event_note,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'All Scheduled Doses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Schedule List grouped by date
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedDates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, dateIndex) {
                    final dateKey = sortedDates[dateIndex];
                    final schedulesForDate = groupedSchedules[dateKey]!;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: dateKey != null
                                  ? LinearGradient(
                                      colors: [Colors.green.shade400, Colors.green.shade600],
                                    )
                                  : LinearGradient(
                                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                                    ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  dateKey != null ? Icons.calendar_today : Icons.schedule,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                                                 Expanded(
                                   child: Text(
                                     dateKey != null ? _formatDate(dateKey) : 'Pending / Not Scheduled',
                                     style: const TextStyle(
                                       fontSize: 16,
                                       fontWeight: FontWeight.bold,
                                       color: Colors.white,
                                     ),
                                   ),
                                 ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    '${schedulesForDate.length} ${schedulesForDate.length == 1 ? 'Dose' : 'Doses'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Doses List
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: schedulesForDate.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, doseIndex) {
                                final schedule = schedulesForDate[doseIndex];
                                                                 return Container(
                                   padding: const EdgeInsets.all(14),
                                   decoration: BoxDecoration(
                                     color: Colors.grey.shade50,
                                     borderRadius: BorderRadius.circular(12),
                                     border: Border.all(color: Colors.grey.shade200),
                                   ),
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       // Dose Number Badge (show injection icon if IsDone)
                                       Container(
                                         width: 40,
                                         height: 40,
                                         decoration: BoxDecoration(
                                           gradient: schedule.IsDone
                                               ? LinearGradient(
                                                   colors: [Colors.green.shade400, Colors.green.shade600],
                                                   begin: Alignment.topLeft,
                                                   end: Alignment.bottomRight,
                                                 )
                                               : LinearGradient(
                                                   colors: [Colors.blue.shade400, Colors.blue.shade600],
                                                   begin: Alignment.topLeft,
                                                   end: Alignment.bottomRight,
                                                 ),
                                           borderRadius: BorderRadius.circular(10),
                                           boxShadow: [
                                             BoxShadow(
                                               color: (schedule.IsDone ? Colors.green : Colors.blue)
                                                   .withOpacity(0.2),
                                               blurRadius: 4,
                                               offset: const Offset(0, 2),
                                             ),
                                           ],
                                         ),
                                         child: Center(
                                           child: schedule.IsDone
                                               ? const Icon(
                                                   Icons.medical_services,
                                                   color: Colors.white,
                                                   size: 20,
                                                 )
                                               : Text(
                                                   '${doseIndex + 1}',
                                                   style: const TextStyle(
                                                     fontSize: 16,
                                                     fontWeight: FontWeight.bold,
                                                     color: Colors.white,
                                                   ),
                                                 ),
                                         ),
                                       ),
                                       const SizedBox(width: 12),
                                       
                                       // Dose Name and Status
                                       Expanded(
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             Text(
                                               schedule.dose?.name ?? 'Dose #${schedule.doseId}',
                                               style: TextStyle(
                                                 fontSize: 15,
                                                 fontWeight: FontWeight.w600,
                                                 color: Colors.grey.shade800,
                                               ),
                                               maxLines: 2,
                                               overflow: TextOverflow.ellipsis,
                                             ),
                                             const SizedBox(height: 6),
                                             // Show plan date if available
                                             if (schedule.planDate != null && schedule.planDate!.isNotEmpty) ...[
                                               Row(
                                                 children: [
                                                   Icon(
                                                     Icons.event,
                                                     size: 12,
                                                     color: Colors.blue.shade600,
                                                   ),
                                                   const SizedBox(width: 4),
                                                   Flexible(
                                                     child: Text(
                                                       'Planned: ${_formatDate(schedule.planDate!)}',
                                                       style: TextStyle(
                                                         fontSize: 12,
                                                         color: Colors.blue.shade600,
                                                         fontWeight: FontWeight.w500,
                                                       ),
                                                       maxLines: 1,
                                                       overflow: TextOverflow.ellipsis,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                               const SizedBox(height: 2),
                                             ],
                                             // Show given date only when IsDone is true
                                             if (schedule.IsDone) ...[
                                               Row(
                                                 children: [
                                                   Icon(
                                                     Icons.check_circle,
                                                     size: 12,
                                                     color: Colors.green.shade600,
                                                   ),
                                                   const SizedBox(width: 4),
                                                   Flexible(
                                                     child: Text(
                                                       schedule.givenDate != null
                                                           ? 'Given: ${_formatDateString(schedule.givenDate!)}'
                                                           : 'Completed',
                                                       style: TextStyle(
                                                         fontSize: 12,
                                                         color: Colors.green.shade600,
                                                         fontWeight: FontWeight.w500,
                                                       ),
                                                       maxLines: 1,
                                                       overflow: TextOverflow.ellipsis,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                             ],
                                           ],
                                         ),
                                       ),
                                       const SizedBox(width: 6),
                                       
                                       // Action Buttons Column
                                       Column(
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                           // Injection Icon Button to toggle IsDone
                                           if (schedule.scheduleId != null)
                                             Tooltip(
                                               message: schedule.IsDone ? 'Ungive' : 'Give',
                                               preferBelow: false,
                                               decoration: BoxDecoration(
                                                 color: Colors.grey.shade800,
                                                 borderRadius: BorderRadius.circular(8),
                                               ),
                                               textStyle: const TextStyle(
                                                 color: Colors.white,
                                                 fontSize: 12,
                                                 fontWeight: FontWeight.w500,
                                               ),
                                               child: Container(
                                                 decoration: BoxDecoration(
                                                   color: schedule.IsDone 
                                                       ? Colors.green.shade50 
                                                       : Colors.purple.shade50,
                                                   borderRadius: BorderRadius.circular(10),
                                                   border: Border.all(
                                                     color: schedule.IsDone 
                                                         ? Colors.green.shade200 
                                                         : Colors.purple.shade200,
                                                   ),
                                                 ),
                                                 child: Material(
                                                   color: Colors.transparent,
                                                   child: InkWell(
                                                     onTap: () => _toggleIsDone(schedule),
                                                     borderRadius: BorderRadius.circular(10),
                                                     child: Padding(
                                                       padding: const EdgeInsets.all(8),
                                                       child: Icon(
                                                         Icons.medical_services,
                                                         color: schedule.IsDone 
                                                             ? Colors.green.shade600 
                                                             : Colors.purple.shade600,
                                                         size: 20,
                                                       ),
                                                     ),
                                                   ),
                                                 ),
                                               ),
                                             ),
                                           // Reschedule Button (only show if not already done)
                                           if (!schedule.IsDone && schedule.scheduleId != null) ...[
                                             const SizedBox(height: 6),
                                             Container(
                                               decoration: BoxDecoration(
                                                 color: Colors.orange.shade50,
                                                 borderRadius: BorderRadius.circular(10),
                                                 border: Border.all(color: Colors.orange.shade200),
                                               ),
                                               child: Material(
                                                 color: Colors.transparent,
                                                 child: InkWell(
                                                   onTap: () => _rescheduleDose(schedule),
                                                   borderRadius: BorderRadius.circular(10),
                                                   child: Padding(
                                                     padding: const EdgeInsets.symmetric(
                                                       horizontal: 8,
                                                       vertical: 8,
                                                     ),
                                                     child: Icon(
                                                       Icons.schedule,
                                                       color: Colors.orange.shade600,
                                                       size: 18,
                                                     ),
                                                   ),
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ],
                                       ),
                                     ],
                                   ),
                                 );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return _formatDateString(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateString(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
