#!/bin/bash
cpu_temp=$(</sys/class/thermal/thermal_zone0/temp)
cpu_freq=$(</sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
if (($cpu_temp > 60000)); then
    temp=$(echo "scale=1; $cpu_temp/1000" | bc -l)
    arm=$(echo "scale=1; $cpu_freq/1000000" | bc -l)
    ~/scripts/./telegram-send.sh "High CPU Temps Detected %0aCPU_Temp= "$temp" C %0aCPU_Freq= "$arm" GHz %0aOn `date`"
    echo "`date` Alert Server running at High Temperature "$temp" C @ "$arm" GHz"  >> ~/custome_scripts.log
fi