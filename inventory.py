#!usr/bin/python3

import subprocess
import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--list', action='store_true')
parser.add_argument('--host', type=str)
args = parser.parse_args()

out = subprocess.run(['terraform', '-chdir=tf', 'state', 'pull'], capture_output=True, text=True)
state = json.loads(out.stdout)

#print(state)
#exit(1)

#state = {}
#with open('statefile') as json_file:
#  state = json.load(json_file)

server_resources = [x for x in state['resources'] if x['type'] == 'hcloud_server']

instances = []
for resource in server_resources:
  for instance in resource['instances']:
    instances.append(instance)

inventory = {
  '_meta': {
    'hostvars': {}
  },
  'all': {
    'hosts': [],
  },
}

# transform instances to ansible inventory hosts
for instance in instances:
  attrs = instance['attributes']
  name = attrs['name']

  inventory['_meta']['hostvars'][name] = {
    'ansible_host': attrs['ipv4_address']
  }
 
  inventory['all']['hosts'].append(name)
  groups = attrs['labels']['roles'].split('-')

  for entry in groups:
    subgroups = entry.split('.')
    for i in range(len(subgroups)):
      group = subgroups[i]
      if group not in inventory:
        inventory[group] = {'hosts':[],'children':[]}
      
      inventory[group]['hosts'].append(name)
      
      # if last entry then we have no further subgroups
      if i == len(subgroups) - 1:
        break

      nxt = subgroups[i + 1]
      if nxt not in inventory[group]['children']:
        inventory[group]['children'].append(nxt)

if args.list:
  print(json.dumps(inventory))
elif args.host:
  print(json.dumps(inventory['_meta']['hostvars'][args.host]))
