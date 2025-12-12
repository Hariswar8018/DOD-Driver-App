import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../login/bloc/login/view.dart';
import '../model/reviews.dart';

class Reviews extends StatefulWidget {
  const Reviews({super.key});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  List<ReviewModel> reviews = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getReviews();
  }

  Future<void> getReviews() async {
    final Dio dio = Dio(
      BaseOptions(validateStatus: (status) => status != null && status < 500),
    );

    try {
      final response = await dio.get(
        Api.apiurl + "reviews",
        options: Options(
          headers: {"Authorization": "Bearer ${UserModel.token}"},
        ),
      );

      if (response.statusCode == 200) {
        // PARSE JSON CORRECTLY
        final parsed = ReviewResponse.fromJson(response.data);

        // Extract list
        reviews = parsed.pagination.data;

        print("Loaded reviews: ${reviews.length}");
      } else {
        print("❌ Error: ${response.statusMessage}");
      }
    } catch (e) {
      print("❌ API Error: $e");
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff25252D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("My Reviews", style: TextStyle(color: Colors.white)),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : reviews.isEmpty
          ? const Center(
        child: Text(
          "No reviews available",
          style: TextStyle(fontSize: 18),
        ),
      ) : ListView.builder(
        padding: const EdgeInsets.all(3),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final r = reviews[index];
          return Card(
            elevation: 3,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade300,
                    child: Text(
                     "${getEmojiFromRating(r.reviews)}",
                      style: const TextStyle(color: Colors.white,fontSize: 18),
                    ),
                  ),
                  subtitle: Text(
                    r.message,
                    style: const TextStyle(
                        fontSize: 13),
                  ),
                  title: StarRating(rating: r.reviews),
                  trailing: Text(
                    r.reviews.toStringAsFixed(0)+" Star ⭐",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text("Reviewed on : "+"${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}",style: TextStyle(fontSize: 13),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text("Customer ID : ${r.userId}",style: TextStyle(fontSize: 13),),
                ),
                SizedBox(height: 9,)
              ],
            ),
          );
        },
      ),
    );
  }
  String getEmojiFromRating(double rating) {
    int r = rating.round(); // round off

    if (r >= 5) return "😁";  // Very happy
    if (r == 4) return "🙂";  // Happy
    if (r == 3) return "😐";  // Neutral
    if (r == 2) return "😕";  // Not good
    if (r == 1) return "😢";  // Sad

    return "😶"; // No rating / 0
  }

}

class StarRating extends StatelessWidget {
  final double rating;        // ex: 4.3, 3.8, 5.0
  final double size;
  final Color color;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 22,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int rounded = rating.round(); // round off rating

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        rounded,
            (index) => Icon(
          Icons.star,
          size: size,
          color: color,
        ),
      ),
    );
  }
}
