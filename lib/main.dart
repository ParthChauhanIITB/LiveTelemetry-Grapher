import 'dart:async';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(LiveGraphApp());
}

class LiveGraphApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Graphs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LiveGraphsPage(),
    );
  }
}

class LiveGraphsPage extends StatefulWidget {
  @override
  _LiveGraphsPageState createState() => _LiveGraphsPageState();
}

class _LiveGraphsPageState extends State<LiveGraphsPage> {
  List<FlSpot> dataPoints1 = [];
  List<FlSpot> dataPoints2 = [];
  List<FlSpot> dataPoints3 = [];
  int index = 0,j=0,l1=0,l2=0,l3=0;
  double i=0,x1=0,x2=0,x3=0;
  List<List<dynamic>> csvData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    csvData = await readCsvData();
    startUpdatingGraph();
  }

  Future<List<List<dynamic>>> readCsvData() async {
    final rawData = await rootBundle.loadString("assets/data.csv");
    j++;
    List<List<dynamic>> listData = CsvToListConverter().convert(rawData);
    return listData.sublist(j); // Skip the header
  }

  void startUpdatingGraph() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (index >= csvData.length) {
        timer.cancel();
        return;
      }

      setState(() {
        if (dataPoints1.length == 30) {
          dataPoints1.removeAt(0);
          dataPoints2.removeAt(0);
          dataPoints3.removeAt(0);
        }

        double x = csvData[index][0].toDouble(); // Time (x-axis)
        double y1 = csvData[index][1].toDouble(); // Data 1
        double y2 = csvData[index][2].toDouble(); // Data 2
        double y3 = csvData[index][3].toDouble(); // Data 3
        dataPoints1.add(FlSpot(x, y1));
        dataPoints2.add(FlSpot(x, y2));
        dataPoints3.add(FlSpot(x, y3));
        if(x<30){
          i=0;
        }
        else{
          i=x;
        }
        if(l1<y1 || x1-x>30){
        l1=y1.toInt();
        x1=x;}
        if(l2<y2 || x2-x>30){
        l2=y2.toInt();
        x2=x;}
        if(l3<y3|| x3-x>30){
        l3=y3.toInt();
        x3=x;}
        index++;
      });
    });
  }

  Widget buildGraph(List<FlSpot> dataPoints, String title, Color color,int h) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: i-30,
                maxX: i,
                minY: 0,
                maxY: h+h/20, // Adjust according to your data
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints,
                    isCurved: true,
                    color: Color.fromARGB(255, 132, 79, 19),
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Graphs"),
      ),
      body: Column(
        children: [
          Expanded(
            child: buildGraph(dataPoints1, "Graph 1 (Data 1)", Colors.blue, l1),
          ),
          Expanded(
            child: buildGraph(dataPoints2, "Graph 2 (Data 2)", Colors.red, l2),
          ),
          Expanded(
            child: buildGraph(dataPoints3, "Graph 3 (Data 3)", Colors.green, l3),
          ),
        ],
      ),
    );
  }
}