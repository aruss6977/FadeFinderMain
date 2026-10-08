import 'package:flutter/material.dart';
import '../data/mock_fighters.dart';
import '../widgets/fighter_card.dart';

// Screen 3: User's Own Fighter Profile & Record.
// Marked as StatelessWidget because it simply displays current account info.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Current user's profile represented by the first mock entry
    final currentUser = mockFighters[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fighter Card'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FighterCard(fighter: currentUser),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const ListTile(
                leading: Icon(Icons.history),
                title: Text('Sparring History'),
                subtitle: Text('4 recorded sparring sessions'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}