import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/problems/model/problem.dart';
import 'package:project_1_cse_3240/problems/theme/app_colors.dart';
import 'package:project_1_cse_3240/problems/screens/problem_detail_page.dart';
import 'difficulty_chip.dart';
import 'tag.dart';

class ProblemCard extends StatelessWidget {
  final Problem problem;
  const ProblemCard({super.key,required this.problem});
  Widget _buildStatusIcon() {
    if (problem.userStatus==1) {

      Text("Solved 🎉", style: TextStyle(color: Colors.green));

      return Icon(Icons.check_circle,color: Colors.green);
      Text("Solved 🎉", style: TextStyle(color: Colors.green));
    } else if (problem.userStatus==0) {
      return Icon(Icons.cancel,color: Colors.red);
    } else {
      return SizedBox();                              //not attempted
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: InkWell(

        //return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context, MaterialPageRoute(builder: (_) =>ProblemDetailPage(problem: problem,title: '',),),
          );
        },
        child: Container(
          margin: EdgeInsets.all(6),
          padding: EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.15),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),

          /*decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200,blurRadius:2,offset:Offset(0,1),
            ),
          ],
        ),*/
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Expanded(
                    child: Text(
                      problem.title,
                      style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,),
                    ),
                  ),

                  _buildStatusIcon(),
                ],
              ),
              SizedBox(height:8),
              Wrap(
                spacing: 6,
                children: problem.tags.map((t) => Tag(text: t))
                    .toList(),
              ),



              SizedBox(height:12),
              Row(
                children: [
                  DifficultyChip(level: problem.difficulty),
                ],
              ),


              SizedBox(height: 6),
              Text("${problem.points} pts",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  )),

              SizedBox(height: 2),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (_) =>ProblemDetailPage(problem: problem,title: 'Solve',),),
                    );
                  },
                  child: Text('Solve →',
                    style: TextStyle(color: primaryBlue,fontWeight: FontWeight.bold,fontSize:15),
                  ),
                ),
              ),



              SizedBox(height:2),
              //alignment: Alignment.,
              Row(
                children: [
                  Text('${problem.submissionCount}submissions'),
                  //Spacer(),
                  //DifficultyChip(level: problem.difficulty),
                  // Spacer(),
                  //Text('${problem.submissionCount}submissions'),
                ],
              ),
            ],
          ),
        ),),
    );
  }
}