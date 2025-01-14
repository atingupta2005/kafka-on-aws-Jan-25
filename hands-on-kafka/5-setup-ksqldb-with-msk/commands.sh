nano .env
nano ksql-config/ksql-server.properties
docker-compose up -d

   mkdir -p ~/kafka/libs
   curl -L -o ~/kafka/libs/aws-msk-iam-auth.jar https://github.com/aws/aws-msk-iam-auth/releases/download/v2.2.0/aws-msk-iam-auth-2.2.0-all.jar
   jar tf ~/kafka/libs/aws-msk-iam-auth.jar | grep IAMClientCallbackHandler

   echo 'export CLASSPATH=$CLASSPATH:/home/$USER/kafka/libs/aws-msk-iam-auth.jar' >> ~/.bashrc

   source ~/.bashrc

   