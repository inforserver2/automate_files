server "0.0.0.0", :web, :app, :db, primary: true

set :plat, "i386" # [i386,amd64]

set :user, "root"
set :application, "blog"
set :deploy_to, "/root/pack"
set :use_sudo, false
set :folder, "~/pack"
set :hostname, "server"
set :domain, "domain.net"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

task :basics do
  run "sudo apt-get -y update"
  run "sudo apt-get -y upgrade"
  run "apt-get -y install ntp ntpdate"
  run "apt-get -y install ssh openssh-server"
  run "apt-get -y install lynx libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev build-essential"
  run "apt-get -y install  nmap tree unzip unrar bind9 dnsutils apache2 libcurl4-openssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev sqlite3 mysql-client"
  run 'echo "mysql-server mysql-server/root_password password {senha}" | debconf-set-selections; echo "mysql-server mysql-server/root_password_again password {senha}" | debconf-set-selections; sudo apt-get -y install mysql-server'
  run "sudo apt-get -y install postgresql libpq-dev" # need configure see attach url
  # sudo apt-get -y install pgadmin3 #needs X-11
  run "sudo apt-get -y install libxslt-dev libxml2-dev"
  # install rails
  run "sudo apt-get -y install ruby1.9.3"
  # http://www.compilando.org/wp/sem-categoria/resolva-o-erro-add-apt-repository-command-not-found-no-ubuntu-natty-11-04
  run "sudo apt-get -y install python-software-properties"
  # PHP
  # http://www.inoweb.com.br/site/blog/7-instalando-apache-php-mysql-phpmyadmin-ubuntu-12
  run "sudo apt-get -y install php5 libapache2-mod-php5"
  run "sudo apt-get -y install php5-mysql php5-curl php5-gd php5-idn php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-mhash php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-json php5-pgsql"
  # JAVA
  # http://www.ubuntudicas.com.br/blog/2012/04/instale-o-oracle-java-jdk-7-no-ubuntu-12-04-e-11-10/
  run "sudo add-apt-repository -y ppa:webupd8team/java"
  #-
  run "sudo apt-get -y update"
  run "sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections"
  run "sudo apt-get -y install oracle-java7-installer"
  run "sudo apt-get -y install aspell libevent-dev libgmp10 libgmp-dev curl libfile-next-perl"
  # http://hantys.blogspot.com.br/2012/04/instalando-imagemagick-ubuntu-1204.html
  run "sudo apt-get -y install libperl-dev"
  run "sudo apt-get -y install libmagickwand-dev"
  run "sudo apt-get -y install libmagickcore-dev libmagick++-dev"
  # via repository
  run "sudo apt-get -y install imagemagick"
  run "sudo apt-get -y install memcached"
  # https://www.digitalocean.com/community/articles/how-to-install-git-on-ubuntu-12-04
  run "sudo apt-get -y install git git-core"
  run "sudo apt-get -y install perl libnet-ssleay-perl libauthen-pam-perl libpam-runtime openssl libio-pty-perl apt-show-versions python"
end


task :step2 do
  run 'mkdir -p ~/pack; cd ~/pack; if [ ! -d ~/pack/automate_files ]; then git clone git://github.com/inforserver2/automate_files.git; fi'
  run "#{folder}/automate_files/webmin_load_src"
  run "#{folder}/automate_files/git_completion_setup"
  run "cd #{folder}; wget http://www.webmin.com/jcameron-key.asc; sudo apt-key add jcameron-key.asc; sudo rm -rf jcameron-key.asc*"
  run "sudo apt-get -y update"
  run "sudo apt-get -y install webmin"
  # Install Sphinx
  run "#{folder}/automate_files/sphinx_install #{plat}"
end

task :keygen do
  run "ssh-keygen -t rsa -q -N '' -f ~/.ssh/id_rsa "
end


task :vim do
  run "sudo apt-get -y install exuberant-ctags ncurses-term ack ncurses-dev"
  # compile vim if wants CommandT
  run "#{folder}/automate_files/compile_vim"
  # install vim normally
  # run "apt-get -y install vim vim-nox vim-gtk"
  run "#{folder}/automate_files/load_vimfiles"
  run "#{folder}/automate_files/personal_vim"
  run "#{folder}/automate_files/command_t_install"
end


task :pear do
  # perl-extensions
  run "pear channel-discover pear.horde.org"
  run "pear channel-update pear.horde.org"
  run "pear install Horde/Horde_Yaml-beta"
end

