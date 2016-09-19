function FindProxyForURL(url, host) 
{
    if (isPlainHostName(host)	||
	isInNet(host, "127.0.0.1", "255.255.255.255") ||
	shExpMatch(host, "*.mobilmir.ru") ||
	shExpMatch(host, "*.cg26.ru") ||
	shExpMatch(host, "*.cifrograd26.ru")
       ) 
	return "PROXY 192.168.127.1:3128"; 

    return "DIRECT";
}
