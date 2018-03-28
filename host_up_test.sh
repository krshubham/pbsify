# for ip in $(seq 1 254); do 
#   ping -c 1 192.168.1.$ip>/dev/null; [ $? -eq 0 ] && echo "192.168.1.$ip UP" || : ; 
# done
for ip in $(seq 116 254); do
  OUTPUT="$(nmap 192.168.43.$ip)";
  if [[ $OUTPUT = *"Host is up"* ]]; then
    echo "The host 192.168.43.$ip is UP";
  else
    echo "The host 192.168.43.$ip seems DOWN";
  fi
done