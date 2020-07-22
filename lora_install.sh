#Add Lora Gatway apt list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1CE2AFD36DBCCA00
sudo echo "deb https://artifacts.chirpstack.io/packages/3.x/deb stable main" | sudo tee /etc/apt/sources.list.d/chirpstack.list

#Add Influx DB list
sudo apt-get install apt-transport-https
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
sudo echo "deb https://repos.influxdata.com/debian jessie stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

#Gateway Driver, Packet forwarder, SDK Install
cd ~
mkdir lora
cd lora
sudo apt-get update
sudo apt-get install git
git clone https://github.com/Lora-net/lora_gateway.git # lora Gateway Drivers
git clone https://github.com/Lora-net/packet_forwarder.git # packet forwarding software
#git clone https://github.com/HelTecAutomation/lorasdk.git
cd /home/pi/lora/lora_gateway
make clean all
cd /home/pi/lora/packet_forwarder
make clean all
cd /home/pi/lora/lorasdk
chmod +x install.sh # dca632FFFE9015e6
./install.sh #Run the script. After the script is run, it will create a service named "lrgateway". The purpose is to make the lora driver and data forwarding program run automatically at startup.
sudo cp -f /global_conf_KR920.json global_conf.json


############ Installation Relative Tool Chain
sudo apt install mosquitto mosquitto-clients redis-server redis-tools postgresql tcpdump ufw

############ Gateway Bridge Install
sudo apt-get install chirpstack-gateway-bridge
#sudo systemctl start chirpstack-gateway-bridge # [start|stop|restart|status]
sudo systemctl enable chirpstack-gateway-bridge

############ Installing LoRa Network Server
sudo apt-get install chirpstack-network-server
#sudo systemctl start chirpstack-network-server #[start|stop|restart|status]

############ Installing the LoRa App Server
sudo apt-get install chirpstack-application-server
#sudo systemctl start chirpstack-application-server #[start|stop|restart|status] 

############ Install Infulx DB
sudo apt-get install influxdb
