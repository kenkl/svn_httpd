FROM httpd:2.4.35-alpine

COPY things/* /tmp/

RUN apk --no-cache add apache2 apache2-utils apache2-webdav mod_dav_svn subversion tzdata \
        && sed -i 's|#LoadModule dav_module|LoadModule dav_module|g' /usr/local/apache2/conf/httpd.conf \
	&& sed -i 's|#Include conf/extra/httpd-default.conf$|&\n\nInclude conf/extra/httpd-svn.conf|' /usr/local/apache2/conf/httpd.conf \
        && sed -i 's|#LoadModule ssl_module|LoadModule ssl_module|g' /usr/local/apache2/conf/httpd.conf \
        && sed -i 's|#Include conf/extra/httpd-ssl.conf|Include conf/extra/httpd-ssl.conf|g' /usr/local/apache2/conf/httpd.conf \
        && sed -i 's/User\ daemon/User\ www-data/g' /usr/local/apache2/conf/httpd.conf \
        && sed -i 's/Group\ daemon/Group\ www-data/g' /usr/local/apache2/conf/httpd.conf \
        && cp /tmp/httpd-svn.conf /usr/local/apache2/conf/extra \
        && cp /tmp/httpd-ssl.conf /usr/local/apache2/conf/extra \
        && cp /tmp/entrypoint.sh /usr/local/bin \
        && cp /tmp/mkrepo.sh /usr/local/bin \
        && cp /tmp/index.html /usr/local/apache2/htdocs \
        && cp -r /usr/local/apache2/conf /tmp/httpd-conf \
        && cp /usr/lib/apache2/*svn* /usr/local/apache2/modules \
        && chmod 755 /usr/local/bin/entrypoint.sh \
        && chmod 755 /usr/local/bin/mkrepo.sh

VOLUME /svn
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EXPOSE 80 443
CMD ["httpd-foreground"]
