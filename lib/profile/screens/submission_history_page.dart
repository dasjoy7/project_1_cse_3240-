import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/profile_service.dart';
import '../models/submission_detail.dart';

class SubmissionHistoryPage extends StatelessWidget {
  const SubmissionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = ProfileService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Submission History", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<SubmissionDetail>>(
        future: profileService.fetchRealSubmissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No submissions yet."));
          }

          final submissions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Icon(
                    sub.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: sub.isCorrect ? Colors.green : Colors.red,
                  ),
                  title: Text(sub.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('MMM dd, yyyy • hh:mm a').format(sub.submitDate)),
                  trailing: Text(
                    sub.isCorrect ? "CORRECT" : "WRONG",
                    style: TextStyle(color: sub.isCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}