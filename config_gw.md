
# Configuration Authentication and Mosquitto
- Add mosquitto users and password
  ```bash
  sudo mosquitto_passwd -c /etc/mosquitto/pwd loraroot # Create a root user. After entering this command, you will be allowed to set and confirm a password. In this experiment, the passwords related to mosquitto are all password.
  sudo mosquitto_passwd /etc/mosquitto/pwd loragw # Create a user named “loragw” for use with lora-gateway-bridge
  sudo mosquitto_passwd /etc/mosquitto/pwd loraserver # This user is used by "loraserver"
  sudo mosquitto_passwd /etc/mosquitto/pwd loraappserver # This user uses "lora-app-server"
  sudo chmod 600 /etc/mosquitto/pwd # Pwd file encryption
  sudo vi /etc/mosquitto/conf.d/local.conf # Open the local.conf file with the vi editor, add the following content to it and save and exit;
  ```
- Edit local.conf
  ```vi
    allow_anonymous false
    password_file /etc/mosquitto/pwd
  ```
- Run mosquitto 
  ```bash
    sudo systemctl restart mosquitto
  ```





# Configure PostgreSQL Database
- Connect postgres DB
  ```bash
  sudo -u postgres psql # Enter the postgres database command line mode
  ```
- Add databases and users
  ```mysql
  create role lora_ns with login password 'password';
  create database lora_ns with owner lora_ns;
  create role lora_as with login password 'password';
  create database lora_as with owner lora_as;
  \c lora_as
  create extension pg_trgm;
  create extension hstore;
  \q
  ```
- Check 
  ```bash
  psql -h localhost -U lora_ns -W lora_ns
  psql -h localhost -U lora_as -W lora_as
  ```






# Configure Lora Gateway Bridge
- 
  ```bash
  sudo vi /etc/chirpstack-gateway-bridge/chirpstack-gateway-bridge.toml
  ```
- Edit chirpstack-gateway-bridge.toml
  ```vi
    udp_bind = "0.0.0.0:1700"  
    server="tcp://127.0.0.1:1883"
    username="loragw"
    password="password"
  ```
- Run
  ```bash
  sudo systemctl restart chirpstack-gateway-bridge # [start|stop|restart|status]
  journalctl -u chirpstack-gateway-bridge -f -n 50
  ```




# Configure Network Server
- Open Network Server configuration file
  ```bash
  sudo vi /etc/chirpstack-network-server/chirpstack-network-server.toml #chirpstack-network-server configfile > chirpstack-network-server.toml
  ```
- Edit
  ```vi
    dsn="postgres://lora_ns:password@localhost/lora_ns?lmode=disable"
    name="KR920"
    bind="0.0.0.0:8000"
    username="loraserver"
    password="password"
  ```
- Restart
  ```bash
  sudo systemctl restart chirpstack-network-server
  journalctl -u chirpstack-network-server -f -n 50 #ChirpStack Network Server log output
  ```





# Configure Application Server
- Open Application Server configuration file
  ```bash
  sudo vi /etc/chirpstack-application-server/chirpstack-application-server.toml
  ```
- Edit
  ```vi
    dsn="postgres://lora_as:password@localhost/lora_as?sslmode=disable"
    username="loraappserver" #MQTT User
    password="password" #MQTT password
    bind="0.0.0.0:8080"
    jwt_secret="openssl rand -base64 32"
  ```
- Restart
  ```bash
  sudo systemctl restart chirpstack-application-server
  journalctl -u chirpstack-application-server -f -n 50
  ```





# Check Status
- 서비스 정상 작동 확인
  ```bash
  sudo systemctl status mosquitto #Check if mosquitto is running
  sudo systemctl status lora-gateway-bridge # Check if lora-gateway-bridge is running
  sudo systemctl status loraserver #Check if loricaserver is running
  sudo systemctl status lora-app-server # Check if lora-app-server is running
  ```





# Configure Influx Database - MQTT 사용시 필요 없음
- Open configuration file
  ```bash
  sudo vi /etc/influxdb/influxdb.conf
  ```
- Edit
  ```
    [http]
      enabled = true
      bind-address = ":8086"
      auth-enabled = false
  ```
- Add database
  ```bash
  influx -precision rfc3339
  ```
  ```vi
    > create database sensordata
    > show databases
    > quit
  ```
- Run
  ```bash
  sudo service influxdb restart
  ```





# 패킷 캡처
  ```bash
  sudo tcpdump -i lo port 1700
  ```





# 방확벽 설정 - 설정 필요 없음
  ```bash
  sudo apt install ufw
  sudo ufw disable
  sudo ufw allow 8080
  ```


# Lora Application Data 확인
  ```bash
  mosquitto_sub -h 127.0.0.1 -p 1883 -u loraappserver -P password -t "application/1/#" -v # Application ID 1의 모든 데이터 구독
  mosquitto_sub -h 127.0.0.1 -p 1883 -u loraappserver -P password -t "application/1/device/+/join" -v # 모든 디바이스의 join 메시지 구독
  mosquitto_sub -h 127.0.0.1 -p 1883 -u loraappserver -P password -t "application/1/device/2232330000888802/join" -v # Dev Eui가 2232330000888802인 join 메시지 구독
  mosquitto_sub -h 127.0.0.1 -p 1883 -u loraappserver -P password -t "application/1/device/+/rx" -v # 모든 디바이스의 rx 메시지 구독
  mosquitto_sub -h 127.0.0.1 -p 1883 -u loraappserver -P password -t "application/1/device/2232330000888802/rx" -v # Dev Eui가 2232330000888802인 rx 메시지 구독
  mosquitto_sub -h 127.0.0.1 -p 1883 -u loraappserver -P password -t "application/1/device/2232330000888802/+" -v # Dev Eui가 2232330000888802인 모든 메시지 구독
  ```
