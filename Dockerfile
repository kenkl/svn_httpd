#FROM httpd
FROM httpd:alpine

#RUN apt-get update \
	#&& apt-get install -y subversion libapache2-svn \
	#&& rm -r /var/lib/apt/lists/*
RUN apk --no-cache add apache2 apache2-utils apache2-webdav mod_dav_svn subversion

RUN sed -i 's|#LoadModule dav_module|LoadModule dav_module|g' /usr/local/apache2/conf/httpd.conf \
	&& sed -i 's|#Include conf/extra/httpd-default.conf$|&\n\nInclude conf/extra/httpd-svn.conf|' /usr/local/apache2/conf/httpd.conf \
        && sed -i 's/User\ daemon/User\ www-data/g' /usr/local/apache2/conf/httpd.conf \
        && sed -i 's/Group\ daemon/Group\ www-data/g' /usr/local/apache2/conf/httpd.conf

COPY httpd-svn.conf /usr/local/apache2/conf/extra/httpd-svn.conf
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh

RUN cp -r /usr/local/apache2/conf /tmp/httpd-conf \
#&& cp /usr/lib/apache2/modules/*svn* /usr/local/apache2/modules \
&& cp /usr/lib/apache2/*svn* /usr/local/apache2/modules \
&& chmod +x /usr/local/sbin/entrypoint.sh

VOLUME /svn
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
EXPOSE 80
CMD ["httpd-foreground"]
