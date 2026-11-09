enum SupportMockScenario {
  success,
  empty,
  offline,
  lostResponse;

  static SupportMockScenario parse(String value) => switch (value) {
    'empty' => empty,
    'offline' => offline,
    'lost_response' => lostResponse,
    _ => success,
  };
}
