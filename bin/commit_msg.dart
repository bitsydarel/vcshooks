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

import 'package:vcshooks/vcshooks.dart';
import 'package:io/ansi.dart';
import 'package:io/io.dart';

/// Run the commit message check with the specified [arguments].
void main(final List<String> arguments) {
  runZonedGuarded(
    () async {
      final File commitMessageFile = File(arguments.first);

      if (!commitMessageFile.existsSync()) {
        throw UnrecoverableException(
          'Commit message file: ${commitMessageFile.path} does not exit',
          ExitCode.usage.code,
        );
      }

      final String commitMessage =
          commitMessageFile.readAsLinesSync().join('\n');

      final OperatingSystem os = getCurrentOs();

      final ScriptConfig config = await loadScriptConfig(os, Directory.current);

      final VCSHooksHandler handler = config.hookHandler(os);

      stdout.writeln(yellow.wrap('commit message check in progress...'));

      await handler.checkCommitMessage(commitMessage);

      stdout.writeln(green.wrap('commit message passed'));
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
