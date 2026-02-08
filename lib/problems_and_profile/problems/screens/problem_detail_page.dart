import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/problems_and_profile/problems/model/problem.dart';
import '../services/supabase_service.dart';

class ProblemDetailPage extends StatefulWidget {
  final Problem problem;
  ProblemDetailPage({
    super.key,
    required this.problem,
    required String title,
  });
  @override
  State<ProblemDetailPage> createState() => _ProblemDetailPageState();
}
class _ProblemDetailPageState extends State<ProblemDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final SupabaseService _service = SupabaseService();
  bool _isSubmitting = false;
  bool _showHint = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final bool correct = await _service.submitAnswer(
      problemId: widget.problem.id,
      userAnswer: _controller.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(correct ? 'Accepted ✅' : 'Wrong ❌'),
        backgroundColor: correct ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasHint =
        widget.problem.hint != null && widget.problem.hint!.isNotEmpty;
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text(
          widget.problem.title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.problem.description ?? 'No description available',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),


              // ======================
              // ANSWER FIELD
              // ======================
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() => _showHint = !_showHint);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Need a hint?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        _showHint ? Icons.expand_less : Icons.expand_more,
                      ),
                    ],
                  ),
                ),
              ),

              if (_showHint && hasHint)
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    widget.problem.hint!,
                    style: TextStyle(fontSize: 15),
                  ),
                ),

              // ======================
              // SUBMIT BUTTON
              // ======================
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Submit Answer',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward,color: Colors.white),
                    ],
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