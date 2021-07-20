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
import 'dart:typed_data';

import 'package:vcshooks/src/software_downloader/git_software_downloader.dart';
import 'package:vcshooks/src/utils/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:vcshooks/src/operating_system.dart';
import 'package:vcshooks/src/utils/dart_utils.dart';

/// Dart software downloader
///
/// Download software required to execute hooks on a dart project.
class DartSoftwareDownloader extends GitSoftwareDownloader {
  /// Create a [DartSoftwareDownloader] with the provided [hooksDir] and [os].
  const DartSoftwareDownloader(
    Directory hooksDir,
    OperatingSystem os,
  ) : super(os, hooksDir);

  @override
  Future<void> downloadPreCommitTools() async {
    await super.downloadPreCommitTools();

    await _downloadStaticAnalyzer();
  }

  Future<void> _downloadStaticAnalyzer() async {
    final String staticAnalyzerFileName = currentOs.getCodeStyleCheckFileName();
    final String staticAnalyzerLink = currentOs.getCodeStyleCheckDownloadLink();

    final File staticAnalyzer = File(
      '${hooksDir.path}/$staticAnalyzerFileName',
    );

    try {
      final Uint8List response =
          await http.readBytes(Uri.parse(staticAnalyzerLink));

      staticAnalyzer.writeAsBytesSync(response, flush: true);

      stdout.writeln('Downloaded $staticAnalyzerFileName for static analysis');
    } on http.ClientException catch (exception) {
      throw UnrecoverableException(
        '${exception.uri} : ${exception.message}',
        exitUnexpectedError,
      );
    }
  }
}
