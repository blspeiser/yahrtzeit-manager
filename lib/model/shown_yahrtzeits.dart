import 'package:flutter/material.dart';
import 'package:yahrtzeit_manager/model/yahrtzeit.dart';

class ShownYahrtzeits extends ChangeNotifier {
  final List<Yahrtzeit> _shown = [
    Yahrtzeit(
      hebrewName: "רַבִּי נַחוּם טְרִיבִיטְשׁ",
      foreignName: "Rabi Nahum Tirziths",
      hebrewDate: "כו בתמוז",
      gregorianDate: "1.8.2024",
      tombPlace: "prague",
      imagePath: "lib/images/1.jpg",
    ),
    Yahrtzeit(
      hebrewName: "רַבִּי נַחוּם טְרִיבִיטְשׁ",
      foreignName: "Rabi Nahum Tirziths",
      hebrewDate: "כו בתמוז",
      gregorianDate: "1.8.2024",
      tombPlace: "prague",
      imagePath: "lib/images/1.jpg",
    ),
    Yahrtzeit(
      hebrewName: "רַבִּי נַחוּם טְרִיבִיטְשׁ",
      foreignName: "Rabi Nahum Tirziths",
      hebrewDate: "כו בתמוז",
      gregorianDate: "1.8.2024",
      tombPlace: "prague",
      imagePath: "lib/images/1.jpg",
    ),
    
  ];

  List<Yahrtzeit> get showmYahrtzeits => _shown;

  List<Yahrtzeit> _userFavorites = [];
  
  List<Yahrtzeit> get userFavorites => _userFavorites;

  void removeFromFavorites(Yahrtzeit yahrtzeit) {
    _userFavorites.remove(yahrtzeit);
    notifyListeners();
  }

  void addToFavorites(Yahrtzeit yahrtzeit) {
    _userFavorites.add(yahrtzeit);
    notifyListeners();
  }


  void clearCart() {
    _userFavorites.clear();
    notifyListeners();
  }
}
