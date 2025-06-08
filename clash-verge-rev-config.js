// Clash Verge Script to add listeners for all proxies
function main(config, profileName) {
  // 如果配置为空则返回
  if (!config) return config;
  
  // 获取所有代理
  const proxies = config.proxies || [];
  
  // 创建listeners数组
  const listeners = proxies.filter(
    proxy => !proxy.name.includes('期') 
    && !proxy.name.includes('流量')
    && !proxy.name.includes('重置')
    ).map((proxy, index) => ({
    name: `mixed${proxy.name}`,
    type: 'mixed',
    port: 42000 + index,
    proxy: proxy.name,
  }));
  
  // 添加listeners到配置中
  config.listeners = listeners;
    // 确保rules数组存在
  if (!config.rules) {
    config.rules = [];
  }
  
  // 自定义链接规则
  config.rules.unshift(
    'DOMAIN-SUFFIX,magicnewton.com,DIRECT',
    'DOMAIN-SUFFIX,api.yescaptcha.com,DIRECT',
    'DOMAIN-SUFFIX,localhost,DIRECT',
    'IP-CIDR,10.0.0.0/8,DIRECT'
  );
  
  // 添加配置说明
  config['#'] = 'Profile Enhancement Merge Template for Clash Verge';
  
  return config;
}