task :rails do

  # Update rubygems
  run "( ! gem list | grep rubygems-update ) && (gem install rubygems-update && update_rubygems) || echo already installed!"

  # install ruby on rails and utilities
  run "( ! gem list | grep rails ) && gem install rails || echo already installed!"
  run "( ! gem list | grep whenever ) && gem install whenever || echo already installed!"
  run "( ! gem list | grep annotate ) && gem install annotate || echo already installed!"
  run "( ! gem list | grep astrails-safe ) && gem install astrails-safe || echo already installed!"
  run "( ! gem list | grep delayed_job ) && gem install delayed_job || echo already installed!"
  run "( ! gem list | grep therubyracer ) && gem install therubyracer || echo already installed!"
  run "( ! gem list | grep pg ) && gem install pg || echo already installed!"
  run "( ! gem list | grep mysql2 ) && gem install mysql2 || echo already installed!"
  run "( ! gem list | grep rmagick ) && gem install rmagick || echo already installed!"
  run "( ! gem list | grep sqlite3 ) && gem install sqlite3 || echo already installed!"
  run "( ! gem list | grep carrierwave ) && gem install carrierwave || echo already installed!"
  run "( ! gem list | grep rspec ) && gem install rspec || echo already installed!"
  run "( ! gem list | grep sass ) && gem install sass || echo already installed!"

  # setup passenger
  run "( ! gem list | grep passenger ) && gem install passenger || echo already installed!"
  run "#{folder}/automate_files/passenger_config"
end

task :php_modules do
  run "#{folder}/automate_files/setup_ioncube_zend #{plat}"

    # PHPMYADMIN
    #cd ~/pack
    #wget http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/3.5.2.2/phpMyAdmin-3.5.2.2-english.tar.gz
    #tar -zxvf phpMyAdmin-3.5.2.2-english.tar.gz
    #cp -rf phpMyAdmin-3.5.2.2-english /var/www/tools/phpMyAdmin
    # OR
  run 'echo "phpmyadmin phpmyadmin/app-password-confirm password" | debconf-set-selections; echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections; echo "phpmyadmin phpmyadmin/mysql/admin-pass password {senha}" | debconf-set-selections; echo "phpmyadmin phpmyadmin/mysql/app-pass password" | debconf-set-selections; echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections; sudo apt-get install phpmyadmin -y'

    # PHPPGADMIN
    # config at http://www.vivaolinux.com.br/dica/Instalacao-e-configuracao-do-PostgreSQL-e-phpPgAdmin-no-Debian
    # cd ~/pack
    # wget http://downloads.sourceforge.net/phppgadmin/phpPgAdmin-5.0.4.tar.gz
    # tar -zxvf phpPgAdmin-5.0.4.tar.gz
    # cp -rf phpPgAdmin-5.0.4 /var/www/tools/phpPgAdmin
    # OR
  run "sudo apt-get -y install phppgadmin"

  run 'sed -i "s#_security[\']] = true#_security\'] = false#g" /etc/phppgadmin/config.inc.php'
  run "sed -i 's/^# allow from all/ allow from all/' /etc/phppgadmin/apache.conf"
  run "sudo -u postgres  psql -d postgres -U postgres -c \"ALTER USER postgres WITH PASSWORD '{senha}';\" "
  run "service apache2 restart"

end

task :js do
  # node.js
  #cd /root/pack
  #wget http://nodejs.org/dist/v0.8.11/node-v0.8.11.tar.gz
  #tar -zxvf node-v0.8.11.tar.gz
  #cd node-v0.8.11
  #./configure && make && make install
  # or
  run "sudo apt-get -y install nodejs"

  # cofee-script
  run "sudo apt-get -y install npm"
  run "npm install -g http://github.com/jashkenas/coffee-script/tarball/master"
end

task :cfg do
  run "#{folder}/automate_files/set_hostname #{hostname} #{domain}"
  run "echo nameserver 127.0.0.1 > /etc/resolv.conf"
  # then setup dns for the domain
  # create virtual domains
  # adduser username
end

task :adjusts do
    # dpkg -s ?
    # dpkg --purge ...
    # apt-get clean
    # sed -n 'Np' file
    # MAIL=~/Maildir
end

task :mail do
    run 'sudo DEBIAN_FRONTEND=noninteractive apt-get -y install postfix'
    run "rm -rf /etc/postfix/main.cf"
    run "sudo apt-get install -y sasl2-bin"
    run "sudo apt-get -y install dovecot-common dovecot-pop3d dovecot-imapd"
    run "sudo apt-get -y install clamav-daemon amavisd-new spamassassin"
    run "sudo apt-get -y install pflogsumm"
    run "sudo apt-get -y install mailutils"
    run "sudo apt-get -y install opendkim"
    run "#{folder}/automate_files/mail/postfix_conf"
    run "#{folder}/automate_files/mail/dovecot_conf"
    run "#{folder}/automate_files/mail/ssl_conf"
    run "#{folder}/automate_files/mail/virtual_conf"
    run "#{folder}/automate_files/mail/clamav"
    run "#{folder}/automate_files/mail/opendkim_install"
    # automate_files/mail/dkim_add #{domain}"
end

task :prepare do
  basics
  step2
  keygen
  vim
  pear
  rails
  php_modules
  js
  mail
  cfg
end