#!/bin/sh
PASSFILE="/etc/openvpn/psw-file"
LOG_FILE="/etc/openvpn/openvpn-authorized.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`
Ding_Webhook_Token="xxxxxxxxxxxxxxxxxxxxxx"
Ding_Webhook="https://oapi.dingtalk.com/robot/send?access_token="$Ding_Webhook_Token
#DevOpsUrl="http://10.50.8.222/user/vpnlog/"
ENVIRONMENT="生产环境"

swap_seconds ()
{
    SEC=$1
    [ "$SEC" -le 60 ] && echo "$SEC秒"
    [ "$SEC" -gt 60 ] && [ "$SEC" -le 3600 ] && echo "$(( SEC / 60 ))分钟$(( SEC % 60 ))秒"
    [ "$SEC" -gt 3600 ] && echo "$(( SEC / 3600 ))小时$(( (SEC % 3600) / 60 ))分钟$(( (SEC % 3600) % 60 ))秒"
}

echo "${TIME_STAMP}: script_type="$script_type"." >> ${LOG_FILE}

if [ $script_type = 'user-pass-verify' ] ; then
    if [ ! -r "${PASSFILE}" ]; then
        echo "${TIME_STAMP}: Could not open password file "${PASSFILE}" for reading." >> ${LOG_FILE}
        exit 1
    fi
    CORRECT_PASSWORD=`awk '!/^;/&&!/^#/&&$1=="'${username}'"{print $2;exit}' ${PASSFILE}`
    if [ "${CORRECT_PASSWORD}" = "" ]; then
        echo "${TIME_STAMP}: User does not exist: username="${username}", password="${password}"." >> ${LOG_FILE}
        exit 1
    fi
    if [ "${password}" = "${CORRECT_PASSWORD}" ]; then
        echo "${TIME_STAMP}: Successful authentication: username="${username}"." >> ${LOG_FILE}
        exit 0
    fi
    echo "${TIME_STAMP}: Incorrect password: username="${username}", password="${password}"." >> ${LOG_FILE}
    exit 1
fi
if [ $script_type = 'client-connect' ] ; then
    curl -s "$Ding_Webhook" \
        -H 'Content-Type: application/json' \
        -d '
        {
            "msgtype": "markdown",
            "markdown": {
                "title": "'$common_name'连接到'$ENVIRONMENT'VPN",
                "text": "## '$common_name'连接到'$ENVIRONMENT'VPN\n> ####    **连接时间**:  '"$TIME_STAMP"'\n> ####    **IP + 端口**:  '$trusted_ip':'$trusted_port'\n> ####    **端对端IP**:  '$ifconfig_pool_remote_ip' <===> '$ifconfig_local'"
            },
            "at": {
                "isAtAll": false
            }
        }'
#    curl -s "$DevOpsUrl" \
#        -H 'Content-Type: application/json' \
#        -d '
#        {
#            "common_name": "'$common_name'",
#            "ifconfig_pool_remote_ip": "'$ifconfig_pool_remote_ip'",
#            "trusted_ip": "'$trusted_ip'",
#            "trusted_port": '$trusted_port'
#        }'
fi
if [ $script_type = 'client-disconnect' ]; then
    duration_time=`swap_seconds $time_duration`
    curl -s "$Ding_Webhook" \
        -H 'Content-Type: application/json' \
        -d '
        {
            "msgtype": "markdown",
            "markdown": {
                "title": "'$common_name'断开'$ENVIRONMENT'VPN",
                "text": "## '$common_name'断开'$ENVIRONMENT'VPN\n> ####    **断开时间**:  '"$TIME_STAMP"'\n> ####    **IP + 端口**:  '$trusted_ip':'$trusted_port'\n> ####    **端对端IP**:  '$ifconfig_pool_remote_ip' <===> '$ifconfig_local'\n> ####    **持续时间**: '$duration_time'"
            },
            "at": {
                "isAtAll": false
            }
        }'
fi
