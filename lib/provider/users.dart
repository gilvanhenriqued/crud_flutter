import 'dart:convert';
import 'dart:math';

import 'package:crud_flutter/data/dummy_users.dart';
import 'package:crud_flutter/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Users with ChangeNotifier {
  // dados e métodos para prover à inteface
  static const _baseUrl = 'https://crud-flutter-35746.firebaseio.com/';
  final Map<String, User> _items = {...DUMMY_USERS};
  
  List<User> get all {
    return [..._items.values];
  }

  int get count {
    return _items.length;
  }

  User byIndex(int i) {
    return _items.values.elementAt(i);
  }

  Future<void> put(User user) async {
    if(user == null) {
      return;
    }

    // caso seja alteração
    if(user.id != null &&
      user.id.trim().isNotEmpty &&
      _items.containsKey(user.id)) {

      await http.patch(
        "$_baseUrl/users/${user.id}.json", 
        body: json.encode({
          'name': user.name,
          'email': user.email,
          'avatarUrl': user.avatarUrl,
        })
      );
      
      _items.update(user.id, (_) => user);
    
    } else {
      // adicionar
      final res = await http.post(
        "$_baseUrl/users.json", 
        body: json.encode({
          'name': user.name,
          'email': user.email,
          'avatarUrl': user.avatarUrl,
        })
      );

      final id = json.decode(res.body)['name'];

      _items.putIfAbsent(id, () => User(
        id: id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
      ));
    }

      notifyListeners();
  }

  void remove(User user) {
    if(user != null && user.id != null) {
      _items.remove(user.id);
      notifyListeners();
    }
  }
}