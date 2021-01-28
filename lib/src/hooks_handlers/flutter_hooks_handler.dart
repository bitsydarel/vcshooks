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

import 'package:vcshooks/src/hooks_handlers/dart_hooks_handler.dart';
import 'package:vcshooks/src/operating_system.dart';
import 'package:vcshooks/src/script_config.dart';
import 'package:vcshooks/src/utils/exceptions.dart';
import 'package:io/io.dart';
import 'package:meta/meta.dart';

/// Flutter hooks handler take care of executing hooks on a flutter project.
class FlutterHooksHandler extends DartHooksHandler {
  ///
  FlutterHooksHandler({
    @required OperatingSystem os,
    @required ScriptConfig config,
  }) : super(os: os, config: config);

  @override
  Future<String> executeUnitTests() async {
    final Directory testDir = Directory('${config.projectDir.path}/test');

    if (!testDir.existsSync()) {
      throw UnrecoverableException(
        'Unit test are enabled but test dir doest not exit (${testDir.path})',
        ExitCode.config.code,
      );
    }

    final List<DartTest> tests = executeTest(
      'flutter',
      <String>['test', '--machine', testDir.path],
    ).where((DartTest element) => !element.succeeded).toList();

    if (tests.isNotEmpty) {
      return tests.map((DartTest e) => e.toString()).join('\n');
    }

    return '';
  }
}
