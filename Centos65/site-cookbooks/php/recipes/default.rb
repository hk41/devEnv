#
# Cookbook Name:: php
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "php"

# install the xdebug pecl
#php_pear "xdebug" do
#  # Specify that xdebug.so must be loaded as a zend extension
#  zend_extensions ['xdebug.so']
#  action :install
#end

# install the xdebug pecl
#php_pear "imagick" do
#  action :install
#end
