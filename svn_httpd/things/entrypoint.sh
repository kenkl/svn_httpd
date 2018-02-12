#!/bin/bash
set -e

# If no config files in /usr/local/apache2/conf, do init copy.
if [ `ls /usr/local/apache2/conf | wc -l` -eq 0 ]; then
	cp -r /tmp/httpd-conf/* /usr/local/apache2/conf/
fi

# Let's create the basic SVN repos structure and place some things if they don't alredy exist
if [ `ls /svn | wc -l` -eq 0 ]; then
	cd /svn
	mkdir repos
	cd repos
	svnadmin create empty
	mkdir /tmp/empty
        echo '#Empty' > /tmp/empty/README.md
	svn import /tmp/empty file:///svn/repos/empty -m "auto-creation of the empty project"
	rm -rf /tmp/empty
	cd /svn
	chown -R www-data:www-data repos
	touch /svn/svn-auth-conf
	ln -s /usr/local/bin/mkrepo.sh /svn/mkrepo.sh
        mkdir tls
        cp /tmp/server.crt ./tls
        cp /tmp/server.key ./tls
fi

exec "$@"
