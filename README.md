# vcshooks

A vcs hooks tool for dart, flutter and other languages.

## Overview

A command-line tool that help you setup vcs hooks check for a project.

It's help you automate your code style check, tests result, branch naming and more before executing a code commit.

[license](https://github.com/bitsydarel/vcshooks/blob/master/LICENSE).

<br>

## Installation

For usage everywhere in the system.

```bash
pub global activate vcshooks
```

For usage only in the current package.

```bash
pub activate vcshooks
```

<br>

<br>

## Usage

```bash
vcshooks --project-type [project type] [local project directory]
```

Options:
--project-type Specify the type of project the script is run on
[dart] (default)             Static analytics for dart project
[flutter]                    Static analytics for flutter project

--commit-message-rule Specify the commit message rule (defaults to "^(?=[\w]).*")

--branch-naming-rule Specify the branch naming rule (defaults to "(^(?=[feature\/|release\/|hotfix\/][a-z\d]
+[-\/_\.]*[a-z\d]*)(?!.*[\@ ]).*)|^(?=(develop|master|main)$).*")

--[no-]code-style-check-enabled Enable code style check on pre-commit (defaults to on)

--[no-]unit-tests-Enabled Enable unit tests on pre-commit (defaults to on)

--[no-]help Print help message

<br>

<br>

## Example

Setup vcs hooks for a dart/flutter the project.

```bash
vcshooks --project-type [dart/flutter] [project dir]
```

Setup vcs hooks with a different commit message rule

```bash
vcshooks --project-type dart --commit-message-rule "^(?=[\@]).*" [project dir]
```

Setup vcs hooks with a different branch naming rule

```bash
vcshooks --project-type dart --branch-naming-rule "^(?=[master,develop,beta,dev]).*" [project dir]
```

Setup vcs hooks with code style check disabled on pre-commit

```bash
vcshooks --project-type dart --no-code-style-check-enabled [project dir]
```

Setup vcs hooks with unit tests disabled on pre-commit

```bash
vcshooks --project-type dart --no-unit-tests-enabled [project dir]
```

<br>