import 'package:flutter/material.dart';

class RunningContestPage extends StatelessWidget {
  const RunningContestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Column(
          children: [
            Text("Regional Selection 2024", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Round 1 • In Progress", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("TIME REMAINING", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeBox("01", "HRS"),
                const Text(" : ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                _buildTimeBox("45", "MIN"),
                const Text(" : ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                _buildTimeBox("23", "SEC"),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.people_outline, size: 16),
                   SizedBox(width: 8),
                   Text("1,842 Participants", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Problem Set", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            _buildProblemItem("A", "Prime Factorization Secrets", "100 pts", true),
            _buildProblemItem("B", "Geometry of the Circle", "150 pts", null),
            _buildProblemItem("C", "The Recursive Sequence", "200 pts", false),
            _buildProblemItem("D", "Polynomial Roots", "250 pts", null),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.message, color: Colors.white),
        label: const Text("Ask Clarification", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTimeBox(String val, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
          ),
          child: Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProblemItem(String letter, String title, String pts, bool? isSolved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Text(letter, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(pts, style: const TextStyle(fontSize: 12)),
        trailing: isSolved == null 
            ? const Icon(Icons.circle_outlined, color: Colors.grey)
            : Icon(isSolved ? Icons.check_circle : Icons.cancel, color: isSolved ? Colors.green : Colors.red),
      ),
    );
  }
}