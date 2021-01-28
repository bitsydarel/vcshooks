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

import 'package:hooks/src/operating_system.dart';
import 'package:hooks/src/software_downloader.dart';
import 'package:hooks/src/utils/exceptions.dart';
import 'package:hooks/src/utils/git_utils.dart';
import 'package:http/http.dart' as http;

/// Git software downloader.
///
/// Download software required to execute hooks on a git project.
class GitSoftwareDownloader extends SoftwareDownloader {
  /// Create a [GitSoftwareDownloader] with the provided [hooksDir] and [os].
  const GitSoftwareDownloader(
    OperatingSystem os,
    Directory hooksDir,
  ) : super(os, hooksDir);

  @override
  Future<void> downloadPreCommitTools() async {
    await _downloadPreCommitChecker();

    await _downloadCommitMsgCheck();
  }

  Future<void> _downloadPreCommitChecker() async {
    final String preCommitLink = currentOs.getPreCommitDownloadLink();
    final String preCommitFileName = currentOs.getPreCommitFileName();

    final File preCommitFile = File('${hooksDir.path}/$preCommitFileName');

    try {
      final Uint8List response = await http.readBytes(preCommitLink);

      preCommitFile.writeAsBytes(response, flush: true);

      stdout.writeln('Downloaded $preCommitFileName for pre-commit check');
    } on http.ClientException catch (exception) {
      throw UnrecoverableException(
        '${exception.uri} : ${exception.message}',
        exitUnexpectedError,
      );
    }
  }

  Future<void> _downloadCommitMsgCheck() async {
    final String commitMsgLink = currentOs.getCommitMsgDownloadLink();
    final String commitMsgFileName = currentOs.getCommitMsgFileName();

    final File commitMsgFile = File('${hooksDir.path}/$commitMsgFileName');

    try {
      final Uint8List response = await http.readBytes(commitMsgLink);

      commitMsgFile.writeAsBytes(response, flush: true);

      stdout.writeln('Downloaded $commitMsgFileName for commit message check');
    } on http.ClientException catch (exception) {
      throw UnrecoverableException(
        '${exception.uri} : ${exception.message}',
        exitUnexpectedError,
      );
    }
  }
}
