#!/bin/bash
# This bash script outputs the status of your Pi and checks whether you are being throttled for undervoltage and gives you your temperature
# Article and discussion at https://jamesachambers.com/measure-raspberry-pi-undervoltage-true-clock-speeds/
# Author James A Chambers 6-6-17
# updated throttle reason codes by tmuka 2021-10

# Output current configuration
vcgencmd get_config int | egrep "(arm|core|gpu|sdram)_freq|over_volt"

# Measure clock speeds
# for src in arm core h264 isp v3d; do echo -e "$src:\t$(vcgencmd measure_clock $src)"; done
# output human readable cpu speeds in GHz if you want raw data, use the previous line instead.

temp=$(vcgencmd measure_clock arm)
IFS== read var1 var2 <<< $temp
arm=$(echo "scale=1; $var2/1000000000" | bc -l)
if (($var2 < 1500000000 )); then
        echo -e "arm:    "$arm"GHz"
else
        echo -e "\033[31marm:    "$arm"GHz \033[0m"
fi

for src in core h264 isp v3d; do echo -e "$src:\t$(vcgencmd measure_clock $src  | awk ' BEGIN { FS="=" } ; { printf("%.1fGHz\n", $2 / 1000000000) } ')"; done

# Measure Volts
for id in core sdram_c sdram_i sdram_p ; do echo -e "$id:\t$(vcgencmd measure_volts $id)"; done

# Measure Temperature
#vcgencmd measure_temp
cpu=$(</sys/class/thermal/thermal_zone0/temp)
if ((cpu < 60000)); then
        echo "temp=$((cpu/1000))'C"
else
        echo -e "\033[31mtemp=$((cpu/1000))'C \033[0m"
fi

# See if we are being throttled
throttled="$(vcgencmd get_throttled)"
echo -e "$throttled"
if [[ $throttled != "throttled=0" ]]; then
        # echo "WARNING:  You are/have been throttled."
        # updated warnings details based on https://raspberrypi.stackexchange.com/a/91433
        # https://forum.libreelec.tv/thread/17860-how-to-interpret-rpi-vcgencmd-get-throttled/
        # NOTE: The script is slightly out of date as bits 3 and 19 have now been added since the page was published. So
        # 0x0 means nothing wrong
        # 0x50000 means throttled has occurred since the last reboot.
        # 0x50005 means you are currently under-voltage and throttled.
        #
        #       Bit Hex value   Meaning
        #       0          1    Under-voltage detected
        #       1          2    Arm frequency capped
        #       2          4    Currently throttled
        #       3          8    Soft temperature limit active
        #       16     10000    Under-voltage has occurred
        #       17     20000    Arm frequency capping has occurred
        #       18     40000    Throttling has occurred
        #       19     80000    Soft temperature limit has occurred
        case $throttled in
                "throttled=0x0")
                        echo "0x0       nothing wrong"
                        ;;
                "throttled=0x50000")
                        echo "\033[31m0x50000   throttling occurred since last reboot"
                        ;;
                "throttled=0x50005")
                        echo "0x50005   currently under voltage and throttled."
                        ;;
                "throttled=0x1")
                        echo "0          1    Under-voltage detected"
                        ;;
                "throttled=0x2")
                        echo "1          2    Arm frequency capped"
                        ;;
                "throttled=0x4")
                        echo "2          4    Currently throttled"
                        ;;
                "throttled=0x8")
                        echo "3          8    Soft temperature limit active";
                        ;;
                "throttled=0x10000")
                        echo "16     10000    Under-voltage has occurred"
                        ;;
                "throttled=0x20000")
                        echo "17     20000    Arm frequency capping has occurred"
                        ;;
                "throttled=0x40000")
                        echo "18     40000    Throttling has occurred"
                        ;;
                "throttled=0x80000")
                        echo "19     80000    Soft temperature limit has occurred \033[0m"
                        ;;
        esac
fi