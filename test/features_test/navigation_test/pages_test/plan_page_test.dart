import 'package:flutter_test/flutter_test.dart';
import 'package:get_it_done/providers/provider.dart';
import 'package:mockito/mockito.dart';


class MockAuthStateProvider extends Mock implements AuthStateProvider {
   @override
  bool get signedState => false;
}

void main() {

//fireabse issues  

}

class AuthStateProviderMock extends AuthStateProvider {
  bool deleteTaskCalled = false;
  
  @override
  Future<void> deleteTask(String taskId) async {
    deleteTaskCalled = true;
  }
}
