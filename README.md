# svn_httpd
## Subversion over httpd 

Based loosly on [starlight36's work](https://github.com/starlight36/docker-httpd-subversion), svn_httpd wraps subversion up with Apache and DAV in a Docker container. This makes subversion a bit more proxy-friendly, and wraps all that up in HTTPS with TLSv1.2 (and 1.1).

As configured here, Apache/subversion makes no attempt at limiting checkins to repos to certain/specific users. _ALL_ repos are writable by users that appear in svn-auth-conf (and successfully authenticate, of course). Also, checkouts/browsing is not limited at all. 

#### A few words about HTTPS

The HTTPS certificate is self-signed - to provide your own, replace server.crt and server.key in svn_httpd/things. The self-signed cert will cause subversion clients to warn, of course, but can be easily overridden. For example:

```
$ svn co https://192.168.47.92:8473/repos/empty
Error validating server certificate for 'https://192.168.47.92:8473':
 - The certificate is not issued by a trusted authority. Use the
   fingerprint to validate the certificate manually!
 - The certificate hostname does not match.
Certificate information:
 - Hostname: selfsigned
 - Valid: from Feb 11 15:53:28 2018 GMT until Feb 10 15:53:28 2021 GMT
 - Issuer: US
 - Fingerprint: 47:79:D2:20:07:19:72:20:4A:03:D7:CC:E2:25:70:97:BC:AE:C8:FB
(R)eject, accept (t)emporarily or accept (p)ermanently? p
A    empty/README.md
Checked out revision 3.
```

In the CLI client, svn, chosing "(p)ermanently" will cache the server's details in ~/.subversion/auth/svn.ssl.server. Other clients _should_ have similar behaviours. RTFM for your favourite client to discover how to do that, or bless the container with certs that your client will accept.

The self-signed cert used by the container is located at /docker/svn/tls (/svn/tls within the container) as server.crt and server.key. If you've a cert/key that you'd prefer to use, simply name them appropriately, drop them in /docker/svn/tls and restart the container.

#### Creating users

User accounts are stored in /svn/svn-auth-conf. This is exposed to the host at /docker/svn/svn-auth-conf. The file is used by Apache to authenticate users to satisfy ```Require valid-user``` in httpd-svn.conf. 

To create a user, use htpasswd to update the svn-auth-conf file. This can be done from the container (```docker exec -it svnthing sh```) or the host (if apache2-utils is installed there). Example:

```
# htpasswd -m /svn/svn-auth-conf username
```

htpasswd will prompt for the user's password to create.

Removing a user is easy - simply edit svn-auth-conf and remove the line for the user you want to remove. Remember, there is no authentication required for checkouts by default.

#### Creating repos

Repositories served up by apache2-webdav/mod_dav_svn are stored at /svn/repos (exposed to the host at /docker/svn/repos). I've included a script that will create a repo here - mkrepo.sh. The script is in /usr/local/bin with a symlink at /svn. For consistent results, this should be run within the container:

```
mkrepo.sh reponame
```

It can then be checked out, modified, and checked in normally.

#### Simple use

Recreating the [SVN documentation](http://svnbook.red-bean.com/en/1.4/svn.ref.svn.html) here is very out-of-scope for this project, but my day-to-day workflow with svn looks something like this:

```svn co https://svnthing.somwhere.org:8473/repos/reponame``` - to retrieve the repo for the first time on a workstation

(make edits to whatever's in the repo)

```svn diff``` - (optional) to confirm my edits and have a "final" look at them before committing back to the repo

```svn ci -m "some comments describing the reasons for this commit"``` - committing the changes to the repo with a comment for ```svn log```


If I already have a copy of the repo on my workstation:

```svn update``` - from within the local directory of the repo to pull the latest version

(make edits)

```svn diff```

```svn ci -m "some more comments about this commit"```

