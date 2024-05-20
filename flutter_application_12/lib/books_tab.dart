import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BooksTab extends StatefulWidget {
  @override
  _BooksTabState createState() => _BooksTabState();
}

class _BooksTabState extends State<BooksTab> {
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  String? selectedCategory;
  TextEditingController contentController = TextEditingController();
  bool _sortByDateAscending = true;

  List<String> categories = [
    'Featured',
    'Upcoming',
    'Thriller & Adventure',
    'Romance',
    'Fairy Tale',
    'Mythology',
    'Action',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Book',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: authorController,
              decoration: InputDecoration(labelText: 'Author'),
            ),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(labelText: 'Content'),
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () {
                if (_areFieldsNotEmpty()) {
                  _createBook();
                } else {
                  _showErrorDialog('Please fill in all the fields.');
                }
              },
              child: Text('Save Book'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _sortByDateAscending = true;
                    });
                  },
                  child: Text('Sort Ascending'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _sortByDateAscending = false;
                    });
                  },
                  child: Text('Sort Descending'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              'Books in Library',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .orderBy('timestamp', descending: !_sortByDateAscending)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  var books = snapshot.data?.docs ?? [];
                  return Column(
                    children: books.map((doc) {
                      var book = doc.data() as Map<String, dynamic>;
                      var timestamp = book['timestamp'] as Timestamp?;

                      var formattedDate = timestamp != null
                          ? "${timestamp.toDate().year}-${timestamp.toDate().month}-${timestamp.toDate().day}"
                          : 'No Date';

                      var formattedTime = timestamp != null
                          ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}"
                          : 'No Time';

                      return Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Title: ${book['Title'] ?? 'No Title'}'),
                                  Text(
                                      'Author: ${book['Author'] ?? 'No Author'}'),
                                  Text(
                                      'Category: ${book['Category'] ?? 'No Category'}'),
                                  Text('Date: $formattedDate'),
                                  Text('Time: $formattedTime'),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _showEditDialog(doc.id, book);
                                  },
                                  child: Text('Edit'),
                                ),
                                SizedBox(width: 8.0),
                                ElevatedButton(
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(doc.id);
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _areFieldsNotEmpty() {
    return titleController.text.isNotEmpty &&
        authorController.text.isNotEmpty &&
        selectedCategory?.isNotEmpty == true &&
        contentController.text.isNotEmpty;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String bookId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this book?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBook(bookId);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(String bookId, Map<String, dynamic> book) {
    TextEditingController editTitleController =
        TextEditingController(text: book['Title']);
    TextEditingController editAuthorController =
        TextEditingController(text: book['Author']);
    String? editCategory = book['Category'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Book'),
          content: SizedBox(
            height: 200,
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: editTitleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: editAuthorController,
                  decoration: InputDecoration(labelText: 'Author'),
                ),
                DropdownButtonFormField<String>(
                  value: editCategory,
                  onChanged: (value) {
                    setState(() {
                      editCategory = value;
                    });
                  },
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateBook(bookId, editTitleController.text,
                    editAuthorController.text, editCategory);
                Navigator.of(context).pop();
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _createBook() {
    FirebaseFirestore.instance.collection('books').add({
      'Title': titleController.text,
      'Author': authorController.text,
      'Category': selectedCategory,
      'Content': contentController.text,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      titleController.clear();
      authorController.clear();
      selectedCategory = null;
      contentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book created successfully!'),
        ),
      );
    }).catchError((error) {
      print('Error creating book: $error');
    });
  }

  void _deleteBook(String bookId) {
    FirebaseFirestore.instance
        .collection('books')
        .doc(bookId)
        .delete()
        .then((_) {
      print('Book deleted successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book deleted successfully!'),
        ),
      );
    }).catchError((error) {
      print('Error deleting book: $error');
    });
  }

  void _updateBook(
      String bookId, String newTitle, String newAuthor, String? newCategory) {
    FirebaseFirestore.instance.collection('books').doc(bookId).update({
      'Title': newTitle,
      'Author': newAuthor,
      'Category': newCategory,
    }).then((_) {
      print('Book updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book updated successfully!'),
        ),
      );
    }).catchError((error) {
      print('Error updating book: $error');
    });
  }
}
