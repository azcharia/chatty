import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with TickerProviderStateMixin {
  final ReminderService _reminderService = ReminderService();
  late TabController _tabController;

  List<Reminder> _allReminders = [];
  List<Reminder> _upcomingReminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);

    try {
      await _reminderService.initialize();
      final allReminders = await _reminderService.getAllReminders();
      final upcomingReminders = await _reminderService.getUpcomingReminders();

      setState(() {
        _allReminders = allReminders;
        _upcomingReminders = upcomingReminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading reminders: $e', isError: true);
    }
  }

  Future<void> _completeReminder(Reminder reminder) async {
    if (reminder.id == null) return;

    try {
      await _reminderService.completeReminder(reminder.id!);
      await _loadReminders();
      _showSnackBar('✅ Reminder "${reminder.title}" selesai!');
    } catch (e) {
      _showSnackBar('Error completing reminder: $e', isError: true);
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    if (reminder.id == null) return;

    final confirmed = await _showConfirmDialog(
      'Hapus Reminder',
      'Yakin mau hapus reminder "${reminder.title}"?',
    );

    if (!confirmed) return;

    try {
      await _reminderService.deleteReminder(reminder.id!);
      await _loadReminders();
      _showSnackBar('🗑️ Reminder "${reminder.title}" dihapus!');
    } catch (e) {
      _showSnackBar('Error deleting reminder: $e', isError: true);
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Ya'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 Reminders'),
        backgroundColor: Colors.purple.shade100,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
            Tab(text: 'All', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [_buildUpcomingTab(), _buildAllTab()],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateReminderDialog(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (_upcomingReminders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada reminder yang akan datang',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Chat dengan Akane untuk set reminder!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReminders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _upcomingReminders.length,
        itemBuilder: (context, index) {
          final reminder = _upcomingReminders[index];
          return _buildReminderCard(reminder);
        },
      ),
    );
  }

  Widget _buildAllTab() {
    if (_allReminders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada reminder',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Mulai chat dengan Akane untuk membuat reminder!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReminders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allReminders.length,
        itemBuilder: (context, index) {
          final reminder = _allReminders[index];
          return _buildReminderCard(reminder);
        },
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final isCompleted = reminder.isCompleted;
    final isPast = reminder.isPast && !isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color:
          isCompleted
              ? Colors.green.shade50
              : isPast
              ? Colors.red.shade50
              : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isCompleted
                  ? Colors.green
                  : isPast
                  ? Colors.red
                  : Colors.purple,
          child: Text(
            reminder.categoryIcon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reminder.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: isPast ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(reminder.dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: isPast ? Colors.red : Colors.grey,
                          fontWeight: isPast ? FontWeight.bold : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (!isCompleted) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: isPast ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          reminder.timeUntil,
                          style: TextStyle(
                            fontSize: 12,
                            color: isPast ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: isCompleted ? 48 : 96,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCompleted) ...[
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _completeReminder(reminder),
                  tooltip: 'Mark as completed',
                ),
              ],
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteReminder(reminder),
                tooltip: 'Delete reminder',
              ),
            ],
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showCreateReminderDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('💡 Tip'),
            content: const Text(
              'Untuk membuat reminder, chat dengan Akane!\n\n'
              'Contoh:\n'
              '• "Ingatkan aku telepon mama besok jam 10"\n'
              '• "Set reminder meeting nanti sore jam 3"\n'
              '• "Reminder beli susu jam 8 malam"\n\n'
              'Akane akan otomatis buatkan reminder untuk kamu! 🌸',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to chat
                },
                child: const Text('Chat dengan Akane'),
              ),
            ],
          ),
    );
  }
}
