import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _interestsController;
  late TextEditingController _routineController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ChatProvider>().userProfile;

    _nameController = TextEditingController(text: profile?.name ?? '');
    _nicknameController = TextEditingController(text: profile?.nickname ?? '');
    _interestsController = TextEditingController(
      text: profile?.interests.join(', ') ?? '',
    );
    _routineController = TextEditingController(
      text: profile?.dailyRoutine.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _interestsController.dispose();
    _routineController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        name: _nameController.text.trim(),
        nickname:
            _nicknameController.text.trim().isEmpty
                ? null
                : _nicknameController.text.trim(),
        interests:
            _interestsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
        dailyRoutine:
            _routineController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
        createdAt:
            context.read<ChatProvider>().userProfile?.createdAt ??
            DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<ChatProvider>().updateUserProfile(profile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile berhasil disimpan!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Kamu'),
        actions: [
          TextButton(onPressed: _saveProfile, child: const Text('Simpan')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Dasar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Panggilan (opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tentang Kamu',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _interestsController,
                      decoration: const InputDecoration(
                        labelText: 'Minat & Hobi',
                        hintText: 'Contoh: membaca, musik, olahraga',
                        border: OutlineInputBorder(),
                        helperText: 'Pisahkan dengan koma',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _routineController,
                      decoration: const InputDecoration(
                        labelText: 'Rutinitas Harian',
                        hintText: 'Contoh: bangun pagi, olahraga, kerja',
                        border: OutlineInputBorder(),
                        helperText: 'Pisahkan dengan koma',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final profile = chatProvider.userProfile;
                if (profile == null) return const SizedBox.shrink();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Info Akun',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Dibuat: ${_formatDate(profile.createdAt)}'),
                        Text(
                          'Terakhir diupdate: ${_formatDate(profile.updatedAt)}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
