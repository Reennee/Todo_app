import 'package:get_it_done/providers/provider.dart';
import 'package:mockito/mockito.dart';

class MockAuthStateProvider extends Mock implements AuthStateProvider {
   @override
  bool get signedState => false;
}

void main() {

  //there is nothing to test. the page is blank by default. :)
 
}


