import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/network/request_coalescer.dart';

void main() {
  test('concurrent calls to the same key execute once', () async {
    final coalescer = RequestCoalescer();
    final completer = Completer<int>();
    var invocations = 0;
    Future<int> request() {
      invocations++;
      return completer.future;
    }

    final first = coalescer.run('booking-1', request);
    final second = coalescer.run('booking-1', request);
    expect(invocations, 1);
    completer.complete(42);
    expect(await first, 42);
    expect(await second, 42);
  });

  test('after completion a new request can execute', () async {
    final coalescer = RequestCoalescer();
    var invocations = 0;
    Future<int> request() async => ++invocations;
    expect(await coalescer.run('key', request), 1);
    await Future<void>.delayed(Duration.zero);
    expect(await coalescer.run('key', request), 2);
  });

  test('unrelated keys do not block one another', () async {
    final coalescer = RequestCoalescer();
    expect(await coalescer.run('first', () async => 1), 1);
    expect(await coalescer.run('second', () async => 2), 2);
  });
}
