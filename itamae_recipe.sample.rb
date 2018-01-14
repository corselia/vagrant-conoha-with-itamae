execute 'basic_setup' do
  command %Q(
    yum update -y;
    yum install -y vim git wget curl tig zsh;
  )
end

$username           = 'foobar'
$root_password      = 'hogehoge'
$conoha_ip_address  = run_command(%Q(curl inet-ip.info;)).stdout.chomp

# 早めに反映をさせる
execute 'set_value_domain_ddns' do
  conoha_domain_name    = 'domain.name'
  conoha_subdomain_name = 'subdomain-name'
  conoha_ddns_password  = 'fugafuga'
  conoha_ip_address     = $conoha_ip_address

  value_domain_access_uri = %Q(https://dyn.value-domain.com/cgi-bin/dyn.fcg?d=#{conoha_domain_name}&p=#{conoha_ddns_password}&h=#{conoha_subdomain_name}&i=#{conoha_ip_address})

  command %Q(
    curl --get "#{value_domain_access_uri}";
  )
end

execute 'add_zsh_to_shells_list' do
  command %Q(
    sed -e '$ a /usr/bin/zsh' -i /etc/shells;
  )
end

# SSH ログイン画面を華やかにする（設定）
execute 'be_beautiful_ssh_login_screen' do
  command %Q(
    sudo /usr/bin/wget --no-check-certificate -O /usr/local/bin/screenfetch https://raw.githubusercontent.com/KittyKatt/screenFetch/master/screenfetch-dev;
    sudo /usr/bin/chmod 755 /usr/local/bin/screenfetch;
    sudo /usr/bin/wget --no-check-certificate -P /usr/local/bin/ https://gist.github.com/ysaotome/5997652/raw/fecdf757b348debfcdd866df00f6d567ff749623/update_motd_by_screenfetch.sh;
    sudo /usr/bin/chmod 755 /usr/local/bin/update_motd_by_screenfetch.sh;
    sudo /usr/local/bin/update_motd_by_screenfetch.sh;
  )
end

# SSH ログイン画面を華やかにする（定期情報更新）
execute 'create_update_motd_cron' do
  command %Q(
    sudo /usr/bin/touch /etc/cron.d/update_motd;
    sudo /usr/bin/chmod 666 /etc/cron.d/update_motd;
    sudo /usr/bin/echo "*/5 * * * * root /usr/local/bin/update_motd_by_screenfetch.sh" > /etc/cron.d/update_motd;
    sudo /usr/bin/chmod 644 /etc/cron.d/update_motd;
  )
end

execute 'change_hostname' do
  command %Q(
    echo my_hostname > /etc/hostname;
  )
end

package 'squid' do
  action :install
end

remote_file '/etc/squid/squid.conf' do
  owner 'root'
  group 'root'
  source 'squid.conf'
end

execute 'open_squid_port_number' do
  command %Q(
    firewall-cmd --add-port=3128/tcp --zone=public --permanent;
    firewall-cmd --reload;
  )
end

execute 'restart_squid' do
  command %Q(
    systemctl restart squid;
  )
end
