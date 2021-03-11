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

import 'package:vcshooks/src/config_cache.dart';
import 'package:vcshooks/src/config_caches/file_config_cache.dart';
import 'package:vcshooks/src/vcs_hooks_handler.dart';
import 'package:vcshooks/src/hooks_handlers/dart_hooks_handler.dart';
import 'package:vcshooks/src/hooks_handlers/flutter_hooks_handler.dart';
import 'package:vcshooks/src/operating_system.dart';
import 'package:vcshooks/src/software_downloader.dart';
import 'package:vcshooks/src/software_downloader/dart_software_downloader.dart';
import 'package:vcshooks/src/utils/exceptions.dart';
import 'package:vcshooks/src/utils/script_utils.dart';
import 'package:io/io.dart';

/// Script configuration for the current project.
class ScriptConfig {
  /// The project type on which the script the script is running.
  final String projectType;

  /// The project's directory on which the script is run against.
  final Directory hooksDir;

  /// The hook's directory where tools are saved.
  final Directory projectDir;

  /// The operating system the script was install
  final String operatingSystem;

  /// Commit message rule
  final String commitMessageRule;

  /// The configuration for pre-commit event.
  final PreCommitConfig preCommitConfig;

  ///
  static const String hooksDirName = '.hooks_tools';

  /// Create the [ScriptConfig] with the specified [projectType], [projectDir],
  /// [hooksDir] and [preCommitConfig].
  const ScriptConfig({
    required this.operatingSystem,
    required this.projectType,
    required this.projectDir,
    required this.hooksDir,
    required this.commitMessageRule,
    required this.preCommitConfig,
  });

  /// Create json representation of the [ScriptConfig].
  Map<String, Object> toJson() {
    return <String, Object>{
      'operatingSystem': operatingSystem,
      'projectType': projectType,
      'projectDir': projectDir.path,
      'hooksDir': hooksDir.path,
      'commitMessageRule': commitMessageRule,
      'preCommitConfig': preCommitConfig.toJson(),
    };
  }

  /// Create a [ScriptConfig] from the provided [json].
  factory ScriptConfig.fromJson(final Map<String, Object?> json) {
    final Object? operatingSystem = json['operatingSystem'];
    final Object? projectType = json['projectType'];
    final Object? projectDir = json['projectDir'];
    final Object? hooksDir = json['hooksDir'];
    final Object? commitMessageRule = json['commitMessageRule'];
    final Object? preCommitConfig = json['preCommitConfig'];

    return ScriptConfig(
      operatingSystem: operatingSystem is String
          ? operatingSystem
          : throw ArgumentError.value(operatingSystem, 'operatingSystem'),
      projectType: projectType is String
          ? projectType
          : throw ArgumentError.value(projectType, 'projectType'),
      projectDir: projectDir is String
          ? Directory(projectDir)
          : throw ArgumentError.value(projectDir, 'projectDir'),
      hooksDir: hooksDir is String
          ? Directory(hooksDir)
          : throw ArgumentError.value(hooksDir, 'hooksDir'),
      commitMessageRule: commitMessageRule is String
          ? commitMessageRule
          : throw ArgumentError.value(commitMessageRule, 'commitMessageRule'),
      preCommitConfig: preCommitConfig is Map<String, Object?>
          ? PreCommitConfig.fromJson(preCommitConfig)
          : throw ArgumentError.value(preCommitConfig, 'preCommitConfig'),
    );
  }

  /// Get default hooks directory for the specified [projectDir].
  static Directory getDefaultHooksDir(final Directory projectDir) {
    return Directory('${projectDir.path}/$hooksDirName');
  }
}

/// Pre-commit configuration for the current project.
class PreCommitConfig {
  /// Branch naming rule as regex.
  final String branchNamingRule;

  /// If code style check is enabled.
  final bool codeStyleCheckEnabled;

  /// If unit tests are enabled.
  final bool unitTestsEnabled;

  /// If integration tests are enabled.
  final bool integrationTestsEnabled;

  /// If UI tests are enabled.
  final bool uiTestsEnabled;

  /// Create a [PreCommitConfig].
  const PreCommitConfig({
    required this.branchNamingRule,
    required this.codeStyleCheckEnabled,
    required this.unitTestsEnabled,
    required this.integrationTestsEnabled,
    required this.uiTestsEnabled,
  });

