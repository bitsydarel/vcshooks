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

import 'package:hooks/hooks.dart';
import 'package:hooks/src/operating_system.dart';
import 'package:hooks/src/script_config.dart';
import 'package:io/io.dart';
import 'package:meta/meta.dart';

/// Hooks handler that take care of handling related git hooks actions.
abstract class HooksHandler {
  /// The [OperatingSystem] that the script is running on.
  final OperatingSystem operatingSystem;

  /// The script's configuration.
  final ScriptConfig config;

  /// Create
  const HooksHandler({
    @required this.operatingSystem,
    @required this.config,
  })  : assert(operatingSystem != null, "operating system can't be null"),
        assert(config != null, "config can't be null");

  /// Setup the hook handler.
  Future<void> setup();

  /// Check the commit message if it's match the rule.
  Future<void> checkCommitMessage(String commitMessage);

  /// Execute before commit checks.
  @mustCallSuper
  Future<void> executePreCommitChecks() async {
    final String branchNamingViolation = await executeBranchNamingCheck();

    if (branchNamingViolation?.isNotEmpty == true) {
      throw UnrecoverableException(
        branchNamingViolation,
        ExitCode.software.code,
      );
    }

    if (config.preCommitConfig.codeStyleCheckEnabled) {
      final String codeStyleViolations = await executeCodeStyleCheck();

      if (codeStyleViolations?.isNotEmpty == true) {
        throw UnrecoverableException(
          codeStyleViolations,
          ExitCode.software.code,
        );
      }
    }

    if (config.preCommitConfig.unitTestsEnabled) {
      final String unitTestsResult = await executeUnitTests();

      if (unitTestsResult?.isNotEmpty == true) {
        throw UnrecoverableException(unitTestsResult, ExitCode.software.code);
      }
    }

    if (config.preCommitConfig.integrationTestsEnabled) {
      final String integrationTests = await executeIntegrationTests();

      if (integrationTests?.isNotEmpty == true) {
        throw UnrecoverableException(integrationTests, ExitCode.software.code);
      }
    }

    if (config.preCommitConfig.uiTestsEnabled) {
      final String uiTests = await executeUiTests();

      if (uiTests?.isNotEmpty == true) {
        throw UnrecoverableException(uiTests, ExitCode.software.code);
      }
    }
  }

  /// Execute branch naming check.
  ///
  /// Return not empty [String] describing a failure if the check failed.
  Future<String> executeBranchNamingCheck();

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
