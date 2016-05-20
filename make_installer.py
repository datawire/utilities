#!/usr/bin/env python

"""make_installer.py

Create a basic installer

Usage: 
  make_installer.py [options] <packagename> <default-source> <default-destination>

Options:
  --template=<template-url>  Set the URL of the template file we'll start with
  --checkexec=<command>      If command is on the PATH already, don't install
  --modules=<module-list>    Comma-separated list of modules to include (see below)
  --module-dir=<module-dir>  Directory in which to find modules (see below)

packagename: Name of this package (see below)
default-source: URL from which the finished installer should download by default 
default-path: PATH to which the finished installer should install by default

If the packagename matches the GitHub repo of the package, you'll be able to
pass a branch name as an argument to the generated installer to install 
directly from a branch.

The template-url can be a simple path, in which case it is assumed to be local.
If it has no directory component, it is assumed to be in the templates/ directory.

Modules to be included are given as a comma-separated list of module names. They
are assumed to be .sh files if no extension is given. They may be full paths; if
no directory is given for a module, the module is assumed to be in the module-dir
(which defaults to module/).

The default set of inclusions is 

    core,output,checks,install-simple,arguments

and ORDER IS IMPORTANT: core must always be first and arguments must always be last.
More information about the modules can be found by reading them.
"""

import sys

import errno
import os
import requests

from docopt import docopt

#### Mainline

args = docopt(__doc__, version="make_installer {0}".format("0.1.0"))

package_name = args["<packagename>"]
default_source = args["<default-source>"]
default_dest = args["<default-destination>"]
template_url = args["--template"]
include_modules = args["--modules"]
module_dir = args["--module-dir"]

if not template_url:
  template_url="https://raw.githubusercontent.com/datawire/utilities/master/install-template.sh"

if include_modules:
  include_modules = include_modules.split(",")
else:
  include_modules = [ "output", "checks", "core", "install-simple", "arguments" ]

if not module_dir:
  module_dir = "modules"

sys.stderr.write("Package name:   %s\n" % package_name)
sys.stderr.write("Default source: %s\n" % default_source)
sys.stderr.write("Default dest:   %s\n" % default_dest)
sys.stderr.write("Template URL:   %s\n" % template_url)


def interpolate(text):
  result = text.replace('{{{DEFAULT_SOURCE}}}', default_source)
  result = result.replace('{{{PACKAGE_NAME}}}', package_name)
  result = result.replace('{{{DEFAULT_DESTINATION}}}', default_dest)

  return result


# # NOTE the stream=True parameter
# resp = requests.get(template_url, stream=True)

template = None

if template_url.find("://") < 0:
  # Local file.

  try:
    template = open(template_url, "r").read()
  except IOError as err:
    if err.errno == errno.ENOENT:
      sys.stderr.write("%s: no such file\n" % template_url)
      sys.exit(1)
    else:
      raise
else:
  resp = requests.get(template_url)

  if resp.status_code != 200:
    sys.stderr.write("%s: download failed: %s\n" % (template_url, resp.text))
    sys.exit(1)

  template = resp.text

installer = interpolate(template)

start_of_modules = installer.find("{{{MODULES}}}")

if start_of_modules >= 0:
  sys.stdout.write(installer[:start_of_modules])

  for module in include_modules:
    dirname, basename = os.path.split(module)
    modulebase, moduleext = os.path.splitext(basename)

    if not dirname:
      dirname = module_dir

    if not moduleext:
      moduleext = ".sh"

    modulepath = os.path.join(dirname, modulebase + moduleext)

    with open(modulepath, "r") as mod:
      sys.stdout.write("####======== module %s ========\n" % modulebase)
      sys.stdout.write(interpolate(mod.read()))

  sys.stdout.write("####======== modules finished ========\n")

  next_line = installer.find("\n", start_of_modules)

  if next_line > 0:
    sys.stdout.write(installer[next_line:])
else:
  sys.stdout.write(installer)
