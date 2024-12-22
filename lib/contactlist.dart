import 'package:contactappsqeeb/editprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'api.dart';
import 'contact.dart';
import 'profile.dart';
import 'savenew.dart';

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  Future<List<Contact>>? contacts; // Use nullable type

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  final TextEditingController _searchController = TextEditingController();
  bool showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts(); // Initialize the contacts
  }

  // Fetch contacts and update the UI
  void _fetchContacts() {
    setState(() {
      contacts = ApiService().fetchContacts().then((fetchedContacts) {
        _contacts = fetchedContacts;
        _filteredContacts = fetchedContacts;
        return fetchedContacts;
      });
    });
  }

  // Filter contacts based on search query and favorite status
  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        bool matchesQuery = query.isEmpty ||
            contact.name!.toLowerCase().contains(query.toLowerCase()) ||
            contact.email!.toLowerCase().contains(query.toLowerCase());
        bool matchesFavorite = !showFavoritesOnly || contact.isFavorite == 1;
        return matchesQuery && matchesFavorite;
      }).toList();
    });
  }

  // Toggle the "Favorite" filter
  void _toggleFavoriteFilter(bool isSelected) {
    setState(() {
      showFavoritesOnly = isSelected;
      _filterContacts(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Contact'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterContacts,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search contact',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // Filter Tabs (All / Favorite)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FilterButton(
                  label: 'All',
                  isSelected: !showFavoritesOnly,
                  onPressed: () => _toggleFavoriteFilter(false),
                ),
                SizedBox(width: 10),
                FilterButton(
                  label: 'Favourite',
                  isSelected: showFavoritesOnly,
                  onPressed: () => _toggleFavoriteFilter(true),
                ),
              ],
            ),
          ),
          // Contact List with Slidable
          Expanded(
            child: FutureBuilder<List<Contact>>(
              future: contacts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No contacts found'));
                } else {
                  final contactList = _filteredContacts;
                  return ListView.builder(
                    itemCount: contactList.length,
                    itemBuilder: (context, index) {
                      final contact = contactList[index];
                      var fav = contact.isFavorite == 1;
                      return SlidableContactTile(
                        name: contact.name!,
                        email: contact.email!,
                        imageUrl: '',
                        isFavorite: fav,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(data: contact.id),
                            ),
                          );
                        },
                        onDelete: () async {
                          try {
                            await ApiService().deleteContact(contact.id);
                            _fetchContacts(); // Reload contacts after deletion
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to delete contact')));
                          }
                        },
                        onMessage: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileDetailScreen(data: contact.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaveProfileScreen(),
            ),
          );
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
    );
  }
}


// Filter Button Widget
class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.purple : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// Slidable Contact Tile Widget
class SlidableContactTile extends StatelessWidget {
  final String name;
  final String email;
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMessage;

  const SlidableContactTile({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.isFavorite,
    this.onEdit,
    this.onDelete,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(name),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onMessage?.call(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.send,
            label: 'Message',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEdit?.call(),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => onDelete?.call(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(name),
        subtitle: Text(email),
        trailing: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? Colors.orange : Colors.grey,
        ),
        onTap: () {
          // Handle tap
        },
      ),
    );
  }
}