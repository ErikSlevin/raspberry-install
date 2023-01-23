#!/bin/bash

clear

function color (){
    echo "\e[$1m$2\e[0m"
}

function extend (){
    local str="$1"
    let spaces=60-${#1}
    while [ $spaces -gt 0 ]; do
        str="$str "
        let spaces=spaces-1
    done
    echo "$str"
}

function center (){
    local str="$1"
    let spacesLeft=(78-${#1})/2
    let spacesRight=78-spacesLeft-${#1}
    while [ $spacesLeft -gt 0 ]; do
        str=" $str"
        let spacesLeft=spacesLeft-1
    done

    while [ $spacesRight -gt 0 ]; do
        str="$str "
        let spacesRight=spacesRight-1
    done

    echo "$str"
}

function sec2time (){
    local input=$1

    if [ $input -lt 60 ]; then
        echo "$input seconds"
    else
        ((days=input/86400))
        ((input=input%86400))
        ((hours=input/3600))
        ((input=input%3600))
        ((mins=input/60))

        local daysPlural="s"
        local hoursPlural="s"
        local minsPlural="s"

        if [ $days -eq 1 ]; then
            daysPlural=""
        fi

        if [ $hours -eq 1 ]; then
            hoursPlural=""
        fi

        if [ $mins -eq 1 ]; then
            minsPlural=""
        fi

        echo "$days day$daysPlural, $hours hour$hoursPlural, $mins minute$minsPlural"
    fi
}

borderColor=35
headerLeafColor=32
headerRaspberryColor=31
greetingsColor=32
statsLabelColor=32

borderEmptyLine="                                                                              "

me=$(whoami)

# Greetings
# Date Fix for Italian Language
weekday=$(date +%A)
monthname=$(date +%B)
#old $(date +"%A, %d %B %Y, %T")")")"
# ----------------------------
greetings="$(color $greetingsColor "$(center "Willkommen zurück, $me!")")\n"
greetings="$greetings$(color $greetingsColor "$(center "${weekday^}, $(date +%d) ${monthname^} $(date +%Y), $(date +%T)")")"

# System information
read loginFrom loginIP loginDate <<< $(last $me --time-format iso -2 | awk 'NR==2 { print $2,$3,$4 }')

# TTY login
if [[ $loginDate == - ]]; then
    loginDate=$loginIP
    loginIP=$loginFrom
fi

# Date LastLogin Fix for Italian Language
weekday=$(date -d $loginDate +%A)
monthname=$(date -d $loginDate +%B)
# ----------------------------
if [[ $loginDate == *T* ]]; then
    login="${weekday^}, $(date -d $loginDate +"%d") ${monthname^} $(date -d $loginDate +"%Y, %T") ($loginIP)"
    #login="$(date -d $loginDate +"%A, %d %B %Y, %T") ($loginIP)"
else
    # Not enough logins
    login="None"
fi

label1="$(extend "$login")"
label1="  $(color $statsLabelColor "Letzter Login....:") $label1"

uptime="$(sec2time $(cut -d "." -f 1 /proc/uptime))"
uptime="$uptime ($(date -d "@"$(grep btime /proc/stat | cut -d " " -f 2)))"

label2="$(extend "$uptime")"
label2="  $(color $statsLabelColor "Laufzeit.........:") $label2"

label3="$(extend "$(free -m | awk 'NR==2 { printf "Total: %sMB, Used: %sMB, Free: %sMB",$2,$3,$4; }')")"
label3="  $(color $statsLabelColor "Arbeitsspeicher..:") $label3"

label4="$(extend "$(df -h ~ | awk 'NR==2 { printf "Total: %sB, Used: %sB, Free: %sB",$2,$3,$4; }')")"
label4="  $(color $statsLabelColor "Festplatte.......:") $label4"

ip=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
label5="$(extend "$ip")"
label5="  $(color $statsLabelColor "IP-Adresse.......:") $label5"

wan=$(curl -s ifconfig.me | tail)
label6="$(extend "$wan")"
label6="  $(color $statsLabelColor "WAN-Adresse......:") $label6"


cpu=$(</sys/class/thermal/thermal_zone0/temp)
label7="$(extend "$((cpu/1000)) °C")"
label7="  $(color $statsLabelColor "Temperatur.......:") $label7"

stats="$label1\n$label2\n$label3\n$label4\n$label5\n$label6\n$label7"

# Print motd
echo -e "\n$greetings\n$borderEmptyLine\n$stats\n"
