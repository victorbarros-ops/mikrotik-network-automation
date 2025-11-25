# -------------------------------------------------------------------------
# SCRIPT: Telegram Alert for Firewall Blacklist
# DESCRIPTION: Fetches IPs from the blacklist and sends a report via Telegram API.
# NOTE: Replace 'YOUR_BOT_TOKEN' and 'YOUR_CHAT_ID' with actual values.
# -------------------------------------------------------------------------

# Define variables (Sanitized for GitHub Security)
:local botToken "YOUR_BOT_TOKEN_HERE"
:local chatId "YOUR_CHAT_ID_HERE"

# Get Blacklist
:local blacklist [/ip firewall address-list find list=blacklist]

# Build Message
:local message "⚠️ Firewall Blacklist Report:\n"
:foreach i in=$blacklist do={
    :local ip [/ip firewall address-list get $i address]
    :local comment [/ip firewall address-list get $i comment]
    :set message ($message . $ip . " - " . $comment . "\n")
}

# URL Encode Function
:local urlEncode do={
    :local str $1
    :local encoded ""
    :local char ""
    :local charCode ""
    :for i from=0 to=([:len $str] - 1) do={
        :set char [:pick $str $i]
        :set charCode [:tostr [:tonum [:find [:toarray "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_.~"] $char]]]
        :if ($charCode != "") do={
            :set encoded ($encoded . $char)
        } else={
            :set encoded ($encoded . "%" . [:pick "0123456789ABCDEF" ([:tonum $char] >> 4)] . [:pick "0123456789ABCDEF" ([:tonum $char] & 0x0F)])
        }
    }
    :return $encoded
}

:local encodedMessage [$urlEncode $message]

# Build URL
:local url ("https://api.telegram.org/bot" . $botToken . "/sendMessage?chat_id=" . $chatId . "&text=" . $encodedMessage)

# Send to API
/tool fetch url=$url keep-result=no
