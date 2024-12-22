import 'dart:convert';
import 'package:http/http.dart' as http;
import 'contact.dart';
class ApiService {
  final String baseUrl = 'http://10.0.2.2:3000';

  Future<List<Contact>> fetchContacts() async {
    final response = await http.get(Uri.parse('$baseUrl/contact'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Contact.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  Future<void> deleteContact(int? id) async {
    final response = await http.get(Uri.parse('$baseUrl/contact/delete/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete contact');
    }
  }

  Future<Contact> fetchContactById(int? id) async {
    final response = await http.get(Uri.parse('$baseUrl/contact/getcontact/$id'));
    if (response.statusCode == 200) {
      // Parse the response and return the contact object
      return Contact.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load contact');
    }
  }

  // Update a contact
  Future<void> updateContact(Contact contact) async {
    final response = await http.put(
      Uri.parse('$baseUrl/contact/update/${contact.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(contact.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update contact');
    }
  }

  Future<void> saveContact(Contact contact) async {
    final response = await http.put(
      Uri.parse('$baseUrl/contact/save'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(contact.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update contact');
    }
  }
}

