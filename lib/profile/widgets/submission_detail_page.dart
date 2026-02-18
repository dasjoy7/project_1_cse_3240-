import 'package:flutter/material.dart';
import '../profile_service.dart';
import 'package:project_1_cse_3240/problems/model/submission_detail.dart';

class SubmissionDetailPage extends StatelessWidget {
  final DateTime date;
  const SubmissionDetailPage({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final service=ProfileService();
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text(
          "${date.year}-${date.month}-${date.day}Submissions",style: TextStyle(color: Colors.blue),),
        elevation: 0,
      ),

      body: FutureBuilder<List<SubmissionDetail>>(
        future: service.fetchSubmissionDetails(date),
        builder: (context,snapshot) {
          if (!snapshot.hasData)
          {
            return Center(child: CircularProgressIndicator());
          }
          final list=snapshot.data!;
          if (list.isEmpty)
          {
            return Center(child: Text("No submissions"));
          }
          final correct=list.where((e) =>e.isCorrect).length;
          final wrong=list.length-correct;
          return Column(
            children: [

              // ================= SUMMARY HEADER =================
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,blurRadius:8,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem("Total",list.length,Colors.white),
                    _summaryItem("Correct",correct,Colors.green),
                    _summaryItem("Wrong",wrong,Colors.red),
                  ],
                ),
              ),

              // ================= LIST =================
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal:16),
                  itemCount: list.length,
                  itemBuilder: (context,i){
                    final item=list[i];
                    return Container(
                      margin: EdgeInsets.only(bottom:12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,blurRadius:6,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item.isCorrect?Colors.green.withOpacity(0.1):Colors.red.withOpacity(0.1),
                            ),
                            child: Icon(
                              item.isCorrect
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: item.isCorrect
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(fontSize:16,fontWeight:FontWeight.w500),
                            ),
                          ),
                          Text(
                            item.isCorrect
                                ? "Accepted"
                                : "Wrong",
                            style: TextStyle(
                              color: item.isCorrect
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryItem(
      String label,int value,Color color) {
    return Column(
      children: [
        Text(value.toString(),
          style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color: color),
        ),
        SizedBox(height:4),
        Text(label,
          style:TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}