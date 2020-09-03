#!/bin/bash
# Create a github_repo from the command line...so cool (more here: https://developer.github.com/v3/repos/#create)
# I should probably implement some check if the creation was successful
curl -u 'ThomasHaine' https://api.github.com/user/repos -d '{"name":"arctic_ocean_freshwater_synthesis", "private":true}'

# Link local repository to git
git init
git add *
git add .gitignore .stickler.yml .travis.yml
git commit -m 'first commit'
git remote add origin git@github.com:ThomasHaine/arctic_ocean_freshwater_synthesis.git
git push -u origin master
