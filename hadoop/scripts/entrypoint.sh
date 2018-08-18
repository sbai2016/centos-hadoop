#!/bin/bash
/usr/sbin/sshd

su - hadoop bash -c "source /opt/hadoop/.bashrc; hdfs namenode -format"
su - hadoop bash -c "source /opt/hadoop/.bashrc; start-dfs.sh"
su - hadoop bash -c "source /opt/hadoop/.bashrc; start-yarn.sh"
su - hadoop bash -c "source /opt/hadoop/.bashrc; mr-jobhistory-daemon.sh start historyserver"
su - hadoop bash -c "source /opt/hadoop/.bashrc; hdfs dfs -mkdir /hbase"
su - hadoop bash -c "source /opt/hadoop/.bashrc; hdfs dfs -mkdir /spark-logs"
su - hadoop bash -c "source /opt/hadoop/.bashrc; hadoop dfsadmin -safemode leave"
su - hadoop bash -c "source /opt/hadoop/.bashrc; hdfs dfs -mkdir -p /user/hadoop"
su - hadoop bash -c "source /opt/hadoop/.bashrc; hdfs dfs -mkdir -p /user/root"
su - hadoop bash -c "source /opt/hadoop/.bashrc; hdfs dfs -chown root /user/root"
su - hadoop bash -c "source /opt/hadoop/.bashrc; hdfs dfs -mkdir -p  /user/root/nifi/in"
su - hadoop bash -c "source /opt/hadoop/.bashrc; hdfs dfs -mkdir -p  /user/root/nifi/out"
su - hadoop bash -c "source /opt/hadoop/.bashrc; hdfs dfs -chown root /user/root"

tail -f /dev/null