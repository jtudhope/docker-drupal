# docker Drupal
#
# VERSION       1
# DOCKER-VERSION        1
FROM    centos:centos7
MAINTAINER Jonathan Tudhope <jon.tudhope@gmail.com>

RUN yum update


RUN yum -y install  mariadb-server mariadb httpd php pwgen python-setuptools vim-tiny php-mysql php-apc php-gd php-curl mc tar wget

#install drush
RUN wget --quiet -O - http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz | tar -zxf - -C /usr/local/share
RUN ln -s /usr/local/share/drush/drush /usr/local/bin/drush

#configure EPEL 
RUN wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
RUN rpm -ivh epel-release-7-2.noarch.rpm

# Make mysql listen on the outside
RUN sed -i "s/^bind-address/#bind-address/" /etc/my.cnf

RUN easy_install supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf

# Retrieve drupal
RUN rm -rf /var/www/ ; cd /var ; drush dl drupal ; mv /var/drupal*/ /var/www/
RUN chmod a+w /var/www/sites/default ; mkdir /var/www/sites/default/files ; chown -R apache:apache /var/www/

RUN chmod 755 /start.sh /etc/apache2/foreground.sh
EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
