#!/bin/bash -e
# To run the following scrip from Terminal, simply type the following:
#
#	bash commit.sh "Your commit description"
# or . commit.sh "..."
#
# Note: You must run this from the same directory that the script is in
commit_message="$1"
git config --global push.default simple
git add . -A
git commit -m "$commit_message"
git push