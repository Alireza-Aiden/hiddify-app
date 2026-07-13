import 'dart:async';
import 'package:fpdart/fpdart.dart';

class RemoteProfileEntity {
  final String id;
  final String name;
  final String url;
  final DateTime lastUpdate;
  final dynamic options;

  RemoteProfileEntity({
    required this.id,
    required this.name,
    required this.url,
    required this.lastUpdate,
    this.options,
  });
}

class ProfileRepository {
  Future<Either<String, void>> upsertRemote(String url) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 100));
    return Right(null);
  }
}

void main() async {
  final repo = ProfileRepository();
  final profiles = List.generate(
    20,
    (index) => RemoteProfileEntity(
      id: 'id_$index',
      name: 'Profile $index',
      url: 'url_$index',
      lastUpdate: DateTime.now().subtract(Duration(days: 1)),
    ),
  );

  print('Testing sequential update...');
  final startSeq = DateTime.now();
  await for (final profile in Stream.fromIterable(profiles)) {
    await repo.upsertRemote(profile.url);
  }
  final endSeq = DateTime.now();
  print('Sequential time: ${endSeq.difference(startSeq).inMilliseconds}ms');

  print('Testing concurrent update...');
  final startConcurrent = DateTime.now();
  await Future.wait(profiles.map((profile) async {
    await repo.upsertRemote(profile.url);
  }));
  final endConcurrent = DateTime.now();
  print('Concurrent time: ${endConcurrent.difference(startConcurrent).inMilliseconds}ms');
}
