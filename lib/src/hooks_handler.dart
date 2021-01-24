import 'dart:io';

import 'package:dart_hooks/dart_hooks.dart';
import 'package:dart_hooks/src/operating_system.dart';
import 'package:io/io.dart';
import 'package:meta/meta.dart';

/// Hooks handler that take care of handling related git hooks actions.
abstract class HooksHandler {
  /// the [OperatingSystem] that the script is running on.
  final OperatingSystem operatingSystem;

  /// The project type on which the script the script is running.
  final String projectType;

  /// The project's directory on which the script is run against.
  final Directory projectDir;

  /// The hook's directory where tools are saved.
  final Directory hooksDir;

  /// Create
  const HooksHandler({
    @required this.operatingSystem,
    @required this.projectType,
    @required this.projectDir,
    @required this.hooksDir,
  })  : assert(operatingSystem != null, "operating system can't be null"),
        assert(
          projectType != null,
          "project type can't be null/empty",
        ),
        assert(projectDir != null, "projectDir can't be null"),
        assert(hooksDir != null, "hooksDir can't be null");

  /// Setup the hook handler.
  Future<void> setup();

  /// Execute before commit checks.
  @mustCallSuper
  Future<void> executeBeforeCommitChecks() async {
    final String codeStyleViolations = await executeCodeStyleCheck();

    if (codeStyleViolations?.isNotEmpty == true) {
      throw UnrecoverableException(codeStyleViolations, ExitCode.software.code);
    }

    final String unitTestsResult = await executeUnitTests();

    if (unitTestsResult?.isNotEmpty == true) {
      throw UnrecoverableException(unitTestsResult, ExitCode.software.code);
    }

    final String integrationTests = await executeIntegrationTests();

    if (integrationTests?.isNotEmpty == true) {
      throw UnrecoverableException(integrationTests, ExitCode.software.code);
    }

    final String uiTests = await executeUiTests();

    if (uiTests?.isNotEmpty == true) {
      throw UnrecoverableException(uiTests, ExitCode.software.code);
    }
  }

  /// Execute code style check.
  ///
  /// Return not empty [String] describing a failure if the check failed.
  @protected
  Future<String> executeCodeStyleCheck();

  /// Execute unit tests.
  ///
  /// Return not empty [String] describing a test failure if the check failed.
  @protected
  Future<String> executeUnitTests();

  /// Execute integration tests.
  ///
  /// Return not empty [String] describing a test failure if the check failed.
  @protected
  Future<String> executeIntegrationTests();

  /// Execute UI tests.
  ///
  /// Return not empty [String] describing a test failure if the check failed.
  @protected
  Future<String> executeUiTests();
}
