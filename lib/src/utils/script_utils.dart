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
import 'package:vcshooks/src/config_cache.dart';
import 'package:vcshooks/src/config_caches/file_config_cache.dart';
import 'package:vcshooks/src/hooks_handlers/git_hooks_handler.dart';
import 'package:vcshooks/src/operating_system.dart';
import 'package:vcshooks/src/script_config.dart';
import 'package:vcshooks/src/utils/exceptions.dart';
import 'package:io/ansi.dart';
import 'package:io/io.dart';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

const String _projectTypeArgument = 'project-type';

/// Script parameter used for [_projectTypeArgument] parameter to specify
/// that the script is run on a dart project.
const String dartProjectType = 'dart';

/// Script parameter used for [_projectTypeArgument] parameter to specify
/// that the script is run on a flutter project.
const String flutterProjectType = 'flutter';

/// List of project type supported by the script.
const List<String> supportedProjectType = <String>[
  dartProjectType,
  flutterProjectType,
];

/// Script parameter used to print help.
const String helpArgument = 'help';

const String _commitMessageRuleArgument = 'commit-message-rule';

const String _branchNamingRuleArgument = 'branch-naming-rule';

const String _codeStyleCheckEnabledArgument = 'code-style-check-enabled';

const String _unitTestsEnabledArgument = 'unit-tests-enabled';

const String _integrationTestsEnabledArgument = 'integration-tests-enabled';

const String _uiTestsEnabledArgument = 'ui-tests-enabled';

/// Script argument parser.
final ArgParser argumentParser = ArgParser()
  ..addOption(
    _projectTypeArgument,
    defaultsTo: dartProjectType,
    allowed: supportedProjectType,
    allowedHelp: <String, String>{
      dartProjectType: 'Static analytics for dart project',
      flutterProjectType: 'Static analytics for flutter project',
    },
    help: 'Specify the type of project the script is run on',
  )
  ..addOption(
    _commitMessageRuleArgument,
    help: 'Specify the commit message rule',
    defaultsTo: GitHooksHandler.defaultCommitMessageRule,
  )
  ..addOption(
    _branchNamingRuleArgument,
    help: 'Specify the branch naming rule',
    defaultsTo: GitHooksHandler.defaultBranchNameRule,
  )
  ..addFlag(
    _codeStyleCheckEnabledArgument,
    defaultsTo: true,
    help: 'Enable code style check on pre-commit',
  )
  ..addFlag(
    _unitTestsEnabledArgument,
    defaultsTo: true,
    help: 'Enable unit tests on pre-commit',
  )
  ..addFlag(
    _integrationTestsEnabledArgument,
    hide: true,
    help: 'Enable integration tests on pre-commit',
  )
  ..addFlag(
    _uiTestsEnabledArgument,
    hide: true,
    help: 'Enable UI tests on pre-commit',
  )
  ..addFlag(
    helpArgument,
    help: 'Print help message',
  );

/// Print help message to the console.
void printHelpMessage([final String message]) {
  if (message != null) {
    stderr.writeln(red.wrap('$message\n'));
  }

  final String options =
      LineSplitter.split(argumentParser.usage).map((String l) => l).join('\n');

  stdout.writeln(
    'Usage: vcshooks --$_projectTypeArgument '
    '[${supportedProjectType.join(', ')}] <local project directory>'
    '\nOptions:\n$options',
  );
}

/// Load the current project script config and validate that its content.
Future<ScriptConfig> loadScriptConfig(
  final OperatingSystem currentOS,
  final Directory currentDir,
) async {
  final Directory hooksDir = await GitHooksHandler.getCurrentHooksDir();

  if (!hooksDir.existsSync()) {
    throw UnrecoverableException(
      'Git Hooks directory ${hooksDir.path} not found\n'
      'Please run setup tool',
      ExitCode.config.code,
    );
  }

  final ConfigCache configCache = FileConfigCache(hooksDir: hooksDir);

  final ScriptConfig scriptConfig = await configCache.loadScriptConfig();

  if (scriptConfig == null) {
    throw UnrecoverableException(
      'Script config not found in dir ${hooksDir.path}\n'
      'Please run setup tool',
      ExitCode.config.code,
    );
  }

  scriptConfig.validateConfig(currentOS, currentDir.path, hooksDir.path);

  return scriptConfig;
}

