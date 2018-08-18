FROM centos:7


#TODO a faire depuis artifactory
RUN yum -y install java-1.8.0-openjdk which openssh openssh-server openssh-clients

RUN echo 'root:password' | chpasswd
RUN sed -i -e 's/#PermitRootLogin yes/PermitRootLogin yes/' -e 's/UsePAM yes yes/UsePAM no/' -e 's%HostKey /etc/ssh/ssh_host_ecdsa_key%#HostKey /etc/ssh/ssh_host_ecdsa_key%' -e 's%HostKey /etc/ssh/ssh_host_ed25519_key%#HostKey /etc/ssh/ssh_host_ed25519_key%' /etc/ssh/sshd_config

#HDFS OS GROUPS

RUN useradd -d /opt/hadoop hadoop
RUN echo "hadoop:hadoop" | chpasswd
RUN useradd -r -s /bin/false -g hadoop hbase

ENV ARTIFACTORY_URL=172.22.1.150
ENV HADOOP_VERSION=2.7.4

#conf SSH
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''

RUN echo -e "CheckHostIP no\nNoHostAuthenticationForLocalhost yes\nStrictHostKeyChecking no\nUserKnownHostsFile /dev/null\n" >> /etc/ssh/ssh_config


#volume hadoop
RUN mkdir -p /opt/volume

COPY ./hadoop/conf/.bashrc /opt/hadoop
COPY ./hadoop/scripts/entrypoint.sh /opt/hadoop

RUN chown hadoop:hadoop /opt/hadoop/.bashrc
RUN chmod ugo+x /opt/hadoop/entrypoint.sh
RUN mkdir -p /opt/volume/datanode
RUN mkdir -p /opt/volume/namenode
RUN chown -R hadoop:hadoop /opt/volume

# ################################
# USER HADOOP
# ################################
USER hadoop

ENV HADOOP_BIN=hadoop-${HADOOP_VERSION}.tar.gz
WORKDIR /tmp
RUN curl -L -O http://${ARTIFACTORY_URL}/artifactory/libs-release-local/fr/cnamts/p8/hadoop/${HADOOP_VERSION}/$HADOOP_BIN \
	&& tar xfz $HADOOP_BIN -C /opt/hadoop/ \
	&& rm -f $HADOOP_BIN

RUN cp -rf /opt/hadoop/hadoop-${HADOOP_VERSION}/* /opt/hadoop/


#SSH HADOOP
RUN ssh-keygen -t rsa -P ''  -f /opt/hadoop/.ssh/id_rsa
RUN cat /opt/hadoop/.ssh/id_rsa.pub >> /opt/hadoop/.ssh/authorized_keys
RUN chmod 0600 /opt/hadoop/.ssh/authorized_keys


#RUN chown -R hadoop:hadoop /opt/hadoop/.ssh

#conf hadoop
COPY ./hadoop/conf/core-site.xml /opt/hadoop/etc/hadoop/
COPY ./hadoop/conf/hdfs-site.xml /opt/hadoop/etc/hadoop/
COPY ./hadoop/conf/hadoop-env.sh /opt/hadoop/etc/hadoop/
# MapReduce
COPY ./hadoop/conf/mapred-site.xml /opt/hadoop/etc/hadoop/
# Yarn
COPY ./hadoop/conf/yarn-env.sh /opt/hadoop/etc/hadoop/
COPY ./hadoop/conf/yarn-site.xml /opt/hadoop/etc/hadoop/
COPY ./hadoop/conf/capacity-scheduler.xml /opt/hadoop/etc/hadoop/

RUN source /opt/hadoop/.bashrc
#RUN hdfs namenode -format

# ################################
# USER ROOT
# ################################

USER root

RUN echo "alias hadoop='/opt/hadoop/bin/hadoop'" >> ~/.bashrc
RUN source ~/.bashrc

ENTRYPOINT ["bash", "-c", "/opt/hadoop/entrypoint.sh"]
