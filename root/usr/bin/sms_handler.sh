#!/bin/sh

# =========================================================
# SMS Forwarder - Dual-Mode (sms_tool / ModemManager)
# =========================================================

CONF="smsforward"
LOG_FILE="/etc/sms_sent.log"
TMP_DIR="/tmp/sms_forward"
LOCK_FILE="/tmp/ttyUSB_sms.lock"
mkdir -p "$TMP_DIR"
touch "$LOG_FILE"

# 1. 实时开关检测
[ "$(uci -q get $CONF.config.enabled)" != "1" ] && exit 0

# 2. 获取配置
DEVICE=$(uci -q get $CONF.config.device || echo "/dev/ttyUSB2")
SERVER=$(uci -q get $CONF.config.server)
PORT=$(uci -q get $CONF.config.port)
USER=$(uci -q get $CONF.config.user)
PASS=$(uci -q get $CONF.config.password)
TARGET=$(uci -q get $CONF.config.target_email)
SENDER=$(uci -q get $CONF.config.sender_email)

# 3. 扫描逻辑（分流处理）
> "$TMP_DIR/raw_recv.txt"

if [ "$DEVICE" = "mm" ]; then
    # === ModemManager 模式 ===
    MM_IDX=$(mmcli -L | grep -oE "Modem/[0-9]+" | head -n 1 | cut -d'/' -f2)
    
    if [ -n "$MM_IDX" ]; then
        SMS_LIST=$(mmcli -m "$MM_IDX" --messaging-list-sms | grep -oE "SMS/[0-9]+" | cut -d'/' -f2)
        for s_idx in $SMS_LIST; do
            echo "MSG: $s_idx" >> "$TMP_DIR/raw_recv.txt"
            # 改进提取逻辑：精准截断 Properties 
            mmcli -m "$MM_IDX" -s "$s_idx" | awk '
                /number:/ { print "From: " $NF }
                /timestamp:/ { print "Date/Time: " $NF }
                /text:/ { 
                    # 找到 text: 所在位置，并提取它之后到行末的内容
                    s=$0; sub(/.*text: /, "", s);
                    # 去掉开头的单引号
                    sub(/^\047/, "", s);
                    found=1;
                    # 如果这一行就包含结尾引号，处理后结束
                    if (s ~ /\047$/) {
                        sub(/\047$/, "", s);
                        print s;
                        found=0;
                    } else {
                        print s;
                    }
                    next;
                }
                found { 
                    # 如果遇到 Properties 栏目的横线，强制停止
                    if ($0 ~ /-------/) { found=0; next; }
                    # 如果这一行包含结束引号，处理后结束
                    if ($0 ~ /\047$/) {
                        s=$0; sub(/\047$/, "", s);
                        # 清理 mmcli 侧边的 | 符号和空格
                        sub(/.*\| /, "", s);
                        print s;
                        found=0;
                    } else {
                        s=$0; sub(/.*\| /, "", s);
                        print s;
                    }
                }
            ' >> "$TMP_DIR/raw_recv.txt"
        done
    fi
else
    # === 传统串口模式 (sms_tool) ===
    [ -x /usr/bin/sms_tool ] && BIN="sms_tool" || BIN="sms-tool"
    exec 8>"$LOCK_FILE"
    if flock -n 8; then
        $BIN -d "$DEVICE" -s SM recv >> "$TMP_DIR/raw_recv.txt" 2>/dev/null
        $BIN -d "$DEVICE" -s ME recv >> "$TMP_DIR/raw_recv.txt" 2>/dev/null
        flock -u 8
    fi
fi

[ ! -s "$TMP_DIR/raw_recv.txt" ] && exit 0

# 准备邮件配置
MSTMP_CONF="/tmp/msmtp_sms.conf"
cat << MEMO > "$MSTMP_CONF"
defaults
auth on
tls on
tls_starttls on
tls_certcheck off
account default
host $SERVER
port $PORT
from $SENDER
user $USER
password $PASS
MEMO
chmod 600 "$MSTMP_CONF"

# 4. 内容解析与去重转发
CUR_INDEX=""; CUR_SENDER=""; CUR_TIME=""; CUR_SEG=""; CUR_CONTENT=""

process_msg() {
    [ -z "$CUR_INDEX" ] || [ -z "$CUR_CONTENT" ] && return
    
    # 清理控制字符，保留干净的内容
    CLEAN_CONTENT=$(echo "$CUR_CONTENT" | tr -d '\000-\011\013\014\016-\037' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    MSG_HASH=$(echo "$CUR_SENDER${CLEAN_CONTENT:0:30}$CUR_INDEX" | md5sum | awk '{print $1}')
    
    if ! grep -q "$MSG_HASH" "$LOG_FILE"; then
        {
            echo "Subject: SMS: $CUR_SENDER ($CUR_SEG)"
            echo "To: $TARGET"
            echo "From: $SENDER"
            echo "Content-Type: text/plain; charset=UTF-8"
            echo ""
            [ -n "$CUR_TIME" ] && echo "Date/Time: $CUR_TIME"
            [ -n "$CUR_SEG" ]  && echo "$CUR_SEG"
            echo "--------------------------------"
            echo "$CLEAN_CONTENT"
            echo "--------------------------------"
        } | msmtp -C "$MSTMP_CONF" "$TARGET"
        
        [ $? -eq 0 ] && echo "$MSG_HASH" >> "$LOG_FILE"
        tail -n 500 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
    fi
}

while read -r line || [ -n "$line" ]; do
    case "$line" in
        MSG:*)
            process_msg
            CUR_INDEX=$(echo "$line" | awk '{print $2}')
            CUR_CONTENT=""; CUR_SENDER="Unknown"; CUR_TIME=""; CUR_SEG="Single"
            ;;
        From:*)
            CUR_SENDER=$(echo "$line" | awk '{print $NF}')
            ;;
        Date/Time:*)
            CUR_TIME=$(echo "$line" | cut -d' ' -f2-)
            ;;
        SMS\ segment*)
            CUR_SEG=$(echo "$line" | tr -d '\r')
            ;;
        *)
            if [ -n "$line" ]; then
                # 过滤掉 mmcli 输出中残留的竖线和前导空格
                CLEAN_LINE=$(echo "$line" | sed 's/.*| //')
                CUR_CONTENT="$CUR_CONTENT$CLEAN_LINE"
            fi
            ;;
    esac
done < "$TMP_DIR/raw_recv.txt"

process_msg
