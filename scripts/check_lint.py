#!/usr/bin/env python

# Copyright 2019 Google
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Lints source files for conformance with the style guide that applies.

Currently supports linting Objective-C, Objective-C++, C++, and Python source.
"""

import argparse
import logging
import os
import re
import subprocess
import sys
import textwrap

from lib import checker
from lib import trace
from lib import git
from lib import source

_logger = logging.getLogger('lint')


_dry_run = False


_cpplint_objc_filters = [
    # Objective-C uses #import and does not use header guards
    '-build/header_guard',

    # Inline definitions of Objective-C blocks confuse
    '-readability/braces',

    # C-style casts are acceptable in Objective-C++
    '-readability/casting',

    # Objective-C needs use type 'long' for interop between types like NSInteger
    # and printf-style functions.
    '-runtime/int',

    # cpplint is generally confused by Objective-C mixing with C++.
    #   * Objective-C method invocations in a for loop make it think its a
    #     range-for
    #   * Objective-C dictionary literals confuse brace spacing
    #   * Empty category declarations ("@interface Foo ()") look like function
    #     invocations
    '-whitespace',
]

_cpplint_objc_options = [
    # cpplint normally excludes Objective-C++
    '--extensions=h,m,mm',

    # Objective-C style allows longer lines
    '--linelength=100',

    '--filter=' + ','.join(_cpplint_objc_filters),
]


def main():
  global _dry_run

  parser = argparse.ArgumentParser(description='Lint source files.')
  parser.add_argument('--dry-run', '-n', action='store_true',
                      help='Show what the linter would do without doing it')
  parser.add_argument('--all', action='store_true',
                      help='run the linter over all known sources')
  parser.add_argument('rev_or_files', nargs='*',
                      help='A single revision that specifies a point in time '
                           'from which to look for changes. Defaults to '
                           'origin/master. Alternatively, a list of specific '
                           'files or git pathspecs to lint.')
  args = trace.parse_args(parser)

  if args.dry_run:
    _dry_run = True
    trace.trace_commands()

  pool = checker.Pool()

  sources = _unique(source.CC_DIRS + source.OBJC_DIRS + source.PYTHON_DIRS)
  patterns = git.make_patterns(sources)

  files = git.find_changed_or_files(args.all, args.rev_or_files, patterns)
  check(pool, files)

  pool.exit()


def check(pool, files):
  group = source.categorize_files(files)

  for kind, files in group.kinds.items():
    for chunk in checker.shard(files):
      if not chunk:
        continue

      linter = _linters[kind]
      pool.submit(linter, chunk)


def lint_cc(files):
  return _run_cpplint([], files)


def lint_objc(files):
  return _run_cpplint(_cpplint_objc_options, files)


def _run_cpplint(options, files):
  scripts_dir = os.path.dirname(os.path.abspath(__file__))
  cpplint = os.path.join(scripts_dir, 'cpplint.py')

  command = [sys.executable, cpplint, '--quiet']
  command.extend(options)
  command.extend(files)

  return _read_output(command)


_flake8_warned = False


def lint_py(files):
  flake8 = which('flake8')
  if flake8 is None:
    global _flake8_warned
    if not _flake8_warned:
      _flake8_warned = True
      _logger.warn(textwrap.dedent(
          """
          Could not find flake8 on the path; skipping python lint.
          Install with:

            pip install --user flake8
          """))
    return

  command = [sys.executable, flake8]
  command.extend(files)

  return _read_output(command)


def _read_output(command):
  trace.command(command)

  if _dry_run:
    return 0

  proc = subprocess.Popen(
      command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  output = proc.communicate('')[0]
  sc = proc.wait()

  return checker.Result(sc, output)


_linters = {
    'cc': lint_cc,
    'objc': lint_objc,
    'py': lint_py,
}


def _unique(items):
  seen = set()
  result = []
  for item in items:
    if item not in seen:
      seen.add(item)
      result.append(item)
  return result


def make_path():
  path = os.environ['PATH'].split(os.pathsep)

  lib_pattern = re.compile(r'(.*)/lib/')
  for entry in sys.path:
    m = lib_pattern.match(entry)
    if m:
      bindir = os.path.join(m.group(1), 'bin')
      if bindir not in path and os.path.exists(bindir):
        path.append(bindir)

  return path


_PATH = make_path()


def which(executable):
  if executable.startswith('/'):
    return executable

  for entry in _PATH:
    joined = os.path.join(entry, executable)
    if os.path.isfile(joined):
      return joined

  return None


if __name__ == '__main__':
  main()
