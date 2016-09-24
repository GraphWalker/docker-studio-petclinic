FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
  openjdk-8-jdk \
  maven \
  git \
  nodejs \
  npm \
  sudo \
  wget \
  bzip2 \
  firefox && \
  apt-get remove firefox -y && \
  rm -rf /var/cache/apt/

  RUN sudo ln -s "$(which nodejs)" /usr/bin/node

RUN cd /usr/local && \
  wget http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/47.0.1/linux-x86_64/en-US/firefox-47.0.1.tar.bz2 && \
  ls -l && \
  tar xvjf firefox-47.0.1.tar.bz2 && \
  ln -s /usr/local/firefox/firefox /usr/bin/firefox


# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
  mkdir -p /home/developer && \
  mkdir -p /etc/sudoers.d && \
  echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
  echo "developer:x:${uid}:" >> /etc/group && \
  echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
  chmod 0440 /etc/sudoers.d/developer && \
  chown ${uid}:${gid} -R /home/developer

USER developer
ENV HOME /home/developer

RUN cd /home/developer && \
  git clone https://github.com/GraphWalker/graphwalker-project && \
  cd graphwalker-project/graphwalker-studio/src/main/webapp && \
  sudo npm install -g && \
  sudo npm install webpack -g && \
  webpack && \
  cd /home/developer/graphwalker-project && \
  mvn install -Dmaven.test.skip=true && \
  mvn clean package -pl graphwalker-studio -am -Dmaven.test.skip=true

RUN cd /home/developer && \
  git clone https://github.com/GraphWalker/graphwalker-example && \
  cd graphwalker-example/java-petclinic && \
  mvn graphwalker:generate-sources package
  
RUN cd /home/developer && \
  git clone https://github.com/SpringSource/spring-petclinic.git && \
  cd spring-petclinic && \
  git reset --hard 482eeb1c217789b5d772f5c15c3ab7aa89caf279

RUN cd /home/developer && \
  echo "#!/bin/bash" > start.sh && \
  echo "cd /home/developer/spring-petclinic && mvn tomcat7:run > spring.log 2>&1 &" >> start.sh && \
  echo "( tail -F -n0 /home/developer/spring-petclinic/spring.log & ) | grep -q 'INFO: Starting ProtocolHandler \[\"http-bio-9966\"\]'" >> start.sh && \
  echo "cd /home/developer/graphwalker-project && java -jar graphwalker-studio/target/graphwalker-studio-4.0.0-SNAPSHOT.jar > studio.log 2>&1 &" >> start.sh && \
  echo "( tail -F -n0 /home/developer/graphwalker-project/studio.log & ) | grep -q 'Started Application in '" >> start.sh

RUN chmod +x /home/developer/start.sh

CMD echo "========================================================" && \
  echo "  Will start Pet Clinic Web app and GraphWalker Studio" && \
  echo "  Please wait, will take some seconds" && \
  echo "========================================================" && \
  bash -C '/home/developer/start.sh' && \
  echo "========================================================" && \
  echo "  Pet Clinic Web app and Studio is up running!" && \
  echo "========================================================" && \
  cd /home/developer/graphwalker-example/java-petclinic && \
  echo "  Run following command:" && \
  echo '  mvn exec:java -Dexec.mainClass="com.company.runners.WebSocketApplication"' && \
  bash
