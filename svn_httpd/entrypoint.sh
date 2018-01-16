#!/bin/bash
set -e

# Set timezone for container
#if [ ! -z $TZ ]; then
	#echo $TZ > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
#fi

# If no config files in /usr/local/apache2/conf, do init copy.
if [ `ls /usr/local/apache2/conf | wc -l` -eq 0 ]; then
	cp -r /tmp/httpd-conf/* /usr/local/apache2/conf/
fi

# Let's create the basic SVN repos structure
if [ `ls /svn | wc -l` -eq 0 ]; then
	cd /svn
	mkdir repos
	cd repos
	svnadmin create empty
	mkdir /tmp/empty
        echo '#Empty' > /tmp/empty/README.md
	echo 'Nothing to see here. This file is auto-created when a container from svn_httpd is spun up.' >> /tmp/empty/README.md
	svn import /tmp/empty file:///svn/repos/empty -m "auto-creation of the empty project"
	rm -rf /tmp/empty
	cd /svn
	chown -R www-data:www-data repos
	touch /svn/svn-auth-conf
	ln -s /usr/local/sbin/mkrepo.sh /svn/mkrepo.sh
fi

exec "$@"
