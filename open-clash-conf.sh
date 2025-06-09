#!/bin/sh
. /usr/share/openclash/ruby.sh
. /usr/share/openclash/log.sh
. /lib/functions.sh

# This script is called by /etc/init.d/openclash
# Add your custom overwrite scripts here, they will be take effict after the OpenClash own srcipts

LOG_OUT "Tip: Start Running Custom Overwrite Scripts..."
LOGTIME=$(echo $(date "+%Y-%m-%d %H:%M:%S"))
LOG_FILE="/tmp/openclash.log"
CONFIG_FILE="$1" #config path

#Simple Demo:
    #General Demo
    #1--config path
    #2--key name
    #3--value
    #ruby_edit "$CONFIG_FILE" "['redir-port']" "7892"
    #ruby_edit "$CONFIG_FILE" "['secret']" "123456"
    #ruby_edit "$CONFIG_FILE" "['dns']['enable']" "true"

    #Hash Demo
    #1--config path
    #2--key name
    #3--hash type value
    #ruby_edit "$CONFIG_FILE" "['experimental']" "{'sniff-tls-sni'=>true}"
    #ruby_edit "$CONFIG_FILE" "['sniffer']" "{'sniffing'=>['tls','http']}"

    #Array Demo:
    #1--config path
    #2--key name
    #3--position(start from 0, end with -1)
    #4--value
    #ruby_arr_insert "$CONFIG_FILE" "['dns']['nameserver']" "0" "114.114.114.114"

    #Array Add From Yaml File Demo:
    #1--config path
    #2--key name
    #3--position(start from 0, end with -1)
    #4--value file path
    #5--value key name in #4 file
    #ruby_arr_add_file "$CONFIG_FILE" "['dns']['fallback-filter']['ipcidr']" "0" "/etc/openclash/custom/openclash_custom_fallback_filter.yaml" "['fallback-filter']['ipcidr']"

#Ruby Script Demo:
    #ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "
    #   begin
    #      Value = YAML.load_file('$CONFIG_FILE');
    #   rescue Exception => e
    #      puts '${LOGTIME} Error: Load File Failed,【' + e.message + '】';
    #   end;

        #General
    #   begin
    #   Thread.new{
    #      Value['redir-port']=7892;
    #      Value['tproxy-port']=7895;
    #      Value['port']=7890;
    #      Value['socks-port']=7891;
    #      Value['mixed-port']=7893;
    #   }.join;

    #   rescue Exception => e
    #      puts '${LOGTIME} Error: Set General Failed,【' + e.message + '】';
    #   ensure
    #      File.open('$CONFIG_FILE','w') {|f| YAML.dump(Value, f)};
    #   end" 2>/dev/null >> $LOG_FILE

# 清空现有的listeners
LOG_OUT "Info: Clearing existing listeners..."
ruby_edit "$CONFIG_FILE" "['listeners']" "[]"

# 直接使用ruby_edit添加规则
LOG_OUT "Info: Adding custom rules to the beginning of rules list..."
ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "
   begin
      Value = YAML.load_file('$CONFIG_FILE');
      puts '${LOGTIME} Info: Successfully loaded config file';
   rescue Exception => e
      puts '${LOGTIME} Error: Load File Failed,【' + e.message + '】';
      exit 1;
   end;

   begin
      # 获取所有代理
      proxies = Value['proxies'] || [];
      puts '${LOGTIME} Info: Found ' + proxies.size.to_s + ' proxies in config';
      
      # 创建listeners数组
      listeners = [];
      port_start = 42000;
      
      # 过滤代理并创建监听器
      proxies.each_with_index do |proxy, index|
        name = proxy['name'].to_s;
        if !name.include?('期') && !name.include?('流量') && !name.include?('重置')
          listeners << {
            'name' => 'mixed' + name,
            'type' => 'mixed',
            'port' => port_start + index,
            'proxy' => name
          };
        end
      end
          
      # 添加listeners到配置中
      Value['listeners'] = listeners;
    
      puts '${LOGTIME} Info: Created ' + listeners.size.to_s + ' listeners';
  
      
      # 添加配置说明
      Value['#'] = 'Profile Enhancement by OpenClash Script';
      
      # 保存修改后的配置
      File.open('$CONFIG_FILE','w') {|f| YAML.dump(Value, f)};
      puts '${LOGTIME} Info: Successfully saved config file';
   rescue Exception => e
      puts '${LOGTIME} Error: Script execution failed,【' + e.message + '】';
   end" 2>/dev/null >> $LOG_FILE

LOG_OUT "Info: Custom Overwrite Scripts Finished!"


exit 0
