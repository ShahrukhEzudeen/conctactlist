import 'package:flutter/material.dart';
import 'api.dart';
import 'contact.dart';  // Make sure you import ApiService

class EditProfileScreen extends StatefulWidget {
  final int? data;

  EditProfileScreen({this.data});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch contact details based on the ID (widget.data)
    _fetchContactDetails();
  }

  // Fetch contact data by ID
  void _fetchContactDetails() async {
    try {
      ApiService apiService = ApiService();
      // Fetch contact by ID using your API service
      print(widget.data);
      Contact contact = await apiService.fetchContactById(widget.data);
      // Populate the text fields with the contact data
      setState(() {
        firstNameController.text = contact.name!;
        emailController.text = contact.email!;
      });
    } catch (e) {
      print('Failed to fetch contact: $e');
      // Show error message to the user
    }
  }

  // Save updated contact
  void _saveProfile() async {
    try {
      ApiService apiService = ApiService();
      // Create a contact object with the updated data
      Contact updatedContact = Contact(
        id: widget.data,
        name: firstNameController.text,
        email: emailController.text,
        isFavorite: 1,
      );
      // Save updated contact to the server
      await apiService.updateContact(updatedContact);
      // Show success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      print('Failed to update contact: $e');
      // Show error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
