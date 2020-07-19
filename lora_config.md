######Configuration Authentication and Mosquitto
sudo mosquitto_passwd -c /etc/mosquitto/pwd loraroot # Create a root user. After entering this command, you will be allowed to set and confirm a password. In this experiment, the passwords related to mosquitto are all 62374838.
sudo mosquitto_passwd /etc/mosquitto/pwd loragw # Create a user named “loragw” for use with lora-gateway-bridge
sudo mosquitto_passwd /etc/mosquitto/pwd loraserver # This user is used by "loraserver"
sudo mosquitto_passwd /etc/mosquitto/pwd loraappserver # This user uses "lora-app-server" 62374838
sudo chmod 600 /etc/mosquitto/pwd # Pwd file encryption
sudo nano /etc/mosquitto/conf.d/local.conf # Open the local.conf file with the nano editor, add the following content to it and save and exit;
# allow_anonymous false
# password_file /etc/mosquitto/pwd
sudo systemctl restart mosquitto





######Configure PostgreSQL Database
sudo -u postgres psql # Enter the postgres database command line mode
# > create role chirpstack_ns with login password '62374838';
# > create database chirpstack_ns with owner chirpstack_ns;
# > create role chirpstack_as with login password '62374838';
# > create database chirpstack_as with owner chirpstack_as;
# > \c chirpstack_as
# > create extension pg_trgm;
# > create extension hstore;
# > \q

psql -h localhost -U chirpstack_ns -W chirpstack_ns
psql -h localhost -U chirpstack_as -W chirpstack_as






######Configure Bridge
sudo vi /etc/chirpstack-gateway-bridge/chirpstack-gateway-bridge.toml
# server="tcp://127.0.0.1:1883"
# username="loragw"
# password="62374838"
sudo systemctl restart chirpstack-gateway-bridge # [start|stop|restart|status]
journalctl -u chirpstack-gateway-bridge -f -n 50





######Configure Network Server
#Config Network Server
sudo vi /etc/chirpstack-network-server/chirpstack-network-server.toml #chirpstack-network-server configfile > chirpstack-network-server.toml

# dsn="postgres://chirpstack_ns:62374838@localhost/chirpstack_ns?sslmode=disable"
# name="KR920"
# bind="127.0.0.1:8000"
# username="loraserver"
# password="62374838"
# jwt_secret="openssl rand -base64 32"

#Restart
sudo systemctl restart chirpstack-network-server
#ChirpStack Network Server log output
journalctl -u chirpstack-network-server -f -n 50





######Configure Application Server
sudo vi /etc/chirpstack-application-server/chirpstack-application-server.toml

# dsn="postgres://loraserver_as:62374838@localhost/loraserver_as?sslmode=disable"
# username="loraappserver"
# password="62374838"
# bind="localhost:8080"
# jwt_secret="openssl rand -base64 32"

sudo systemctl restart chirpstack-application-server
journalctl -u chirpstack-application-server -f -n 50





################Check Status
sudo systemctl status mosquitto #Check if mosquitto is running
sudo systemctl status loraserver #Check if loricaserver is running
sudo systemctl status lora-app-server # Check if lora-app-server is running
sudo systemctl status lora-gateway-bridge # Check if lora-gateway-bridge is running





############Influx Database
sudo vi /etc/influxdb/influxdb.conf
#[http]
#  enabled = true
#  bind-address = ":8086"
#  auth-enabled = false

sudo service influxdb restart
influx -precision rfc3339
#> create database sensordata
#> show databases
#> quit

sudo service influxdb restart





############ 패킷 캡처
sudo tcpdump -i lo port 1800





############ 방확벽 설정
sudo apt install ufw
sudo ufw disable
sudo ufw allow 8080