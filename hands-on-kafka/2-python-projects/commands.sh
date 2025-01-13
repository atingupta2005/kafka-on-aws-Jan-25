sudo rm -rf ~/kafka-ey-24
cd ~
git clone https://github.com/atingupta2005/kafka-ey-24
cd ~/kafka-ey-24/hands-on-kafka/2-python-projects
sudo chmod a+rwx /pyenv
deactivate
source /pyenv/bin/activate
nc -vz localhost 2181
nc -vz localhost 9092
sudo apt install httpie  -y

USER_SUFFIX=$(echo "$USER" | cut -c 2-5)
echo $USER_SUFFIX

##----------------------------------------------------------------##
# Create Topic
cd ~/kafka-ey-24/hands-on-kafka/2-python-projects/1-python-kafka-admin-api-simple
pip install -r requirements.txt

sudo uvicorn main:app --reload --host 0.0.0.0 --port 85$USER_SUFFIX > output.log 2>&1 &
curl localhost:85$USER_SUFFIX/hello-world
sudo pkill uvicorn
##----------------------------------------------------------------##
# Create Topic with 'retention.ms': '360000'
cd ~/kafka-ey-24/hands-on-kafka/2-python-projects/2-python-kafka-admin-api-adv
pip install -r requirements.txt

sudo uvicorn main:app --reload --host 0.0.0.0 --port 85$USER_SUFFIX > output.log 2>&1 &
curl localhost:85$USER_SUFFIX/hello-world
sudo pkill uvicorn
##----------------------------------------------------------------##
# Create message when we call api using POST - /api/people
cd ~/kafka-ey-24/hands-on-kafka/2-python-projects/5-peopleservice-basic-producer
pip install -r requirements.txt

sudo uvicorn main:app --reload --host 0.0.0.0 --port 85$USER_SUFFIX > output.log 2>&1 &
sleep 2
http POST :85$USER_SUFFIX/api/people count:=5
sudo pkill uvicorn
##----------------------------------------------------------------##
# Create message when we call api using POST - /api/people with callbacks
cd ~/kafka-ey-24/hands-on-kafka/2-python-projects/8-peopleservice-producer-python-adv
pip install -r requirements.txt

sudo uvicorn main:app --reload --host 0.0.0.0 --port 85$USER_SUFFIX > output.log 2>&1 &
sleep 2
http POST :85$USER_SUFFIX/api/people count:=5
tail output.log
##----------------------------------------------------------------##
# Kafka consumer
cd ~/kafka-ey-24/hands-on-kafka/2-python-projects/10-peopleconsumeradv
pip install -r requirements.txt

python pyconsumer.py &
http POST :85$USER_SUFFIX/api/people count:=1
sudo pkill uvicorn
pkill pyconsumer
pkill -f " pyconsumer.py"