/// Script arguments parser.
///
/// Contains helper method, that parse each script argument.
extension ArgResultsExtenstion on ArgResults {
  /// Parse the project type.
  String parseProjectTypeArgument() {
    // fail if the project type was not provided
    if (!wasParsed(_projectTypeArgument)) {
      throw const UnrecoverableException(
        '$_projectTypeArgument parameter is required',
        exitMissingRequiredArgument,
      );
    }

    final dynamic projectType = this[_projectTypeArgument];

    if (projectType is String &&
        projectType.isNotEmpty &&
        supportedProjectType.contains(projectType)) {
      return projectType;
    } else {
      throw UnrecoverableException(
        '$_projectTypeArgument parameter is required, '
        "supported values are ${supportedProjectType.join(", ")}",
        exitMissingRequiredArgument,
      );
    }
  }

  /// Parse the project directory argument.
  Directory parseProjectDirArgument() {
    if (rest.length != 1) {
      throw const UnrecoverableException(
        'invalid project dir path',
        exitInvalidArgument,
      );
    }

    final Directory projectDir = getResolvedProjectDir(rest[0]);

    if (!projectDir.existsSync()) {
      throw const UnrecoverableException(
        'specified local project dir does not exist',
        exitInvalidArgument,
      );
    }

    return projectDir;
  }

  /// Parse the git hooks directory argument
  Directory getGitHooksDir(final Directory projectDir) {
    final Directory hooksDir = Directory(
      '${projectDir.path}/${ScriptConfig.hooksDirName}',
    );

    try {
      if (hooksDir.existsSync()) {
        hooksDir.deleteSync(recursive: true);
      }
      hooksDir.createSync();
    } on Exception catch (exception) {
      throw UnrecoverableException(
        'git hooks dir could not be created.\n'
        'System error: ${exception.toString()}',
        exitUnexpectedError,
      );
    }

    return hooksDir;
  }

  /// Parse commit message rule argument
  String parseCommitMessageRuleArgument() {
    final dynamic commitMessageRule = this[_commitMessageRuleArgument];

    if (commitMessageRule is String && commitMessageRule.isNotEmpty) {
      return commitMessageRule;
    } else {
      throw UnrecoverableException(
        '$_commitMessageRuleArgument argument not provided',
        ExitCode.usage.code,
      );
    }
  }

  /// Parse branch naming rule argument
  String parseBranchNamingRuleArgument() {
    final dynamic branchNamingRule = this[_branchNamingRuleArgument];

    if (branchNamingRule is String && branchNamingRule.isNotEmpty) {
      return branchNamingRule;
    } else {
      throw UnrecoverableException(
        '$_branchNamingRuleArgument argument not provided',
        ExitCode.usage.code,
      );
    }
  }

  /// Parse code style check argument
  bool parseCodeStyleCheckArgument() {
    final dynamic codeStyleCheckEnabled = this[_codeStyleCheckEnabledArgument];

    if (codeStyleCheckEnabled is bool) {
      return codeStyleCheckEnabled;
    } else {
      throw UnrecoverableException(
        '$_codeStyleCheckEnabledArgument argument not provided',
        ExitCode.usage.code,
      );
    }
  }

  /// Parse unit tests enabled argument
  bool parseUnitTestsEnabledArgument() {
    final dynamic unitTestsEnabled = this[_unitTestsEnabledArgument];

    if (unitTestsEnabled is bool) {
      return unitTestsEnabled;
    } else {
      throw UnrecoverableException(
        '$_unitTestsEnabledArgument argument not provided',
        ExitCode.usage.code,
      );
    }
  }

  /// Parse integration tests enabled argument
  bool parseIntegrationTestsEnabledArgument() {
    final dynamic integrationTests = this[_integrationTestsEnabledArgument];

    if (integrationTests is bool) {
      return integrationTests;
    } else {
      throw UnrecoverableException(
        '$_integrationTestsEnabledArgument argument not provided',
        ExitCode.usage.code,
      );
    }
  }

  /// Parse UI tests enabled argument
  bool parseUiTestsEnabledArgument() {
    final dynamic uiTestsEnabled = this[_uiTestsEnabledArgument];

    if (uiTestsEnabled is bool) {
      return uiTestsEnabled;
    } else {
      throw UnrecoverableException(
        '$_uiTestsEnabledArgument argument not provided',
        ExitCode.usage.code,
      );
    }
  }
}

/// Get the project [Directory] with a full path.
Directory getResolvedProjectDir(final String projectDir) {
  return Directory(path.canonicalize(projectDir));
}
