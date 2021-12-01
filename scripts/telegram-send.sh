#!/bin/bash
    
GROUP_ID="YOUR-CHAT-ID"
BOT_TOKEN="BOT-TOKEN"

curl -s --data "text=$1" --data "chat_id=$GROUP_ID" 'https://api.telegram.org/bot'$BOT_TOKEN'/sendMessage' > /dev/null