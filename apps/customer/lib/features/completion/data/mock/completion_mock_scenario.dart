enum CompletionMockScenario {
  success,
  offline,
  lostResponse;

  static CompletionMockScenario parse(String value) => switch (value) {
    'success' => success,
    'offline' => offline,
    'lost_response' => lostResponse,
    _ => throw ArgumentError.value(value, 'COMPLETION_MOCK_SCENARIO'),
  };
}
