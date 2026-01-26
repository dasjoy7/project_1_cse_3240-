import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/running_contest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contest_model.dart';

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key});

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const Icon(Icons.menu, color: Colors.black),
          title: const Text("Math Olympiad", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          actions: const [
             Padding(
               padding: EdgeInsets.only(right: 16.0),
               child: CircleAvatar(backgroundImage: NetworkImage('https://via.placeholder.com/150')),
             )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                labelColor: Colors.blue[800],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.grey,
                tabs: const [Tab(text: "Upcoming"), Tab(text: "Completed")],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            ContestListView(status: 'upcoming'),
            ContestListView(status: 'completed'),
          ],
        ),
      ),
    );
  }
}

class ContestListView extends StatelessWidget {
  final String status;
  const ContestListView({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    return FutureBuilder(
      future: client.from('contests').select().eq('status', status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return const Center(child: Text("No contests found"));
        }

        final contests = (snapshot.data as List).map((e) => Contest.fromMap(e)).toList();

        return RefreshIndicator(
          onRefresh: () async => (context as Element).markNeedsBuild(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: contests.length,
            itemBuilder: (context, index) {
              final contest = contests[index];
              return status == 'upcoming' 
                  ? _buildUpcomingCard(context, contest) 
                  : _buildCompletedCard(contest);
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingCard(BuildContext context, Contest contest) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RunningContestPage())),
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(contest.imageUrl ?? 'https://via.placeholder.com/400x200', height: 160, width: double.infinity, fit: BoxFit.cover),
                Positioned(
                  top: 15, left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                    child: const Text("REGISTRATION OPEN", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contest.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(contest.startTime.toString().substring(0, 16), style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Register Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard(Contest contest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.emoji_events_outlined, color: Colors.teal),
        ),
        title: Text(contest.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Rank: 42", style: TextStyle(color: Colors.grey)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Text("Score: 92/100", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}