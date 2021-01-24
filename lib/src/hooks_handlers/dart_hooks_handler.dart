import 'dart:convert';
import 'dart:io';

import 'package:dart_hooks/dart_hooks.dart';
import 'package:dart_hooks/src/hooks_handlers/git_hooks_handler.dart';
import 'package:dart_hooks/src/utils/dart_utils.dart';
import 'package:io/io.dart';

///
class DartHooksHandler extends GitHooksHandler {
  ///
  DartHooksHandler({
    OperatingSystem os,
    Directory projectDir,
    Directory gitHooksDir,
    String projectType = 'dart',
  }) : super(
          os: os,
          projectDir: projectDir,
          gitHooksDir: gitHooksDir,
          projectType: projectType,
        );

  @override
  Future<String> executeCodeStyleCheck() async {
    final String staticAnalyzer = operatingSystem.staticAnalyzerFileName();

    final ProcessResult result = Process.runSync(
      '${hooksDir.path}/$staticAnalyzer',
      <String>[
        '--project-type',
        projectType,
        '--reporter-type',
        'console',
        projectDir.path
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
    final Directory testDir = Directory('${projectDir.path}/test');

    if (!testDir.existsSync()) {
      throw UnrecoverableException(
        'Unit test are enabled but test dir doest not exit (${testDir.path})',
        ExitCode.config.code,
      );
    }

    final String tool = operatingSystem.getTestTool();
    final List<String> toolArgs = operatingSystem.getTestToolArguments(testDir);

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

    final List<_Test> tests = _parseTests(fullOutput)
        .where((_Test element) => !element.hidden)
        .where((_Test element) => !element.succeeded)
        .toList();

    if (tests.isNotEmpty) {
      return tests.map((_Test e) => e.toString()).join('\n');
    }

    return '';
  }

  List<_Test> _parseTests(final String testsOutput) {
    final Map<int, _Test> failedTests = <int, _Test>{};

    stdout.writeln('Tests output: $testsOutput');

    final Iterable<String> lines = testsOutput
        .split('\n')
        .where((String line) => line != '\n' && line.trim().isNotEmpty);

    stdout.writeln('Joined output: $lines');

    for (final String line in lines) {
      stdout.writeln('Current line: $line');
      stdout.writeln('Current line length : ${line.length}');

      final Object json = jsonDecode(line);

      if (json is Map<String, Object>) {
        if (json['type'] == 'testStart') {
          _parseTestStartEvent(json, failedTests);
        } else if (json['type'] == 'testDone') {
          _parseTestDoneEvent(json, failedTests);
        } else if (json['type'] == 'error') {
          _parseTestErrorEvent(json, failedTests);
        }
      }
    }

    return failedTests.values.toList(growable: false);
  }

  @override
  Future<String> executeIntegrationTests() async => '';

  @override
  Future<String> executeUiTests() async => '';

  void _parseTestStartEvent(
    final Map<String, Object> json,
    final Map<int, _Test> tests,
  ) {
    final int testId = _parseTestId(json);

    final _Test test = tests[testId] ?? _Test();

    final Object testJson = json['test'];

    if (testJson is Map<String, Object>) {
      test
        ..testId = testId
        ..testName = testJson['name'].toString()
        ..file = testJson['url'].toString();
    }

    tests[testId] = test;
  }

  void _parseTestDoneEvent(
    final Map<String, Object> json,
    final Map<int, _Test> tests,
  ) {
    final int testId = _parseTestId(json);

    final _Test test = tests[testId] ?? _Test();

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

  void _parseTestErrorEvent(
    final Map<String, Object> json,
    final Map<int, _Test> tests,
  ) {
    final int testId = _parseTestId(json);

    final _Test test = tests[testId] ?? _Test();

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

  int _parseTestId(final Map<String, Object> json) {
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

class _Test {
  int testId;
  String file;
  String testName;
  String error;
  bool succeeded;
  bool hidden;

  @override
  String toString() {
    return 'Test $testName in file: $file\nError: $error';
  }
}
