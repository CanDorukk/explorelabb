import 'package:explorelab/core/LocaleManager.dart';
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
  final int dersSayi;

  ItemModel(this.id, this.dersAd, this.dersSayi);
}

class _HomePageState extends State<HomePage> {
  final Color accentColor = Colors.green;

  List<ItemModel> items = [
    ItemModel("1", "chemistry_experiments", 5),
    ItemModel("2", "astronomy_adventure", 3),
    ItemModel("3", "physics_experiments", 4),
    ItemModel("4", "nature_exploration", 2),
    ItemModel("5", "under_the_microscope", 6),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  Widget _buildTitle() {
    return Text(
      "Özel Eğitim",
      style: TextStyle(
          fontSize: 40, color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildItemCardChild(ItemModel item) {
    final localManager = Provider.of<LocalManager>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              localManager.translate(item.dersAd),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Trainings(
                          id: item
                              .id)), // Doğru şekilde id parametresini gönder
                );
              },
              icon: Icon(
                Icons.menu_book_rounded,
              ),
              color: accentColor,
            )
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Trainings(
                          id: item
                              .id)), // Doğru şekilde id parametresini gönder
                );
              },
              icon: Icon(
                Icons.menu,
                color: Colors.grey,
              ),
            ),
            Text(
              item.dersSayi
                  .toString(), // TODO : burada içerikte bulunan ders sayısının belirtilmesi gerekiyor.
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemCard(ItemModel item) {
    return GestureDetector(
      onTap: () {
        if (item.id == "1") {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Trainings(id: item.dersAd)),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Trainings(id: item.dersAd)),
          );
        }
      },
      child: Container(
        width: 100,
        height: 120,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(left: 32, right: 32, top: 4, bottom: 4),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(28)),
            boxShadow: [
              BoxShadow(color: Color.fromARGB(255, 39, 96, 41), blurRadius: 10)
            ]),
        child: _buildItemCardChild(item),
      ),
    );
  }

  Widget _buildCardsList() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        var item = items.elementAt(index);
        return _buildItemCard(item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[300],
        title: _buildTitle(),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // Burada 'item' değişkeni yok, dolayısıyla bir id değeri göndermelisin
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        Trainings(id: "0")), // id: "0" olarak düzeltildi
              );
            },
            icon: Icon(
              Icons.article,
              color: Colors.blueGrey,
            ),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 16),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: width,
                  height: height / 2,
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(28),
                          topLeft: Radius.circular(28)))),
            ),
            _buildCardsList(),
          ],
        ),
      ),
    );
  }
}
