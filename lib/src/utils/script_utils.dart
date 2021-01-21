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

import 'dart:convert';
import 'dart:io';
import 'package:dart_hooks/dart_hooks.dart';
import 'package:dart_hooks/src/utils/exceptions.dart';
import 'package:io/ansi.dart';
import 'package:meta/meta.dart';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

const String _projectTypeParameter = 'project-type';

/// Script parameter used for [_projectTypeParameter] parameter to specify
/// that the script is run on a dart project.
const String dartProjectType = 'dart';

/// Script parameter used for [_projectTypeParameter] parameter to specify
/// that the script is run on a flutter project.
const String flutterProjectType = 'flutter';

/// List of project type supported by the script.
const List<String> supportedProjectType = <String>[
  dartProjectType,
  flutterProjectType,
];

/// Script parameter used to print help.
const String helpParameter = 'help';

/// Script argument parser.
final ArgParser argumentParser = ArgParser()
  ..addOption(
    _projectTypeParameter,
    defaultsTo: dartProjectType,
    allowed: supportedProjectType,
    allowedHelp: <String, String>{
      dartProjectType: 'Static analytics for dart project',
      flutterProjectType: 'Static analytics for flutter project',
    },
    help: 'Specify the type of project the script is run on',
  )
  ..addFlag(
    helpParameter,
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
    'Usage: dart_hooks --$_projectTypeParameter '
        '[${supportedProjectType.join(', ')}] <local project directory>'
        '\nOptions:\n$options',
  );
}

/// Script arguments.
///
/// Contains all the argument supported by the script.
class ScriptArgument {
  /// Project directory where the style checker will be executed.
  final Directory projectDir;

  /// Type of project the script is running against.
  final String projectType;

  /// Current operating system.
  final OperatingSystem operatingSystem;

  /// Git Hooks Directory.
  final Directory gitHooksDir;

  /// Create [ScriptArgument] with [projectType] and [projectDir].
  const ScriptArgument({
    @required this.projectType,
    @required this.projectDir,
    @required this.operatingSystem,
    @required this.gitHooksDir,
  })
      : assert(projectDir != null, 'Project Dir should be specified'),
        assert(projectType != null, 'Project Type should be specified'),
        assert(operatingSystem != null, 'Operating system should be specified'),
        assert(gitHooksDir != null, 'Git hooks dir should be specified');

  /// Create a [ScriptArgument] from the provided [argResults].
  factory ScriptArgument.from(final ArgResults argResults) {
    final String projectType = _parseProjectType(argResults);

    final Directory projectDir = _parseProjectDirParameter(argResults);

    final OperatingSystem currentOs = getCurrentOs();

    final Directory gitHooksDir = _parseGitHooksDirParameter(projectDir);

    return ScriptArgument(
      projectType: projectType,
      projectDir: projectDir,
      operatingSystem: currentOs,
      gitHooksDir: gitHooksDir,
    );
  }

  static String _parseProjectType(final ArgResults argResults) {
    if (!argResults.wasParsed(_projectTypeParameter)) {
      throw const UnrecoverableException(
        '$_projectTypeParameter parameter is required',
        exitMissingRequiredArgument,
      );
    }

    final dynamic projectType = argResults[_projectTypeParameter];

    if (projectType is String &&
        projectType.isNotEmpty &&
        supportedProjectType.contains(projectType)) {
      return projectType;
    } else {
      throw UnrecoverableException(
        '$_projectTypeParameter parameter is required, '
            "supported values are ${supportedProjectType.join(", ")}",
        exitMissingRequiredArgument,
      );
    }
  }

  static Directory _parseProjectDirParameter(final ArgResults argResults) {
    if (argResults.rest.length != 1) {
      throw const UnrecoverableException(
        'invalid project dir path',
        exitInvalidArgument,
      );
    }

    final Directory projectDir = getResolvedProjectDir(argResults.rest[0]);

    if (!projectDir.existsSync()) {
      throw const UnrecoverableException(
        'specified local project dir does not exist',
        exitInvalidArgument,
      );
    }

    return projectDir;
  }

  static Directory _parseGitHooksDirParameter(final Directory projectDir) {
    final Directory hooksDir = Directory('${projectDir.path}/.git_hooks_tools');

    try {
      if (!hooksDir.existsSync()) {
        hooksDir.createSync();
      }
    } on Exception catch (exception) {
      throw UnrecoverableException(
        'git hooks dir could not be created.\n'
            'System error: ${exception.toString()}',
        exitUnexpectedError,
      );
    }

    return hooksDir;
  }
}

/// Get the project [Directory] with a full path.
Directory getResolvedProjectDir(final String projectDir) {
  return Directory(path.canonicalize(projectDir));
}
