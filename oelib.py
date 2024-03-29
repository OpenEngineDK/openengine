#!/usr/bin/env python
# -------------------------------------------------------------------
# Helper functions for dist.py and make.py
# -------------------------------------------------------------------
# Copyright (C) 2007 OpenEngine.dk (See AUTHORS)
#
# This program is free software; It is covered by the GNU General
# Public License version 2 or any later version.
# See the GNU General Public License for more details (see LICENSE).
#--------------------------------------------------------------------

import string, sys, platform, subprocess, os, os.path as path
import urllib.request, urllib.parse, urllib.error, urllib.request, urllib.error, urllib.parse, zipfile, tarfile
import errno    

def deleteFolder(folder):
    '''
    Deletes a folder at the path of folder
    '''
    if system("win"):
        execute("rmdir /S /Q %s" % folder) 
    else:
        execute("rm -r %s" % folder)

def mkdirp(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

def createFolders():
    mkdirp('dependencies')
    mkdirp('extensions')
    mkdirp('libraries')
    mkdirp('projects')

class ExecError(Exception):
    "Exception thrown if execute(cmd) exited with error code != 0"

def printCommands(cmds):
    print(("\n".join([f.__doc__.strip() for f,c in cmds])))

def execute(cmd):
    '''
    Execute system command
    '''
    proc = subprocess.Popen(cmd, shell=True)
    proc.wait()
    if proc.returncode != 0:
        raise ExecError("%s exited with error code %i\n"
                        % (cmd, proc.returncode))

def error(err):
    '''
    Print error message, and exit
    '''
    print(err)
    sys.exit(1)

def system(name):
    '''
    Returns true if name==any, or if name matches the system platform.
    '''
    if name == "any":
        return True
    if sys.platform.startswith("linux") and name.startswith("linux"):
        if name ==  "linux64":
            return platform.machine() == "x86_64"
        elif name == "linux32":
            return platform.machine() != "x86_64"
        else:
            return True
    else:
        return sys.platform.startswith(name)

def cores():
    '''
    Returns the number of CPUs in the system
    Source: http://pyprocessing.berlios.de/
    '''
    try:
        count = 0
        if system("linux"):
            count = os.sysconf('SC_NPROCESSORS_ONLN')
        elif system("darwin"):
            count = int(os.popen('sysctl -n hw.ncpu').read())
        elif system("win"):
            count = int(os.environ['NUMBER_OF_PROCESSORS'])
        return max(count, 1)
    # if an error occurs simply return one
    except Exception: pass
    return 1
