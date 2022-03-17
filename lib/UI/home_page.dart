import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_buscador_gif/UI/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

final String BASE_URL = "https://api.giphy.com/v1/gifs";
final String API_KEY = "XvF8S5255gqi7j1ll3vkOelli3LAgmnj";

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;

  int _offset = 0;

  Future<Map> _getGIFs() async {
    http.Response response;

    if (_search == Null || _search.isEmpty) {
      response = await http
          .get("$BASE_URL/trending?api_key=$API_KEY&limit=20&rating=G");
    } else {
      response = await http.get(
          "$BASE_URL/search?api_key=$API_KEY&q=$_search&limit=19&offset=$_offset&rating=G&lang=en");
    }

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGIFs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      height: 200,
                      width: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                    break;
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return _createGIFTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(int pagination) {
    if (_search == null || _search.isEmpty) {
      return pagination;
    } else {
      return pagination + 1;
    }
  }

  Widget _createGIFTable(BuildContext context, AsyncSnapshot snapshot) {
    var data = snapshot.data["data"];
    var pagination = snapshot.data["pagination"];

    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _getCount(pagination["count"]),
        itemBuilder: (context, index) {
          if (_search == null || index < pagination["count"]) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                height: 300,
                fit: BoxFit.cover,
                placeholder: kTransparentImage,
                image: data[index]["images"]["fixed_height"]["url"],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GifPage(data[index])));
              },
              onLongPress: () {
                Share.share(data[index]["images"]["fixed_height"]["url"]);
              },
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
          }
        });
  }
}
