import 'package:flutter/material.dart';

class LocaleStrings {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
  ];

  // Define your localized strings
  static Map<String, Map<String, String>> _localizedStrings = {
    "en": {
      "score": "Score: ",
      "bestScore": "Best Score: ",
      "gameOver": "Game Over!",
      "musicOn": "Music On",
      "musicOff": "Music Off",
      "pause": "Pause",
      "play": "Play",
      "exitmessage": "Do you really want to exit the game",
      "start": "Start",
      "exit": "Exit",
      "yes": "Yes",
      "no": "No",
      "resume": "Resume",
      "restart": "Restart",
      "settings": "Settings",
      "tryAgain": "Try Again"
    },
    "fr": {
      "score": "Score : ",
      "bestScore": "Meilleur score : ",
      "gameOver": "Jeu terminé !",
      "musicOn": "Musique activée",
      "musicOff": "Musique désactivée",
      "pause": "Pause",
      "play": "Jouer",
      "exitmessage": "Voulez-vous vraiment quitter le jeu",
      "start": "Démarrer",
      "exit": "Quitter",
      "yes": "Oui",
      "no": "Non",
      "resume": "Reprendre",
      "restart": "Redémarrer",
      "settings": "Paramètres",
      "tryAgain": "Réessayer"
    }
  };

  // Method to get the localized string for a given key
  static String getString(String key, Locale locale) {
    return _localizedStrings[locale.languageCode]?[key] ?? key;
  }
}
