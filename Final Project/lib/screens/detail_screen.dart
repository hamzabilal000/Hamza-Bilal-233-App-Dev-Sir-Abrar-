import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock_model.dart';
import '../providers/stock_provider.dart';
import '../theme.dart';

class DetailScreen extends StatelessWidget {
  final Stock stock;
  const DetailScreen({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    bool isPositive = stock.changePercent >= 0;

    return Scaffold(
      appBar: AppBar(title: Text(stock.symbol)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Price Display
            Center(
              child: Column(
                children: [
                  Text("\$${stock.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  Text(
                    "${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%",
                    style: TextStyle(
                      color: isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // CHART
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: stock.history.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true, color: (isPositive ? AppTheme.accentGreen : AppTheme.accentRed).withOpacity(0.2)),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // BUY BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  // Add to portfolio
                  Provider.of<StockProvider>(context, listen: false).addToPortfolio(stock);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bought ${stock.symbol}!")));
                },
                child: const Text("Add to Portfolio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}