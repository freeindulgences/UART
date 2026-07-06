#!/bin/bash

echo "########################################"
echo "Performing PVS Studio static analysis."
echo "Please remember, this errors can be false-positives but they very rarely are."

echo -e "\e[45mPlease note that line numbers are off by 2! Subtract 2 from line number to get it right!\e[0m"

# suppress progress output
pvs-studio-analyzer analyze -a 44 -o project.log -e "*/spl/*" -e "*/arm-none-eabi/*" -e "*/mcu_support_package/*" -e "*/cmsis/*" #&>/dev/null

retval=$?

# print analysis log, highlighting "error" and "warning" with grep
plog-converter --indicate-warnings -t errorfile project.log | GREP_COLOR='01;31' grep -E --color=always 'error:|$' | GREP_COLOR='01;33' grep -E --color=always 'warning:|$'


if [ "${PIPESTATUS[0]}" -eq "2" ]; then
   echo -e "\e[41mPVS Studio has reported some problems!\e[0m"
   exit 1;
fi

echo "PVS Studio analysis complete"