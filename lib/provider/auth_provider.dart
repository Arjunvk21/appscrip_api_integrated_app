import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  String? _userId;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get userId => _userId;

  setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    setLoading(true);
    try {
      Response response = await http.post(
          Uri.parse('https://reqres.in/api/register'),
          body: {'email': email, 'password': password});
      if (response.statusCode == 200) {
        setLoading(false);
        final responseData = json.decode(response.body);
        _token = responseData['token'].toString();
        _userId = responseData['id'].toString();
      } else {
        setLoading(false);
      }
    } catch (e) {
      setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    setLoading(true);
    try {
      Response response = await http.post(
          Uri.parse('https://reqres.in/api/login'),
          body: {'email': email, 'password': password});
      if (response.statusCode == 200) {
        setLoading(false);
        final responseData = json.decode(response.body);
        _token = responseData['token'];
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('token', _token!);
        await pref.setString('userId', _userId!);
      } else {
        setLoading(false);
      }
    } catch (e) {
      setLoading(false);
    }
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    return _token != null;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = null;
    _userId = null;
    notifyListeners();
  }
}
