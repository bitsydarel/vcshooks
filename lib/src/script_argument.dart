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

import 'dart:io';

import 'package:args/args.dart';
import 'package:hooks/src/operating_system.dart';
import 'package:hooks/src/script_config.dart';
import 'package:meta/meta.dart';
import 'package:hooks/src/utils/script_utils.dart';

/// Script arguments.
///
/// Contains all the argument supported by the script.
class ScriptArgument {
  /// Project directory where the style checker will be executed.
  final Directory projectDir;

  /// Type of project the script is running against.
  final String projectType;

  /// Current operating system.
  final OperatingSystem operatingSystem;

  /// Git Hooks Directory.
  final Directory hooksDir;

  /// Code style check is enabled.
  final bool codeStyleCheckEnabled;

  /// Unit tests is enabled.
  final bool unitTestsEnabled;

  /// Integration tests is enabled.
  final bool integrationTestsEnabled;

  /// UI tests is enabled.
  final bool uiTestsEnabled;

  /// Create [ScriptArgument] with [projectType] and [projectDir].
  const ScriptArgument({
    @required this.projectType,
    @required this.projectDir,
    @required this.operatingSystem,
    @required this.hooksDir,
    @required this.codeStyleCheckEnabled,
    @required this.unitTestsEnabled,
    @required this.integrationTestsEnabled,
    @required this.uiTestsEnabled,
  })  : assert(projectDir != null, 'Project Dir should be specified'),
        assert(projectType != null, 'Project Type should be specified'),
        assert(operatingSystem != null, 'Operating system should be specified'),
        assert(hooksDir != null, 'Git hooks dir should be specified'),
        assert(
          codeStyleCheckEnabled != null,
          'Code style check enabled should be specified',
        ),
        assert(
          unitTestsEnabled != null,
          'Unit tests enabled should be specified',
        ),
        assert(
          integrationTestsEnabled != null,
          'Integration tests enabled should be specified',
        ),
        assert(uiTestsEnabled != null, 'UI tests enabled should be specified');

  /// Create a [ScriptArgument] from the provided [args].
  factory ScriptArgument.from(final ArgResults args) {
    final String projectType = args.parseProjectTypeArgument();

    final Directory projectDir = args.parseProjectDirArgument();

    final Directory gitHooksDir = args.getGitHooksDir(projectDir);

    return ScriptArgument(
      projectType: projectType,
      projectDir: projectDir,
      operatingSystem: getCurrentOs(),
      hooksDir: gitHooksDir,
      codeStyleCheckEnabled: args.parseCodeStyleCheckArgument(),
      unitTestsEnabled: args.parseUnitTestsEnabledArgument(),
      integrationTestsEnabled: args.parseIntegrationTestsEnabledArgument(),
      uiTestsEnabled: args.parseUiTestsEnabledArgument(),
    );
  }

  /// Convert the [ScriptArgument] to the [ScriptConfig].
  ScriptConfig toScriptConfig() {
    return ScriptConfig(
      projectType: projectType,
      projectDir: projectDir,
      hooksDir: hooksDir,
      preCommitConfig: PreCommitConfig(
        codeStyleCheckEnabled: codeStyleCheckEnabled,
        unitTestsEnabled: unitTestsEnabled,
        integrationTestsEnabled: integrationTestsEnabled,
        uiTestsEnabled: uiTestsEnabled,
      ),
    );
  }
}
