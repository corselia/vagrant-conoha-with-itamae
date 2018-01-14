#!/bin/bash

vagrant up --provider=conoha
itamae ssh --vagrant itamae_recipe.rb --log-level DEBUG

# vagrant ssh-config
# vagrant ssh if ssh port number is 22
# ssh username@domain.name if domain.name is available...
