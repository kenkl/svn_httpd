#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

if [[ -z $1 ]]; then
    echo "ERROR: No repository name specified."
    echo "Usage: mkrepo.sh REPONAME"
    exit 1
fi

echo "Creating $1 repository in SVN.."

cd /svn/repos
svnadmin create $1
mkdir /tmp/$1
echo "Autocreation of the $1 repo" > /tmp/$1/README.md
svn import /tmp/$1 file:///svn/repos/$1 -m "Autocreation of $1 repo"
chown -R www-data:www-data /svn/repos/$1
echo "Done. Have fun!"

