import 'dart:async';

import 'package:explorelab/core/LocaleManager.dart';
import 'package:explorelab/screens/firestore_service.dart';
import 'package:explorelab/screens/trainings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class ItemModel {
  final String id;
  final String dersAd;
  int dersSayi;

  ItemModel(this.id, this.dersAd, this.dersSayi);
}

class _HomePageState extends State<HomePage> {
  final Color accentColor = Colors.green;
  final FirestoreService _firestoreService = FirestoreService();
  List<ItemModel> items = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    _initializeItems();
  }

  void _initializeItems() {
    items = [
      ItemModel("chemistry_experiments", "chemistry_experiments", 0),
      ItemModel("astronomy_adventure", "astronomy_adventure", 0),
      ItemModel("physics_experiments", "physics_experiments", 0),
      ItemModel("nature_exploration", "nature_exploration", 0),
      ItemModel("under_the_microscope", "under_the_microscope", 0),
      ItemModel("development", "development", 0),
    ];
    _loadTopicCounts();
  }

  // Stream'leri dinlemek ve her bir item için topic sayısını almak
  void _loadTopicCounts() {
    for (final item in items) {
      Stream<int> stream = _firestoreService.getTopicCountStream(item.id);
      stream.listen((count) {
        setState(() {
          item.dersSayi = count; // Topic sayısını güncelleriz
        });
      });
    }
  }

  Widget _buildTitle() {
    final localManager = Provider.of<LocalManager>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                final isTurkish =
                    localManager.currentLocale.languageCode == 'tr';
                final newLocale =
                    isTurkish ? const Locale('en') : const Locale('tr');
                localManager.changeLocale(newLocale);
              },
              icon: Icon(Icons.language),
              label: Text(
                localManager.currentLocale.languageCode.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Text(
          localManager.translate('title'),
          style: TextStyle(
              fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // StreamBuilder ile dinamik verileri alıyoruz
  Widget _buildItemCardChild(ItemModel item) {
    final localManager = Provider.of<LocalManager>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                localManager.translate(item.dersAd),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              onPressed: () => _navigateToTrainings(item.id),
              icon: Icon(Icons.menu_book_rounded),
              color: accentColor,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () => _navigateToTrainings(item.id),
              icon: Icon(Icons.menu, color: Colors.grey),
            ),
            StreamBuilder<int>(
              stream: _firestoreService.getTopicCountStream(
                  item.id), // Stream üzerinden veri alıyoruz
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Hata: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return Text('Veri yok');
                } else {
                  item.dersSayi = snapshot.data!;
                  return Text(
                    item.dersSayi.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToTrainings(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Trainings(id: id)),
    );
  }

  Widget _buildItemCard(ItemModel item) {
    return GestureDetector(
      onTap: () => _navigateToTrainings(item.id),
      child: Container(
        width: 100,
        height: 120,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 32, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 39, 96, 41),
              blurRadius: 10,
            )
          ],
        ),
        child: _buildItemCardChild(item),
      ),
    );
  }

  Widget _buildCardsList() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(items[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[300],
        title: _buildTitle(),
        actions: <Widget>[],
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(top: 16),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: size.width,
                  height: size.height / 2,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                ),
              ),
              _buildCardsList(),
            ],
          ),
        ),
      ),
    );
  }
}