  /// Create the current [PreCommitConfig] from [json] represented as [Map] of
  /// key value pairs.
  factory PreCommitConfig.fromJson(final Map<String, Object?> json) {
    final Object? branchNamingRule = json['branchNamingRule'];
    final Object? codeStyleCheckEnabled = json['codeStyleCheckEnabled'];
    final Object? unitTestsEnabled = json['unitTestsEnabled'];
    final Object? integrationTestsEnabled = json['integrationTestsEnabled'];
    final Object? uiTestsEnabled = json['uiTestsEnabled'];

    return PreCommitConfig(
      branchNamingRule: branchNamingRule is String
          ? branchNamingRule
          : throw ArgumentError.value(branchNamingRule, 'branchNamingRule'),
      codeStyleCheckEnabled: codeStyleCheckEnabled is bool
          ? codeStyleCheckEnabled
          : throw ArgumentError.value(
              codeStyleCheckEnabled,
              'codeStyleCheckEnabled',
            ),
      unitTestsEnabled: unitTestsEnabled is bool
          ? unitTestsEnabled
          : throw ArgumentError.value(unitTestsEnabled, 'unitTestsEnabled'),
      integrationTestsEnabled: integrationTestsEnabled is bool
          ? integrationTestsEnabled
          : throw ArgumentError.value(
              integrationTestsEnabled,
              'integrationTestsEnabled',
            ),
      uiTestsEnabled: uiTestsEnabled is bool
          ? uiTestsEnabled
          : throw ArgumentError.value(uiTestsEnabled, 'uiTestsEnabled'),
    );
  }

  /// Convert the current [PreCommitConfig] to a json representation
  /// of key value pairs.
  Map<String, Object> toJson() {
    return <String, Object>{
      'branchNamingRule': branchNamingRule,
      'codeStyleCheckEnabled': codeStyleCheckEnabled,
      'unitTestsEnabled': unitTestsEnabled,
      'integrationTestsEnabled': integrationTestsEnabled,
      'uiTestsEnabled': uiTestsEnabled,
    };
  }
}

/// Script Configuration Extensions.
extension ScriptConfigExtension on ScriptConfig {
  /// Get the [ConfigCache] that match the current script configuration.
  ConfigCache cache() {
    return FileConfigCache(hooksDir: hooksDir);
  }

  /// Get the [VCSHooksHandler] that match the current script configuration.
  VCSHooksHandler hookHandler(final OperatingSystem currentOs) {
    switch (projectType) {
      case dartProjectType:
        return DartHooksHandler(os: currentOs, config: this);
      case flutterProjectType:
        return FlutterHooksHandler(os: currentOs, config: this);
      default:
        throw UnrecoverableException(
          'Project type not supported\nPlease run setup tool',
          ExitCode.config.code,
        );
    }
  }

  /// Get the [SoftwareDownloader] that match the current script configuration.
  SoftwareDownloader softwareDownloader(final OperatingSystem currentOs) {
    switch (projectType) {
      case dartProjectType:
      case flutterProjectType:
        return DartSoftwareDownloader(hooksDir, currentOs);
      default:
        throw UnrecoverableException(
          'Project type not supported\nPlease run setup tool',
          ExitCode.config.code,
        );
    }
  }

  /// Validate script configuration.
  ///
  /// [currentDirPath] represent the current project directory path.
  /// [hooksDirPath] represent the current project hooks directory path.
  ///
  /// Throws [UnrecoverableException] if one or some of the directory does not
  /// match the current project's script configuration.
  void validateConfig(
    final OperatingSystem currentOs,
    final String currentDirPath,
    final String hooksDirPath,
  ) {
    if (currentDirPath != projectDir.path) {
      throw UnrecoverableException(
        'Current directory $currentDirPath is different than '
        '${projectDir.path}\nPlease run setup tool',
        ExitCode.config.code,
      );
    }

    if (hooksDirPath != hooksDir.path) {
      throw UnrecoverableException(
        'Current hooks directory $hooksDirPath is different than '
        '${hooksDir.path}\nPlease run setup tool',
        ExitCode.config.code,
      );
    }

    if (currentOs.name() != operatingSystem) {
      throw UnrecoverableException(
        'Script was configured on $operatingSystem but now the project is run '
        'on  ${currentOs.name()}\nPlease run setup tool',
        ExitCode.config.code,
      );
    }
  }
}
