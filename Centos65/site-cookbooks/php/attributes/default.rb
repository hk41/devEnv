default['php']['directives'] = { "date.timezone" => "Asia/Tokyo" }

case node["platform_family"]
when "rhel", "fedora"
  if node['platform_version'].to_f < 6 then
    default['php']['packages'] = ['php53', 'php53-devel', 'php53-cli', 'php53-mbstring', 'php-pear']
    default['php']['package_options'] = "--disablerepo=remi,epel"
  else
    default['php']['packages'] = ['php', 'php-devel', 'php-cli', 'php-mbstring', 'php-pear']
    default['php']['package_options'] = "--disablerepo=remi,epel"
  end
end

