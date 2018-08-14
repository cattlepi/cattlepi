#!/usr/bin/env python
import pystache
import json
import os
import stat
import sys
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("-t", "--template-file", dest="template", 
                    help="template file to fill in", required=True)
parser.add_argument("-p", "--param-file", dest="param",
                    help="parameters to use when filling in the template", required=True)
args = parser.parse_args()

if args.template.endswith('.mustache'):
    output_file = args.template[:-9]
else:
    print("invalid template file name")
    sys.exit(2)

print("Expanding %s using params from %s into %s" % (args.template, args.param, output_file))
pystache.defaults.MISSING_TAGS = 'strict'

with open(args.param) as f:
    params = json.load(f)

with open(output_file, "w") as o:
    with open(args.template) as f:
        o.write(pystache.render(f.read(), params))

current_permissions = stat.S_IMODE(os.lstat(args.template).st_mode)
os.chmod(output_file, current_permissions)

