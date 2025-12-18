import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../database_helper.dart'; // Make sure this import is here!

class StockProvider with ChangeNotifier {
  // Lists to hold our data
  List<Stock> _stocks = [];
  List<Stock> _portfolio = []; // Your owned stocks
  List<Stock> _filteredStocks = []; // For search results

  // Fake News Data (Hardcoded for the UI)
  List<NewsArticle> news = [
    NewsArticle(title: "Market hits all-time high as Tech rallies", source: "Bloomberg", time: "1h ago", imageUrl: "https://picsum.photos/200/200"),
    NewsArticle(title: "Crypto regulation talks heat up in Senate", source: "CoinDesk", time: "2h ago", imageUrl: "https://picsum.photos/201/201"),
    NewsArticle(title: "Tesla announces new AI-driven model", source: "Reuters", time: "4h ago", imageUrl: "https://picsum.photos/202/202"),
    NewsArticle(title: "Oil prices drop significantly today", source: "CNBC", time: "5h ago", imageUrl: "https://picsum.photos/203/203"),
  ];

  // Getters
  List<Stock> get stocks => _filteredStocks.isNotEmpty ? _filteredStocks : _stocks;
  List<Stock> get portfolio => _portfolio;

  // Constructor: Starts everything when the app launches
  StockProvider() {
    _generateHugeStockList(); // Create the fake stocks
    _loadPortfolioFromDB();   // <--- LOAD SAVED DATA FROM DATABASE
    _startSimulation();       // Start the price ticker
  }

  // ---------------------------------------------------------------------------
  // 1. DATABASE FUNCTIONS (SQLite)
  // ---------------------------------------------------------------------------

  // Load stocks you bought previously from the local database
  Future<void> _loadPortfolioFromDB() async {
    _portfolio = await DatabaseHelper.instance.getPortfolio();
    notifyListeners(); // Update the UI
  }

  // Buy a stock and save it to the database
  Future<void> addToPortfolio(Stock stock) async {
    // Check if we already own it to prevent duplicates in the list
    bool alreadyOwned = _portfolio.any((s) => s.symbol == stock.symbol);

    if (!alreadyOwned) {
      _portfolio.add(stock); // Update UI immediately
      await DatabaseHelper.instance.insertStock(stock); // Save to Storage
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // 2. STOCK GENERATION & SEARCH
  // ---------------------------------------------------------------------------

  void _generateHugeStockList() {
    // Add some "Real" famous stocks first
    _stocks.add(Stock(symbol: 'AAPL', name: 'Apple Inc.', price: 175.0, changePercent: 1.2, history: [170, 172, 175]));
    _stocks.add(Stock(symbol: 'TSLA', name: 'Tesla', price: 240.0, changePercent: -0.5, history: [245, 240, 238]));
    _stocks.add(Stock(symbol: 'NVDA', name: 'Nvidia', price: 460.0, changePercent: 3.5, history: [450, 455, 460]));
    _stocks.add(Stock(symbol: 'BTC', name: 'Bitcoin', price: 42000.0, changePercent: 1.5, history: [41000, 41500, 42000]));
    _stocks.add(Stock(symbol: 'ETH', name: 'Ethereum', price: 2200.0, changePercent: 0.8, history: [2150, 2180, 2200]));

    // Auto-generate 50 more fake stocks so the list is long
    List<String> sectors = ['Tech', 'Bio', 'Energy', 'Crypto', 'Auto'];
    final random = Random();

    for (int i = 0; i < 50; i++) {
      String sector = sectors[random.nextInt(sectors.length)];
      double startPrice = random.nextDouble() * 500 + 10;

      _stocks.add(Stock(
        symbol: '${sector.substring(0,3).toUpperCase()}$i', // e.g., TEC1, BIO4
        name: '$sector Global $i',
        price: startPrice,
        changePercent: (random.nextDouble() * 10) - 5, // Random percent between -5% and +5%
        history: [startPrice, startPrice + 2, startPrice - 1], // Fake history
      ));
    }
    _filteredStocks = _stocks; // Show all stocks initially
  }

  // Search logic
  void search(String query) {
    if (query.isEmpty) {
      _filteredStocks = _stocks;
    } else {
      _filteredStocks = _stocks.where((stock) =>
      stock.symbol.toLowerCase().contains(query.toLowerCase()) ||
          stock.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 3. REAL-TIME SIMULATION
  // ---------------------------------------------------------------------------

  void _startSimulation() {
    // Every 2 seconds, slightly change the price of every stock
    Timer.periodic(const Duration(seconds: 2), (timer) {
      final random = Random();
      for (var stock in _stocks) {
        double move = (random.nextDouble() * 2) - 1; // Random move between -1.00 and +1.00
        stock.price += move;
        stock.changePercent += (move / stock.price) * 100;

        // Update history for the chart
        stock.history.add(stock.price);
        if (stock.history.length > 20) stock.history.removeAt(0); // Keep chart manageable
      }
      notifyListeners(); // Refresh the UI
    });
  }
}