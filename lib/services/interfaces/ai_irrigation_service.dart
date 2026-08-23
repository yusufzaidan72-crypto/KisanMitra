import '../../models/irrigation_advice.dart';

abstract class AIAssistantService {
  Future<String> askQuestion(String question, {String language = 'hi'});
  Future<String> getContextualAdvice(String context);
}

abstract class IrrigationService {
  Future<IrrigationAdvice> getIrrigationAdvice(IrrigationInput input);
}
