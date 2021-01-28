/*
 * The Clear BSD License
 *
 * Copyright (c) 2021 Bitsy Darel
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted (subject to the limitations in the disclaimer
 * below) provided that the following conditions are met:
 *
 *      * Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *
 *      * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *      * Neither the name of the copyright holder nor the names of its
 *      contributors may be used to endorse or promote products derived from
 *      this software without specific prior written permission.
 *
 * NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY
 * THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
 * NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import 'dart:convert';
import 'dart:io';

import 'package:vcshooks/src/hooks_handlers/git_hooks_handler.dart';
import 'package:vcshooks/src/script_config.dart';
import 'package:vcshooks/src/utils/dart_utils.dart';
import 'package:vcshooks/src/operating_system.dart';
import 'package:vcshooks/src/utils/exceptions.dart';
import 'package:io/io.dart';
import 'package:meta/meta.dart';

/// Dart git hooks handler.
class DartHooksHandler extends GitHooksHandler {
  /// Create a [DartHooksHandler] with the provided [os] and [config].
  DartHooksHandler({
    @required OperatingSystem os,
    @required ScriptConfig config,
  }) : super(os: os, config: config);

  @override
  Future<String> executeCodeStyleCheck() async {
    final String staticAnalyzer = operatingSystem.getCodeStyleCheckFileName();

    final Directory hooksDir = config.hooksDir;

    final ProcessResult result = Process.runSync(
      '${hooksDir.path}/$staticAnalyzer',
      <String>[
        '--project-type',
        config.projectType,
        '--reporter-type',
        'console',
        config.projectDir.path
      ],
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    final String output = result.stdout.toString();
    final String outputError = result.stderr.toString();

    // Error first so user will see it first.
    final String fullOutput = '$outputError\n$output';

    if (outputError.isNotEmpty) {
      return fullOutput;
    } else {
      for (final String line in const LineSplitter().convert(fullOutput)) {
        // If line start with error, warning and invalid.
        if (line.startsWith(RegExp('(ERROR|WARNING|INVALID)'))) {
          return fullOutput;
        }
      }

      return '';
    }
  }

  @override
  Future<String> executeUnitTests() async {
    final Directory testDir = Directory('${config.projectDir.path}/test');

    if (!testDir.existsSync()) {
      throw UnrecoverableException(
        'Unit test are enabled but test dir doest not exit (${testDir.path})',
        ExitCode.config.code,
      );
    }

    final List<DartTest> tests = executeTest(
      'pub',
      <String>['run', 'test', '-r', 'json', testDir.path],
    ).where((DartTest element) => !element.succeeded).toList();

    if (tests.isNotEmpty) {
      return tests.map((DartTest e) => e.toString()).join('\n');
    }

    return '';
  }

  @override
  Future<String> executeIntegrationTests() {
    throw UnsupportedError(
      'Integration tests are not supported yet, please create a github issue '
      'or send pull request',
    );
  }

  @override
  Future<String> executeUiTests() {
    throw UnsupportedError(
      'UI tests are not supported yet, please create a github issue '
      'or send pull request',
    );
  }

  /// Execute tests using the provided [tool] with the specified [toolArgs].
  @protected
  List<DartTest> executeTest(final String tool, final List<String> toolArgs) {
    final ProcessResult result = Process.runSync(
      tool,
      toolArgs,
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    final String output = result.stdout.toString();
    final String outputError = result.stderr.toString();

    // Error first so user will see it first.
    final String fullOutput = '$outputError\n$output';

    return parseTests(fullOutput);
  }

  /// Parse the [testsOutput] to a list of [DartTest].
  @visibleForTesting
  List<DartTest> parseTests(final String testsOutput) {
    final Map<int, DartTest> failedTests = <int, DartTest>{};

    final Iterable<String> lines = testsOutput
        .split('\n')
        .where((String line) => line != '\n' && line.trim().isNotEmpty);

    for (final String line in lines) {
      final Object json = jsonDecode(line);

      if (json is Map<String, Object>) {
        if (json['type'] == 'testStart') {
          parseTestStartEvent(json, failedTests);
        } else if (json['type'] == 'testDone') {
          parseTestDoneEvent(json, failedTests);
        } else if (json['type'] == 'error') {
          parseTestErrorEvent(json, failedTests);
        }
      }
    }

    return failedTests.values.toList(growable: false);
  }

  /// Parse the test start event [json] and create/update
  /// the [DartTest] in [tests].
  @visibleForTesting
  void parseTestStartEvent(
    final Map<String, Object> json,
    final Map<int, DartTest> tests,
  ) {
    final int testId = parseTestId(json);

    final DartTest test = tests[testId] ?? DartTest();

    final Object testJson = json['test'];

    if (testJson is Map<String, Object>) {
      test
        ..testId = testId
        ..testName = testJson['name'].toString()
        ..file = testJson['url'].toString();
    }

    tests[testId] = test;
  }

  /// Parse the test done event [json] and create/update
  /// the [DartTest] in [tests].
  @visibleForTesting
  void parseTestDoneEvent(
    final Map<String, Object> json,
    final Map<int, DartTest> tests,
  ) {
    final int testId = parseTestId(json);

    final DartTest test = tests[testId] ?? DartTest();

    final Object rawResultField = json['result'];

    if (rawResultField is String) {
      switch (rawResultField) {
        case 'success':
          test.succeeded = true;
          break;
        case 'failure':
          test.succeeded = false;
          break;
        case 'error':
          test.succeeded = false;
          break;
      }
    }

    test.testId = testId;

    final Object rawHiddenField = json['hidden'];

    test.hidden = rawHiddenField is bool ? rawHiddenField : false;

    tests[testId] = test;
  }

  /// Parse the test error event [json] and create/update
  /// the [DartTest] in [tests].
  @visibleForTesting
  void parseTestErrorEvent(
    final Map<String, Object> json,
    final Map<int, DartTest> tests,
  ) {
    final int testId = parseTestId(json);

    final DartTest test = tests[testId] ?? DartTest();

    final Object rawError = json['error'];

    if (rawError is String) {
      test
        ..error = rawError
        ..succeeded = false;
    }

    final Object rawStackTrace = json['stackTrace'];

    if (rawStackTrace is String) {
      test
        ..error = '${test.error}\n$rawStackTrace'
        ..succeeded = false;
    }

    tests[testId] = test;
  }

  /// Parse the test id from the [json].
  @visibleForTesting
  int parseTestId(final Map<String, Object> json) {
    final Object rawTestId = json['testID'];

    int testId = rawTestId is int ? rawTestId : null;

    if (testId == null) {
      final Object test = json['test'];

      if (test is Map<String, Object>) {
        final Object possibleTestId = test['id'];

        testId = possibleTestId is int ? possibleTestId : null;
      }
    }

    return testId ?? -1;
  }
}

/// Dart test api representation of a test.
class DartTest {
  /// Id of the test in a test suite.
  int testId;

  /// The file containing the test.
  String file;

  /// The test's name.
  String testName;

  /// The error generated by test.
  String error;

  /// Ff the test succeeded or not.
  bool succeeded;

  /// If the test is hidden test or not.
  ///
  /// hidden tests are virtual tests created for loading test suites,
  /// setUpAll(), and tearDownAll().
  ///
  /// Only successful tests will be hidden.
  bool hidden;

  @override
  String toString() {
    return 'Test $testName in $file\n$error';
  }
}
