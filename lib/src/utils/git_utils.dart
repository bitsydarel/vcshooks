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

import 'package:vcshooks/src/operating_system.dart';

const String _hooksToolUrl =
    'https://github.com/bitsydarel/vcshooks/releases/download/v0.1.3';

/// Flutter
extension GitSupportedOperatingSystemExtensions on OperatingSystem {
  /// Get the code style check tool download link.
  String getPreCommitDownloadLink() {
    switch (this) {
      case OperatingSystem.windows:
        return '$_hooksToolUrl/precommit-windows.exe';
      case OperatingSystem.macOs:
        return '$_hooksToolUrl/precommit-macos';
      case OperatingSystem.linux:
        return '$_hooksToolUrl/precommit-linux';
    }
  }

  /// Get the code style check file name.
  String getPreCommitFileName() {
    switch (this) {
      case OperatingSystem.windows:
      case OperatingSystem.macOs:
      case OperatingSystem.linux:
        return 'pre-commit';
    }
  }

  /// Get the code style check tool download link.
  String getCommitMsgDownloadLink() {
    switch (this) {
      case OperatingSystem.windows:
        return '$_hooksToolUrl/commit-msg-windows.exe';
      case OperatingSystem.macOs:
        return '$_hooksToolUrl/commit-msg-macos';
      case OperatingSystem.linux:
        return '$_hooksToolUrl/commit-msg-linux';
    }
  }

  /// Get the code style check file name.
  String getCommitMsgFileName() {
    switch (this) {
      case OperatingSystem.windows:
      case OperatingSystem.macOs:
      case OperatingSystem.linux:
        return 'commit-msg';
    }
  }
}
