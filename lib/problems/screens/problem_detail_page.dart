import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/problems/model/problem.dart';
import '../services/supabase_service.dart';

class ProblemDetailPage extends StatefulWidget {
  final Problem problem;
  ProblemDetailPage({
    super.key,
    required this.problem,
    required String title,////

  });
  @override
  State<ProblemDetailPage> createState() => _ProblemDetailPageState();
}
class _ProblemDetailPageState extends State<ProblemDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final SupabaseService _service=SupabaseService();
  bool _isSubmitting=false;
  bool _showHint=false;
  @override
  void dispose()
  {
    _controller.dispose();
    super.dispose();
  }
  Future<void>_submit()async
  {
    setState(()=>_isSubmitting=true);
    final bool correct=await _service.submitAnswer(
      problemId: widget.problem.id,
      userAnswer: _controller.text,
    );
    if(!mounted)return;
    setState(()=>_isSubmitting=false);


    ////////////////////////////////////////////////////////////////////////////////////////
    if (correct)
    {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🎉🎉🎉",style: TextStyle(fontSize: 40)),
              SizedBox(height: 10),
              Text("Correct Answer!",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
            ],
          ),
        ),
      );
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wrong ❌"),
          backgroundColor: Colors.red,
        ),
      );
    }

  }
  @override
  Widget build(BuildContext context) {
    final hasHint=widget.problem.hint !=null && widget.problem.hint!.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Row(/////////////////////////////////////////
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.problem.title,
                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18,),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "💎 ${widget.problem.points}",
                style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),


      ),
      body: Padding(
        padding:EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // ======================
              // PROBLEM DESCRIPTION
              // ======================
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: Colors.blue,blurRadius:200,offset: Offset(0,1),
                  ),
                  ],
                ),
                child: Text(
                  widget.problem.description ?? 'No description available',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black,fontWeight: FontWeight.bold,
                  ),
                ),
              ),


              // ======================
              // ANSWER FIELD
              // ======================
              SizedBox(height:40),
              Container(
                padding: EdgeInsets.symmetric(horizontal:18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                    color: Colors.black87,blurRadius:1,offset: Offset(0,1),
                  ),],
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your answer...',
                    border: InputBorder.none,
                  ),
                ),
              ),


              // ======================
              // HINT BUTTON
              // ======================
              SizedBox(height:20),
              GestureDetector(
                onTap: () {
                  setState(()=>_showHint=!_showHint);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal:16,vertical:14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: Colors.white, blurRadius:5,offset: Offset(0,1),
                    ),],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline,color:Colors.blue),
                          SizedBox(width:8),
                          Text('Need a hint?',
                            style: TextStyle(fontSize:16,fontWeight: FontWeight.normal,color: Colors.grey),
                          ),
                        ],
                      ),
                      Icon(_showHint?Icons.expand_less:Icons.expand_more,
                      ),
                    ],
                  ),
                ),
              ),

              if(_showHint && hasHint)
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(widget.problem.hint!,
                    style: TextStyle(fontSize:15),
                  ),
                ),

              // ======================
              // SUBMIT BUTTON
              // ======================
              SizedBox(height:32),
              Center(
                child: SizedBox(
                  width:215,
                  height:55,
                  child: ElevatedButton(
                    onPressed: _isSubmitting?null: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting?CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Submit Answer',
                          style: TextStyle(fontSize:17,fontWeight: FontWeight.w600,color: Colors.white,),
                        ),
                        SizedBox(width:8),
                        Icon(Icons.arrow_forward,color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}