#!/bin/bash

/data/phabricator/bin/config set environment.append-paths '["/usr/libexec/git-core", "/bin", "/usr/bin", "/usr/local/bin"]'

/data/phabricator/bin/aphlict debug
