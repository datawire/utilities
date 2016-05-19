# utilities
Utilities that should be shared across other repos. 

Of notable interest:

## make_installer.py

Takes a template and produces an installer that can be downloaded with

```curl https://url/of/installer | bash```

As arguments, it needs the name of the thing you're installing, the default place to download from, and the default directory to install to. 

A basic installer template is available in `templates/basic.sh`, which knows how to download a zipfile from a URL, how to install from a local directory, and how to run pre- and post-install hooks in the installed bits.

## versioner.py

Reads `git` logs and tags for a project and spits out, on stdout, the semantic-versioning number that should be used for the next build of the project.

Tags denoting versions must be `semver` version numbers with a prepended `v`, e.g. `v0.1.5`, `v1.0.5`, `v1.2.8-4760+arm64v7` or the like. `versioner.py` will complain if it can't find such a tag in the `git` history for the project.

### Developing

Just run `make` to rebuild `install.sh` (which, of course, uses `make_installer.py`), then commit the new `install.sh` to `git` so that it can be found by people running `curl`. That's it.

