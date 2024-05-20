import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Screen2 extends StatelessWidget {
  const Screen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ebook Library',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            EbookList(),
          ],
        ),
      ),
    );
  }
}

class EbookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('books').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No books available.'),
          );
        } else {
          List<Map<String, dynamic>> booksData = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: booksData.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(
                    'Author: ${booksData[index]['Author'] ?? 'Unknown Author'}',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Title: ${booksData[index]['Title'] ?? 'Unknown Title'}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  onTap: () {
                    _navigateToBookContent(context, booksData[index]);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  void _navigateToBookContent(
      BuildContext context, Map<String, dynamic> bookData) {
    final String category = bookData['Category'] ?? '';

    if (category != 'Upcoming') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookContentScreen(bookData: bookData),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Coming Soon!'),
            content: Text('Book is coming to your shelf soon!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

class BookContentScreen extends StatelessWidget {
  final Map<String, dynamic> bookData;

  const BookContentScreen({required this.bookData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookData['Title'] ?? 'Unknown Title'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Author: ${bookData['Author'] ?? 'Unknown Author'}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Content: \n ${bookData['Content'] ?? 'No content available.'}',
                  style: TextStyle(fontSize: 20.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
