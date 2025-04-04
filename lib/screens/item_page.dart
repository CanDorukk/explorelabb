import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class KavramOgretim extends StatefulWidget {
  @override
  _KavramOgretimState createState() => _KavramOgretimState();
  final String id; // id eklendi

  KavramOgretim({required this.id}); // required olarak işaretlendi
}

class ItemModel {
  final String dersAd;
  final String link;

  ItemModel({required this.dersAd, required this.link});

  // Firestore'dan veri çekerken bu model kullanılacak
  factory ItemModel.fromMap(Map<String, dynamic> data) {
    return ItemModel(
      dersAd: data['dersAd'] ?? "Bilinmeyen Ders",
      link: data['link'] ?? "",
    );
  }
}

class _KavramOgretimState extends State<KavramOgretim> {
  final Color accentColor = Colors.green;
  List<ItemModel> items = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    _fetchDataFromFirestore();
  }

  // 📌 Firestore'dan Dersleri Çek
  Future<void> _fetchDataFromFirestore() async {
    try {
      FirebaseFirestore.instance
          .collection("kavram_ogretimi") // Firestore koleksiyon adı
          .get()
          .then((querySnapshot) {
        List<ItemModel> tempItems = querySnapshot.docs
            .map((doc) => ItemModel.fromMap(doc.data()))
            .toList();
        setState(() {
          items = tempItems;
        });
      });
    } catch (e) {
      print("Firestore Hatası: $e");
    }
  }

  Widget _buildItemCard(ItemModel item) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(item.link)) {
          launch(item.link);
        } else {
          print("Bağlantı açılamadı: ${item.link}");
        }
      },
      child: Container(
        width: 90,
        height: 80,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.green.shade900, blurRadius: 10),
          ],
        ),
        child: Center(
          child: Text(
            item.dersAd,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCardsList() {
    return items.isEmpty
        ? Center(child: CircularProgressIndicator()) // Veri yüklenirken göster
        : ListView.builder(
            padding: EdgeInsets.only(bottom: 30),
            itemCount: items.length,
            itemBuilder: (context, index) {
              var item = items[index];
              return _buildItemCard(item);
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: Text(
          "Kavram Öğretimi",
          style: TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 8),
        child: _buildCardsList(),
      ),
    );
  }
}
