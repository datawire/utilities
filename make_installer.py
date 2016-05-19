#!/usr/bin/env python

"""make_installer.py

Create a basic installer

Usage: 
  make_installer.py [--template=<template-url>] <packagename> <default-source> <default-destination>

template-url: URL of the template file from which we'll synthesize the installer
default-source: URL from which the finished installer should download by default 
default-path: PATH to which the finished installer should install by default
"""

import sys

import errno
import requests

from docopt import docopt

args = docopt(__doc__, version="make_installer {0}".format("0.1.0"))

package_name = args["<packagename>"]
default_source = args["<default-source>"]
default_dest = args["<default-destination>"]
template_url = args["--template"]

if not template_url:
  template_url="https://raw.githubusercontent.com/datawire/utilities/master/install-template.sh"

sys.stderr.write("Package name:   %s\n" % package_name)
sys.stderr.write("Default source: %s\n" % default_source)
sys.stderr.write("Default dest:   %s\n" % default_dest)
sys.stderr.write("Template URL:   %s\n" % template_url)

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

installer = template.replace('{{{DEFAULT_SOURCE}}}', default_source)
installer = installer.replace('{{{PACKAGE_NAME}}}', package_name)
installer = installer.replace('{{{DEFAULT_DESTINATION}}}', default_dest)

sys.stdout.write(installer)
