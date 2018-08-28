#!/usr/bin/env python
import yaml
import sys

from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("-r", "--recipe-file", dest="recipe", 
                    help="recipe file to load", required=True) 
parser.add_argument("-o", "--output-file", dest="output", 
                    help="generate target output", required=True) 
args = parser.parse_args()

with open(args.recipe) as f:
    try:
        my_recipe = yaml.load(f)
    except yaml.YAMLError as exc:
        print(exc)
        sys.exit(2)

try:
    for key in ['version', 'tool', 'template', 'params']:
        if key not in my_recipe:
            raise ValueError('%s field not present in recipe' % key)
    supported = False
    for supported_tool in ['script', 'run_playbook']:
        if my_recipe['tool'] == supported_tool: 
            supported = True
            break
    if my_recipe['tool'] == 'run_playbook':
        if 'playbook' not in my_recipe['params']:
            raise ValueError('playbook field not present in recipe params' % key)
    if my_recipe['tool'] == 'script':
        if 'run' not in my_recipe['params']:
            raise ValueError('run field not present in recipe params' % key)
except ValueError as exc:
    print(exc)
    sys.exit(2)

with open(args.output, "w") as o:
    o.write('export RECIPE_EXPAND_TEMPLATE=yes')
    o.write('export RECIPE_TEMPLATE=$TOPDIR"%s"' % my_recipe['template'])
    if my_recipe['tool'] == 'run_playbook':
        o.write('export RECIPE_CMD="$BUILDDIR/%s"' %s my_recipe['params']['run'])
    if my_recipe['tool'] == 'script':
        o.write('export RECIPE_CMD="$UTILDIR/run_playbook.sh $BUILDDIR hosts %s"' %s my_recipe['params']['playbook'])
