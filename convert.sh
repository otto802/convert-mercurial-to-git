#!/bin/bash

## be sure to understand all the steps before using this!
exit;

## install tools

wget https://search.maven.org/classic/remote_content?g=com.madgag&a=bfg&v=LATEST
wget https://github.com/frej/fast-export/archive/master.zip
unzip fast-export-master.zip


## using fast export to convert hg repo to git
## we rewriting some ugly author names during this step (see authors file)
## for our repo this took about 7h, so added some timing info here
## ../repo_hg is the source repository

date
mkdir repo_git
cd repo_git
git init
git config core.ignoreCase false
time ../fast-export-master/hg-fast-export.sh -r ../repo_hg -A ../authors

## we've got now a git repository in repo_git
## its just not checked out yet (see fast export docs)
## we want to take the chance to do some cleanup

cd repo_git
git checkout HEAD

## delete branches listed in the file branches_delete (mainly the hg "closed" branches)
for i in `cat ../branches_delete`; do
   git branch -D $i
done

## using BFG we get rid of some binary stuff
## Warning: be sure to read and understand https://rtyley.github.io/bfg-repo-cleaner/ befor using this!

java -jar ../bfg-1.13.0.jar --delete-files '*.{PNG,png,jpg,jpeg,JPG,JPEG,PDF,pdf,swf,svg,woff,eot,ttf,gif,csv,eot,gpx,ico,jpg-GD,kml,kmz,tif,wav,woff2,z}' .
git reflog expire --expire=now --all && git gc --prune=now --aggressive

## restart some existing branches (we use them for deployment)
git branch -f production
git branch -f staging

