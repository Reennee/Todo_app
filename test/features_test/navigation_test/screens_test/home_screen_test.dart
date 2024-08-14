import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it_done/providers/provider.dart';
import 'package:mockito/mockito.dart';

// Mock AuthStateProvider class using Mockito
class MockAuthStateProvider extends Mock implements AuthStateProvider {
  @override
  bool get signedState => false;
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
 //firestore issues.
}
