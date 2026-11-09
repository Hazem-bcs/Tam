enum ChatMockScenario {
  success,
  empty,
  disconnect,
  sendFailure,
  lostResponse;

  static ChatMockScenario parse(String value) => switch (value) {
    'empty' => empty,
    'disconnect' => disconnect,
    'send_failure' => sendFailure,
    'lost_response' => lostResponse,
    _ => success,
  };
}
