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

import 'dart:async';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:hooks/src/config_cache.dart';
import 'package:hooks/src/config_caches/file_config_cache.dart';
import 'package:hooks/src/script_config.dart';
import 'package:io/ansi.dart';
import 'package:io/io.dart';

// Run the script with the provided [arguments].
Future<void> main(List<String> arguments) async {
  stdout.writeln(arguments.join(', '));

  runZonedGuarded<void>(
    () async {
      final OperatingSystem os = getCurrentOs();

      final Directory hooksDir = await GitHooksHandler.getCurrentHooksDir();

      if (!hooksDir.existsSync()) {
        throw UnrecoverableException(
          'Git Hooks directory ${hooksDir.path} not found\n'
          'Please run setup tool',
          ExitCode.config.code,
        );
      }

      final ScriptConfig config = await _getConfig(hooksDir);

      if (config == null) {
        throw UnrecoverableException(
          'Script config not found in dir ${hooksDir.path}\n'
          'Please run setup tool',
          ExitCode.config.code,
        );
      }

      config.validateConfig(Directory.current.path, hooksDir.path);

      final HooksHandler handler = _getHookHandler(os, config);

      await handler.executePreCommitChecks();
    },
    (Object error, StackTrace trace) {
      if (error is UnrecoverableException) {
        stderr.writeln(red.wrap(error.reason));
        exitCode = error.exitCode;
      } else {
        stderr.writeln(red.wrap(error.toString()));
        exitCode = exitUnexpectedError;
      }
    },
  );
}

Future<ScriptConfig> _getConfig(final Directory hooksDir) async {
  final ConfigCache configCache = FileConfigCache(hooksDir: hooksDir);

  return configCache.loadScriptConfig();
}

HooksHandler _getHookHandler(
  final OperatingSystem operatingSystem,
  final ScriptConfig config,
) {
  switch (config.projectType) {
    case dartProjectType:
      return DartHooksHandler(os: operatingSystem, config: config);
    default:
      throw UnrecoverableException(
        'Project type not supported\nPlease run setup tool',
        ExitCode.config.code,
      );
  }
}
