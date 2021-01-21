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
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_hooks/dart_hooks.dart';
import 'package:dart_hooks/src/git_hooks_handler.dart';

Future<void> main(List<String> arguments) async {
  ArgResults argResults;

  try {
    argResults = argumentParser.parse(arguments);
  } on Exception catch (_) {
    printHelpMessage('Invalid parameter specified.');
    exitCode = exitInvalidArgument;
    return;
  }

  if (argResults.wasParsed(helpParameter)) {
    printHelpMessage();
    exitCode = 0;
    return;
  }

  runZonedGuarded<void>(
    () async {
      final ScriptArgument scriptArgument = ScriptArgument.from(argResults);

      Directory.current = scriptArgument.projectDir.path;

      final SoftwareDownloader softwareDownloader = _getSoftwareDownloader(
        scriptArgument.operatingSystem,
        scriptArgument.gitHooksDir,
        scriptArgument,
      );

      await softwareDownloader.downloadPreCommitTools();

      final GitHooksHandler initializer = GitHooksHandler(
        scriptArgument.operatingSystem,
        scriptArgument.gitHooksDir,
      );

      await initializer.setup();
    },
    (Object error, StackTrace stack) {
      if (error is UnrecoverableException) {
        printHelpMessage(error.reason);
        exitCode = error.exitCode;
        return;
      } else {
        printHelpMessage(error.toString());
        exitCode = exitUnexpectedError;
        return;
      }
    },
  );
}

SoftwareDownloader _getSoftwareDownloader(
  final OperatingSystem currentOs,
  final Directory toolsDir,
  final ScriptArgument scriptArgument,
) {
  switch (scriptArgument.projectType) {
    case dartProjectType:
    case flutterProjectType:
      return DartSoftwareDownloader(toolsDir, currentOs);
    default:
      throw UnrecoverableException(
        'Unsupported project type, '
        'supported project type: ${supportedProjectType.join(', ')}',
        exitMissingRequiredArgument,
      );
  }
}
