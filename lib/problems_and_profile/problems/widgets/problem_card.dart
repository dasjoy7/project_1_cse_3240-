import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/problems_and_profile/problems/model/problem.dart';
import 'package:project_1_cse_3240/problems_and_profile/problems/theme/app_colors.dart';
import 'package:project_1_cse_3240/problems_and_profile/problems/screens/problem_detail_page.dart';
import 'difficulty_chip.dart';
import 'tag.dart';

class ProblemCard extends StatelessWidget {
  final Problem problem;

  const ProblemCard({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    return InkWell(borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ProblemDetailPage(problem: problem, title: '',),),);
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                problem.title, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),

            SizedBox(height: 8),
            Wrap(spacing: 6,
              children: problem.tags.map((t) => Tag(text: t)).toList(),),

            SizedBox(height: 8),
            Row(children: [ DifficultyChip(level: problem.difficulty),
              Spacer(),
              Text('${problem.submissionCount} submissions'),
            ],),

            //SizedBox(height: 3),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProblemDetailPage(
                        problem: problem,
                        title: 'Solve',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Solve →',
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],

        ),
      ),
    );
  }
}