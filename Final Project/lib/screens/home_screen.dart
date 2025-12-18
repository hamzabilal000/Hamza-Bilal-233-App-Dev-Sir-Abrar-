import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../widgets/stock_card.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // To control tabs

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);

    // SCREEN 1: MARKET (The List)
    Widget buildMarketTab() {
      return Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              onChanged: (value) => provider.search(value), // Live Search!
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.search, color: AppTheme.textGrey),
                hintText: "Search 50+ assets...",
                hintStyle: TextStyle(color: AppTheme.textGrey),
              ),
            ),
          ),
          // The List
          Expanded(
            child: ListView.builder(
              itemCount: provider.stocks.length,
              itemBuilder: (context, index) {
                return StockCard(stock: provider.stocks[index]);
              },
            ),
          ),
        ],
      );
    }

    // SCREEN 2: PORTFOLIO (Your Stocks)
    Widget buildPortfolioTab() {
      if (provider.portfolio.isEmpty) {
        return const Center(child: Text("No stocks owned yet.\nGo to Market and Buy some!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)));
      }
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.5)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Balance", style: TextStyle(color: Colors.white70)),
                Text("\$12,450.32", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                Text("+ \$340.20 (Today)", style: TextStyle(color: AppTheme.accentGreen)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.portfolio.length,
              itemBuilder: (context, index) => StockCard(stock: provider.portfolio[index]),
            ),
          ),
        ],
      );
    }

    // SCREEN 3: NEWS
    Widget buildNewsTab() {
      return ListView.builder(
        itemCount: provider.news.length,
        itemBuilder: (context, index) {
          final article = provider.news[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(article.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
              ),
              title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("${article.source} • ${article.time}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedIndex == 0 ? "Market" : _selectedIndex == 1 ? "Portfolio" : "News",
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const CircleAvatar(backgroundColor: AppTheme.surface, child: Icon(Icons.person, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),

              // Switch between tabs
              Expanded(
                child: _selectedIndex == 0 ? buildMarketTab() :
                _selectedIndex == 1 ? buildPortfolioTab() : buildNewsTab(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Market"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Portfolio"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "News"),
        ],
      ),
    );
  }
}