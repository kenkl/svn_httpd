FROM httpd

ENV SVN_PREFIX /usr/lib/apache2/modules
#RUN mkdir -p "$SVN_PREFIX" 
WORKDIR $SVN_PREFIX


RUN apt-get update \
	&& apt-get install -y libsqlite3-0 libaprutil1-ldap subversion libapache2-svn \
	&& rm -r /var/lib/apt/lists/*

ENV SVN_VERSION 1.9.2
#ENV SVN_BZ2_URL http://mirrors.cnnic.cn/apache/subversion/subversion-$SVN_VERSION.tar.bz2

RUN sed -i 's|#LoadModule dav_module|LoadModule dav_module|g' /usr/local/apache2/conf/httpd.conf \
	&& sed -i 's|#Include conf/extra/httpd-default.conf$|&\n\nInclude conf/extra/httpd-svn.conf|' /usr/local/apache2/conf/httpd.conf
	#&& echo "LoadModule dav_svn_module $SVN_PREFIX/mod_dav_svn.so" >> /usr/local/apache2/conf/extra/httpd-svn.conf \
	#&& echo "LoadModule authz_svn_module $SVN_PREFIX/mod_authz_svn.so" >> /usr/local/apache2/conf/extra/httpd-svn.conf

WORKDIR $HTTPD_PREFIX


COPY httpd-svn.conf /usr/local/apache2/conf/extra/httpd-svn.conf
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh

RUN cp -r /usr/local/apache2/conf /tmp/httpd-conf \
&& cp /usr/lib/apache2/modules/*svn* /usr/local/apache2/modules \
&& chmod +x /usr/local/sbin/entrypoint.sh

VOLUME /svn
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
EXPOSE 80
CMD ["httpd-foreground"]
