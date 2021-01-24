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
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER 
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
 * OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_hooks/src/hooks_handler.dart';
import 'package:dart_hooks/src/operating_system.dart';
import 'package:dart_hooks/src/utils/exceptions.dart';
import 'package:io/io.dart';
import 'package:meta/meta.dart';

/// Git hooks handler that take care of handling related git hooks actions.
abstract class GitHooksHandler extends HooksHandler {
  /// Create a [GitHooksHandler] with the provided [os], [projectType],
  /// [projectType], [projectDir], [gitHooksDir].
  GitHooksHandler({
    @required OperatingSystem os,
    @required String projectType,
    @required Directory projectDir,
    @required Directory gitHooksDir,
  }) : super(
          operatingSystem: os,
          projectType: projectType,
          projectDir: projectDir,
          hooksDir: gitHooksDir,
        );

  @override
  Future<void> setup() async {
    final Directory currentGitHooks = await getCurrentGitHooksDirectory();

    if (currentGitHooks != hooksDir) {
      setCurrentGitHooksDirectory(hooksDir);
    }

    final String permissionTool = operatingSystem.getPermissionTool();
    final List<String> permissionToolArgs =
        operatingSystem.getPermissionToolArgs(hooksDir);

    final ProcessResult processResult = Process.runSync(
      permissionTool,
      permissionToolArgs,
    );

    if (processResult.exitCode != ExitCode.success.code) {
      throw UnrecoverableException(
        processResult.stderr.toString(),
        ExitCode.osError.code,
      );
    }
  }

  /// Get current git hooks directory.
  @visibleForTesting
  Future<Directory> getCurrentGitHooksDirectory() async {
    final ProcessResult processResult = Process.runSync(
      'git',
      <String>['config', '--get', 'core.hooksPath'],
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    if (processResult.exitCode == ExitCode.success.code) {
      return Directory(processResult.stdout.toString());
    } else {
      throw UnrecoverableException(
        'Could not get current git hooks directory\n'
        'Error: ${processResult.stderr.toString()}',
        processResult.exitCode,
      );
    }
  }

  /// Set current git hooks directory as the specified [gitHooksDir].
  @visibleForTesting
  Future<void> setCurrentGitHooksDirectory(final Directory gitHooksDir) async {
    final ProcessResult processResult = Process.runSync(
      'git',
      <String>['config', 'core.hooksPath', gitHooksDir.path],
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    if (processResult.exitCode != ExitCode.success.code) {
      throw UnrecoverableException(
        'Could not set git hooks directory to ${gitHooksDir.path}\n'
        'Error: ${processResult.stderr.toString()}',
        processResult.exitCode,
      );
    }
  }
}
