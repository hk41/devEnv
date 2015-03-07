#
# Cookbook Name:: db
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#node['db']['rpms'].each do |rpms|
#  cookbook_file "/tmp/#{rpms['rpm_package_name']}" do
#    source rpms['rpm_package_name']
#    #checksum rpms['rpm_package_checksum']
#  end
#end
#
## package リソースで attribute 設定した順にインストールされていきます
#node['db']['rpms'].each do |rpms|
#  package rpms['rpm_package_name'] do
#    action :install
#    provider Chef::Provider::Package::Rpm
#    source "/tmp/#{rpms['rpm_package_name']}"
#  end
#end

# --------------------------------------------------
# set /etc/my.cnf
# --------------------------------------------------
template '/etc/my.cnf' do
  owner 'root'
  group 'root'
  mode 644
  notifies :restart, "service[mysqld]"
end

# --------------------------------------------------
# MySQL 5.5.38 installation
# --------------------------------------------------
# dependencies
#%w[perl-DBD-MySQL perl-DBI].each do |pkg|
%w[libaio libaio-devel openssl-devel perl-DBD-MySQL perl-DBI].each do |pkg|

  package pkg do
    action :install
  end
end

# install mysql from remi repo
#%w[mysql51 mysql51-server mysql51-devel].each do |pkg|
%w[mysql mysql-server mysql-devel].each do |pkg|
  package pkg do
    action :install
    #options "--enablerepo=base --disablerepo=remi,epel,updates"
    #options "--disablerepo=base,updates,remi,epel"
  end
end

#--------------------------------------------------
# log files
#--------------------------------------------------
# create directories for mysql log files.
mysql_log_dir = '/var/log/mysql'

directory mysql_log_dir do
  owner "mysql"
  group "mysql"
  mode "0755"
  action :create
end

# touch log files
%w[
  error
  slow
  query
].each do |log_name|
  bash "create_#{log_name}_log" do
    log_file = "#{mysql_log_dir}/#{log_name}.log"
    code <<-EOC
      touch #{log_file}
    EOC
    creates log_file
  end
end

#--------------------------------------------------
# log rotation
#--------------------------------------------------
# ref: /etc/logrotate.d/mysqld
template '/root/.my.cnf' do
  owner "root"
  group "root"
  mode 0600
end

# logrotate
cookbook_file '/etc/logrotate.d/mysql-log-rotate' do
  owner "root"
  group "root"
  mode 0644
end

#--------------------------------------------------
# set service
#--------------------------------------------------
# chkconifig on and start
service "mysqld" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable , :start ]
end

#--------------------------------------------------
# mysql_secure_installation 5.5
#--------------------------------------------------
# 4. Set root password? [Y/n] Y
# 1. Remove anonymous users? [Y/n] Y
# 3. Disallow root login remotely? [Y/n] Y
# 2. Remove test database and access to it? [Y/n] Y
# 5. Reload privilege tables now? [Y/n] Y

root_password = node.set['mysql_user']['root']['password']
bash "mysql_secure_installation" do
  code <<-EOC
    mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -e "DROP DATABASE test;"
    mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('#{root_password}');" -D mysql
    mysql -u root -p#{root_password} -e "SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('#{root_password}');" -D mysql
    mysql -u root -p#{root_password} -e "SET PASSWORD FOR 'root'@'::1' = PASSWORD('#{root_password}');" -D mysql
    mysql -u root -p#{root_password} -e "FLUSH PRIVILEGES;"
  EOC
  only_if "mysql -u root -e 'show databases'"
end
