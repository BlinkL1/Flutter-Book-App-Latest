import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Screen1 extends StatelessWidget {
  const Screen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchBooks(),
      builder: (context, AsyncSnapshot<List<List<Book>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No books found.'));
        } else {
          List<List<Book>> bookCategories = snapshot.data!;

          List<String> categoryNames = [
            'Featured',
            'Upcoming',
            'Thriller & Adventure',
            'Romance',
            'Fairy Tale',
            'Mythology',
            'Action',
          ];

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                    for (var i = 0; i < bookCategories.length; i++) ...[
                      _buildBookSection(categoryNames[i], bookCategories[i]),
                      const SizedBox(height: 16.0),
                    ],
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<List<List<Book>>> _fetchBooks() async {
    try {
      QuerySnapshot<Map<String, dynamic>> booksSnapshot =
          await FirebaseFirestore.instance.collection('books').get();

      List<Book> featuredBooks = [];
      List<Book> upcomingBooks = [];
      List<Book> thrillerAdventureBooks = [];
      List<Book> romanceBooks = [];
      List<Book> fairyTaleBooks = [];
      List<Book> mythologyBooks = [];
      List<Book> actionBooks = [];

      booksSnapshot.docs.forEach((bookDoc) {
        Book book = Book(
          title: bookDoc['Title'],
          author: bookDoc['Author'],
          category: bookDoc['Category'],
          body: bookDoc['Content'],
        );

        switch (book.category) {
          case 'Featured':
            featuredBooks.add(book);
            break;
          case 'Upcoming':
            upcomingBooks.add(book);
            break;
          case 'Thriller & Adventure':
            thrillerAdventureBooks.add(book);
            break;
          case 'Romance':
            romanceBooks.add(book);
            break;
          case 'Fairy Tale':
            fairyTaleBooks.add(book);
            break;
          case 'Mythology':
            mythologyBooks.add(book);
            break;
          case 'Action':
            actionBooks.add(book);
            break;
          default:
            break;
        }
      });

      return [
        featuredBooks,
        upcomingBooks,
        thrillerAdventureBooks,
        romanceBooks,
        fairyTaleBooks,
        mythologyBooks,
        actionBooks,
      ];
    } catch (error) {
      print('Error fetching books: $error');
      throw error;
    }
  }

  Widget _buildBookSection(String title, List<Book> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        Container(
          height: 150.0,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  _navigateToBookContent(context, books[index]);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 150.0,
                    child: Card(
                      elevation: 3.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            books[index].title,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'by ${books[index].author}',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToBookContent(BuildContext context, Book book) {
    final String category = book.category ?? '';

    if (category != 'Upcoming') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookContentScreen(
            appBarTitle: book.title,
            bookTitle: book.author,
            bookContent: book.body,
          ),
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

class Book {
  final String title;
  final String author;
  final String? category;
  final String body;

  Book({
    required this.title,
    required this.author,
    required this.category,
    required this.body,
  });
}

class BookContentScreen extends StatelessWidget {
  final String appBarTitle;
  final String bookTitle;
  final String bookContent;

  const BookContentScreen({
    Key? key,
    required this.appBarTitle,
    required this.bookTitle,
    required this.bookContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bookTitle,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              bookContent,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
