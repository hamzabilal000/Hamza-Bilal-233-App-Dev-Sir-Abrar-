class Stock {
  final String symbol;
  final String name;
  double price;
  double changePercent;
  final List<double> history;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.history,
  });

  // Convert a Stock into a Map (for saving to SQLite)
  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'changePercent': changePercent,
      // Note: We don't save history to keep the DB simple for this project
    };
  }

  // Convert a Map into a Stock (for loading from SQLite)
  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      symbol: map['symbol'],
      name: map['name'],
      price: map['price'],
      changePercent: map['changePercent'],
      // Give it a fake history so the chart doesn't crash when loading from DB
      history: [map['price'], map['price'] + 1, map['price'] - 1, map['price']],
    );
  }
}

class NewsArticle {
  final String title;
  final String source;
  final String time;
  final String imageUrl;

  NewsArticle({
    required this.title,
    required this.source,
    required this.time,
    required this.imageUrl,
  });
}