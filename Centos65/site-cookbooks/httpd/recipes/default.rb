#
# Cookbook Name:: httpd
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "httpd" do
  action :install
end

# httpd起動
service "httpd" do
  action [ :enable, :start ]
end

# 設定ファイルの設置
template "httpd.conf" do
  path "/etc/httpd/httpd.conf"
  owner "root"
  group "root"
  mode 0644

  # ファイルが更新されたらサービスをリロード
  notifies :reload, 'service[httpd]'
end

