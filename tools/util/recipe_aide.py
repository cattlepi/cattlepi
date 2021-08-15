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
        my_recipe = yaml.safe_load(f)
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
    recipes_to_include = []
    # the include logic - we will prepare the invocation
    if 'include' in my_recipe:
        for inc_recipe in my_recipe['include']:
            for key in ['version', 'name']:
                if key not in inc_recipe:
                    raise ValueError('%s field not present in include %s' % (key, inc_recipe))
            recipes_to_include.append(inc_recipe['name'])
    if len(recipes_to_include) > 0:
        o.write('export RECIPE_INCLUDES=(%s)\n' % ' '.join(recipes_to_include))

    # other instructions
    o.write('export RECIPE_EXPAND_TEMPLATE=yes\n')
    o.write('export RECIPE_TEMPLATE=$TOPDIR"%s"\n' % my_recipe['template'])
    if my_recipe['tool'] == 'script':
        o.write('export RECIPE_CMD="$BUILDDIR/%s"\n' % my_recipe['params']['run'])
    if my_recipe['tool'] == 'run_playbook':
        o.write('export RECIPE_CMD="$UTILDIR/run_playbook.sh $BUILDDIR hosts %s"\n' % my_recipe['params']['playbook'])
