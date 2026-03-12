import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../services/ai_service.dart';

class DetailsPage extends StatefulWidget {
  final int movieId;
  final String title;

  const DetailsPage({super.key, required this.movieId, required this.title});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final TmdbService _tmdbService = TmdbService();
  final AiService _aiService = AiService();
  late Future<Map<String, dynamic>> _movieDetails;

  @override
  void initState() {
    super.initState();
    _movieDetails = _tmdbService.getMovieDetails(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Cillad: ${snapshot.error}'));
          }

          final details = snapshot.data!;
          final overview = details['overview'] ?? '';
          final cast = details['credits']['cast'] as List;
          final List genres = details['genres'] ?? [];
          final double rating = (details['vote_average'] as num).toDouble();
          final int runtime = details['runtime'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Genres
                Wrap(
                  spacing: 8,
                  children: genres
                      .map(
                        (g) => Chip(
                          label: Text(
                            g['name'],
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blueGrey.shade900,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),

                // 2. Rating & Runtime
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text("$runtime daqiiqo"),
                  ],
                ),
                const Divider(height: 40),

                // 3. Somali Summary (AI Section)
                const Text(
                  'Nuxurka Filimka',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                FutureBuilder<String>(
                  future: _aiService.translateToSomali(overview),
                  builder: (context, aiSnapshot) {
                    if (aiSnapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        "Waa la turjumayaa...",
                        style: TextStyle(color: Colors.grey),
                      );
                    }
                    return Text(
                      aiSnapshot.data ?? "Turjumaad lama helin.",
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // 4. Cast
                const Text(
                  'Jilaayaasha',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cast.length > 10 ? 10 : cast.length,
                    itemBuilder: (context, index) {
                      final actor = cast[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: actor['profile_path'] != null
                                  ? NetworkImage(
                                      'https://image.tmdb.org/t/p/w200${actor['profile_path']}',
                                    )
                                  : null,
                              child: actor['profile_path'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 80,
                              child: Text(
                                actor['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
