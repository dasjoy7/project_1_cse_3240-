import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/profile/widgets/submission_detail_page.dart';
import 'profile_service.dart';
import 'profile_stats.dart';
import 'widgets/progress_ring.dart';
import 'widgets/stat_tile.dart';
import 'widgets/submission_heatmap.dart';
import 'package:project_1_cse_3240/profile/profile_daily_submission.dart';



class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ProfileService();

    return Scaffold(
      backgroundColor:Colors.white,
      body: FutureBuilder<ProfileStats>(
        future:service.fetchProfileStats(),
        builder: (context,snapshot) {
          if(!snapshot.hasData)
          {
            return Center(child: CircularProgressIndicator());
          }
          final s=snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height:30),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                  ),
                  child:CircleAvatar(
                    radius:50,
                    backgroundImage:AssetImage(''),
                  ),
                ),

                SizedBox(height:12),
                Text(s.fullName,
                  style:TextStyle(fontSize:20,fontWeight:FontWeight.bold),
                ),
                Text(
                  "@${s.username}",style:TextStyle(color: Colors.grey),
                ),

                SizedBox(height:30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Daily Submissions",
                    style: TextStyle(fontSize:20,fontWeight:FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),


                SizedBox(height:12),
                FutureBuilder(
                  future: service.fetchDailySubmissions(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                    {
                      return Center(child: CircularProgressIndicator());
                    }
                    final list=snapshot.data!;
                    if(list.isEmpty)
                    {
                      return Text("No submissions yet");
                    }


                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue,blurRadius:1,
                          ),
                        ],
                      ),


                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_,_) =>Divider(height:1),////
                        itemBuilder:(context,i) {
                          final d=list[i];


                          return ListTile(
                            leading:Icon(Icons.calendar_today),
                            iconColor:Colors.blue,
                            title: Text(
                              "${d.date.year}-${d.date.month}-${d.date.day}",
                              style: TextStyle(color: Colors.green),
                            ),

                            trailing: Text(
                              "${d.count}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.red
                              ),
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubmissionDetailPage(
                                    date:d.date,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),


                SizedBox(height:30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Submission Activity",
                    style: TextStyle(fontSize:20,fontWeight:FontWeight.bold,
                        color: Colors.blueGrey
                    ),
                  ),
                ),

                SizedBox(height:12),
                FutureBuilder<List<DailySubmission>>(
                  future:service.fetchDailySubmissions(),
                  builder: (context, AsyncSnapshot<List<DailySubmission>> snapshot)  {
                    if (!snapshot.hasData){
                      return CircularProgressIndicator();
                    }

                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(),
                      ),
                      child: SubmissionHeatmap(data: snapshot.data!),
                    );
                  },
                ),



                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Problem Solving",
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                          color: Colors.blueGrey)
                  ),
                ),

                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink,blurRadius:1,offset:Offset(0,1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ProgressRing(
                        easy: s.easySolved,
                        medium: s.mediumSolved,
                        hard: s.hardSolved,
                      ),
                    ],
                  ),
                ),

                SizedBox(height:22),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  //physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 2.2,
                  children: [
                    StatTile(
                      label: "Total Submissions",
                      value: s.totalSubmissions,
                      color: Colors.blue,
                      icon: Icons.send_rounded,
                    ),
                    StatTile(
                      label: "Accepted",
                      value: s.accepted,
                      color: Colors.green,
                      icon: Icons.check_circle_rounded,
                    ),
                    StatTile(
                      label: "Wrong Answer",
                      value: s.wrong,
                      color: Colors.red,

                      icon: Icons.cancel_outlined,
                    ),
                    StatTile(
                      label: "Solved",
                      value: s.totalSolved,
                      color: Colors.indigo,
                      icon: Icons.flag_circle_rounded,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }


/*Widget _legend(Color color, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          CircleAvatar(radius: 5,backgroundColor: color),
          SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }*/
}