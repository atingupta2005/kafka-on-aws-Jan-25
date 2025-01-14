aws kafka list-clusters
sudo yum update
sudo yum install git -y
git clone https://github.com/atingupta2005/kafka-on-aws-Jan-25
cd ~/kafka-on-aws-Jan-25/hands-on-kafka/5-setup-ksqldb-with-msk
nano .env
nano ksql-config/ksql-server.properties
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
sudo docker-compose up -d


docker exec -it ksqldb-cli ksql http://ksqldb-server:8088

