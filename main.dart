import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(PokemonCardBattleApp());
}

class PokemonCardBattleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Battle',
      theme: ThemeData(primarySwatch: Colors.green),
      home: BattleScreen(),
    );
  }
}

class BattleScreen extends StatefulWidget {
  @override
  _BattleScreenState createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  String firstCardImage = '';
  String secondCardImage = '';
  String battleResult = '';
  int firstCardHp = 0;
  int secondCardHp = 0;

  Future<Map<String, dynamic>> getRandomCard() async {
    final response = await http.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List cards = jsonResponse['data'];
      final randomCard = cards[Random().nextInt(cards.length)];
      return randomCard;
    } else {
      throw Exception('Error fetching card data');
    }
  }

  Future<void> loadNewCards() async {
    try {
      final card1 = await getRandomCard();
      final card2 = await getRandomCard();

      setState(() {
        firstCardImage = card1['images']['large'];
        secondCardImage = card2['images']['large'];

        firstCardHp = card1['hp'] != null ? int.parse(card1['hp']) : 0;
        secondCardHp = card2['hp'] != null ? int.parse(card2['hp']) : 0;

        if (firstCardHp > secondCardHp) {
          battleResult = 'Card 1 wins with ${firstCardHp} HP!';
        } else if (secondCardHp > firstCardHp) {
          battleResult = 'Card 2 wins with ${secondCardHp} HP!';
        } else {
          battleResult = 'It\'s a tie with ${firstCardHp} HP!';
        }
      });
    } catch (e) {
      setState(() {
        battleResult = 'Failed to load cards. Please try again.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadNewCards(); // Fetch cards initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon Battle'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the first card
              firstCardImage.isNotEmpty
                  ? _buildCardDisplay(firstCardImage, firstCardHp)
                  : CircularProgressIndicator(),

              SizedBox(height: 20),

              // Display the second card
              secondCardImage.isNotEmpty
                  ? _buildCardDisplay(secondCardImage, secondCardHp)
                  : CircularProgressIndicator(),

              SizedBox(height: 20),

              // Display battle result
              Text(
                battleResult,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 40),

              // Button to load new cards
              ElevatedButton(
                onPressed: loadNewCards,
                child: Text('Load New Battle'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build the card display with HP info
  Widget _buildCardDisplay(String imageUrl, int hp) {
    return Column(
      children: [
        Container(
          width: 200,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
        SizedBox(height: 10),
        Text('HP: $hp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
