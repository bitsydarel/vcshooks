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

    stdout.writeln('Exit code is ${result.exitCode}');

    if (result.exitCode != ExitCode.success.code) {
      return '${result.stderr.toString()}\n${result.stdout.toString()}';
    } else {
      return '';
    }
  }

  @override
  Future<String> executeUnitTests() async => '';

  @override
  Future<String> executeIntegrationTests() async => '';

  @override
  Future<String> executeUiTests() async => '';
}
