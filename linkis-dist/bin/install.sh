#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#Actively load user env
source ~/.bash_profile
shellDir=`dirname $0`
workDir=`cd ${shellDir}/..;pwd`
common_conf=$LINKIS_HOME/conf/linkis.properties

#To be compatible with MacOS and Linux
txt=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    txt="''"
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    # linux
    txt=""
elif [[ "$OSTYPE" == "cygwin" ]]; then
    echo "linkis not support Windows operating system"
    exit 1
elif [[ "$OSTYPE" == "msys" ]]; then
    echo "linkis not support Windows operating system"
    exit 1
elif [[ "$OSTYPE" == "win32" ]]; then
    echo "linkis not support Windows operating system"
    exit 1
elif [[ "$OSTYPE" == "freebsd"* ]]; then

    txt=""
else
    echo "Operating system unknown, please tell us(submit issue) for better service"
    exit 1
fi

## import common.sh
source ${workDir}/bin/common.sh

##load config
echo "======= Step 1: Load deploy-config/* =========="
export LINKIS_CONFIG_PATH=${LINKIS_CONFIG_PATH:-"${workDir}/deploy-config/linkis-env.sh"}
export LINKIS_DB_CONFIG_PATH=${LINKIS_DB_CONFIG_PATH:-"${workDir}/deploy-config/db.sh"}

source ${LINKIS_CONFIG_PATH}
source ${LINKIS_DB_CONFIG_PATH}

isSuccess "load config"


echo "======= Step 2: Check env =========="
## check env
# sh ${workDir}/bin/checkEnv.sh
# isSuccess "check env"

########################  init LINKIS related env  ################################
if [ "$LINKIS_HOME" = "" ]
then
  export LINKIS_HOME=${workDir}/LinkisInstall
fi

if [  -d $LINKIS_HOME ] && [ "$LINKIS_HOME" != "$workDir" ];then
   echo "LINKIS_HOME: $LINKIS_HOME is alread exists and will be backed up"

   ## Every time, backup the old linkis home with timestamp and not clean them.
   ## If you want to clean them, please delete them manually.
   backDir=$LINKIS_HOME-back-`date +'%s'`

   echo "mv  $LINKIS_HOME  $backDir"
   mv  $LINKIS_HOME  $backDir
   isSuccess "back up old LINKIS_HOME:$LINKIS_HOME to $backDir"
fi
echo "try to create dir LINKIS_HOME: $LINKIS_HOME"
sudo mkdir -p $LINKIS_HOME;sudo chown -R $deployUser:$deployUserGroup $LINKIS_HOME
isSuccess "create the dir of LINKIS_HOME:$LINKIS_HOME"

LINKIS_PACKAGE=${workDir}/linkis-package

if ! test -d ${LINKIS_PACKAGE}; then
    echo "**********${RED}Error${NC}: please put ${LINKIS_PACKAGE} in $workDir! "
    exit 1
else
    echo "Start to cp ${LINKIS_PACKAGE} to $LINKIS_HOME."
    cp -r $LINKIS_PACKAGE/* $LINKIS_HOME
    isSuccess "cp ${LINKIS_PACKAGE} to $LINKIS_HOME"
fi

cp ${LINKIS_CONFIG_PATH} $LINKIS_HOME/conf
cp ${LINKIS_DB_CONFIG_PATH} $LINKIS_HOME/conf

common_conf=$LINKIS_HOME/conf/linkis.properties

echo "======= Step 3: Create necessary directory =========="

echo "[WORKSPACE_USER_ROOT_PATH] try to create directory"
if [ "$WORKSPACE_USER_ROOT_PATH" != "" ]
then
  localRootDir=$WORKSPACE_USER_ROOT_PATH
  if [[ $WORKSPACE_USER_ROOT_PATH == file://* ]];then
    localRootDir=${WORKSPACE_USER_ROOT_PATH#file://}
    echo "[WORKSPACE_USER_ROOT_PATH] try to create local dir,cmd is: mkdir -p $localRootDir/$deployUser"
    mkdir -p $localRootDir/$deployUser
    sudo chmod -R 775 $localRootDir/$deployUser
  elif [[ $WORKSPACE_USER_ROOT_PATH == hdfs://* ]];then
    localRootDir=${WORKSPACE_USER_ROOT_PATH#hdfs://}
    echo "[WORKSPACE_USER_ROOT_PATH] try to create hdfs dir,cmd is: hdfs dfs -mkdir -p $localRootDir/$deployUser"
    hdfs dfs -mkdir -p $localRootDir/$deployUser
    hdfs dfs -chmod -R 775 $localRootDir/$deployUser
  else
    echo "[WORKSPACE_USER_ROOT_PATH] does not support $WORKSPACE_USER_ROOT_PATH filesystem types"
  fi
  isSuccess "create WORKSPACE_USER_ROOT_PATH: $WORKSPACE_USER_ROOT_PATH directory"
fi



########################  init hdfs and db  ################################
echo "[HDFS_USER_ROOT_PATH] try to create directory"
 if [ "$HDFS_USER_ROOT_PATH" != "" ]
 then
     localRootDir=$HDFS_USER_ROOT_PATH/bml
   if [[ $HDFS_USER_ROOT_PATH == file://* ]];then
     sed -i ${txt}  "s#wds.linkis.bml.is.hdfs.*#wds.linkis.bml.is.hdfs=false#g" $common_conf
     localRootDir=${localRootDir#file://}
     sed -i ${txt}  "s#\#wds.linkis.bml.local.prefix.*#wds.linkis.bml.local.prefix=$localRootDir#g" $common_conf
     echo "[HDFS_USER_ROOT_PATH] try to create local dir,cmd is: mkdir -p $localRootDir/$deployUser"
     mkdir -p $localRootDir/$deployUser
     sudo chmod -R 775 $localRootDir/$deployUser
   elif [[ $HDFS_USER_ROOT_PATH == hdfs://* ]];then
     localRootDir=${localRootDir#hdfs://}
     sed -i ${txt}  "s#\#wds.linkis.bml.hdfs.prefix.*#wds.linkis.bml.hdfs.prefix=$localRootDir#g" $common_conf
     echo "[HDFS_USER_ROOT_PATH] try to create hdfs dir,cmd is: hdfs dfs -mkdir -p $localRootDir/$deployUser"
     hdfs dfs -mkdir -p $localRootDir/$deployUser
   else
     echo "[HDFS_USER_ROOT_PATH] does not support $HDFS_USER_ROOT_PATH filesystem types"
   fi

   isSuccess "create HDFS_USER_ROOT_PATH: $HDFS_USER_ROOT_PATH directory"

 fi


echo "[RESULT_SET_ROOT_PATH] try to create directory"
 if [ "$RESULT_SET_ROOT_PATH" != "" ]
 then
   localRootDir=$RESULT_SET_ROOT_PATH
   if [[ $RESULT_SET_ROOT_PATH == file://* ]];then
     localRootDir=${RESULT_SET_ROOT_PATH#file://}
     echo "[RESULT_SET_ROOT_PATH] try to create local dir,cmd is: mkdir -p $localRootDir/$deployUser"
     mkdir -p $localRootDir/$deployUser

     # we should provide the permission to the user (not in deployUser group), otherwise the user can not read/write the result set
     sudo chmod -R 777 $localRootDir
     sudo chmod -R 775 $localRootDir/$deployUser
   elif [[ $RESULT_SET_ROOT_PATH == hdfs://* ]];then
     localRootDir=${RESULT_SET_ROOT_PATH#hdfs://}
     echo "[RESULT_SET_ROOT_PATH] try to create hdfs dir,cmd is: hdfs dfs -mkdir -p $localRootDir"
     hdfs dfs -mkdir -p $localRootDir
     hdfs dfs -chmod 775 $localRootDir
   else
     echo "[RESULT_SET_ROOT_PATH] does not support $RESULT_SET_ROOT_PATH filesystem types"
   fi

   isSuccess "create RESULT_SET_ROOT_PATH: $RESULT_SET_ROOT_PATH directory"

 fi


echo "======= Step 4: Create linkis table =========="
## sql init
if [ "$YARN_RESTFUL_URL" != "" ]
then
  sed -i ${txt}  "s#@YARN_RESTFUL_URL#$YARN_RESTFUL_URL#g" $LINKIS_HOME/db/linkis_dml.sql
fi

if [ "$HIVE_METASTORE_URIS" != "" ]
then
  sed -i ${txt} "s#@HIVE_METASTORE_URIS#$HIVE_METASTORE_URIS#g" $LINKIS_HOME/db/linkis_dml.sql
fi

if [ "$HADOOP_VERSION" != "" ]
then
  sed -i ${txt}  "s#@HADOOP_VERSION#$HADOOP_VERSION#g" $LINKIS_HOME/db/linkis_dml.sql
fi

if [ "$YARN_AUTH_ENABLE" != "" ]
then
  sed -i ${txt}  "s#@YARN_AUTH_ENABLE#$YARN_AUTH_ENABLE#g" $LINKIS_HOME/db/linkis_dml.sql
  sed -i ${txt}  "s#@YARN_AUTH_USER#$YARN_AUTH_USER#g" $LINKIS_HOME/db/linkis_dml.sql
  sed -i ${txt}  "s#@YARN_AUTH_PWD#$YARN_AUTH_PWD#g" $LINKIS_HOME/db/linkis_dml.sql
else
  sed -i ${txt}  "s#@YARN_AUTH_ENABLE#false#g" $LINKIS_HOME/db/linkis_dml.sql
fi


if [ "$YARN_KERBEROS_ENABLE" != "" ]
then
  sed -i ${txt}  "s#@YARN_KERBEROS_ENABLE#$YARN_KERBEROS_ENABLE#g" $LINKIS_HOME/db/linkis_dml.sql
  sed -i ${txt}  "s#@YARN_PRINCIPAL_NAME#$YARN_PRINCIPAL_NAME#g" $LINKIS_HOME/db/linkis_dml.sql
  sed -i ${txt}  "s#@YARN_KEYTAB_PATH#$YARN_KEYTAB_PATH#g" $LINKIS_HOME/db/linkis_dml.sql
  sed -i ${txt}  "s#@YARN_KRB5_PATH#$YARN_KRB5_PATH#g" $LINKIS_HOME/db/linkis_dml.sql
else
  sed -i ${txt}  "s#@YARN_KERBEROS_ENABLE#false#g" $LINKIS_HOME/db/linkis_dml.sql
fi

SERVER_IP=$local_host

##Label set start
if [ "$SPARK_VERSION" != "" ]
then
  sed -i ${txt}  "s#spark-2.4.3#spark-$SPARK_VERSION#g" $LINKIS_HOME/db/linkis_dml.sql
  sed -i ${txt}  "s#\#wds.linkis.spark.engine.version.*#wds.linkis.spark.engine.version=$SPARK_VERSION#g" $common_conf
fi

if [ "$HIVE_VERSION" != "" ]
then
  sed -i ${txt}  "s#hive-2.3.3#hive-$HIVE_VERSION#g" $LINKIS_HOME/db/linkis_dml.sql
  sed -i ${txt}  "s#\#wds.linkis.hive.engine.version.*#wds.linkis.hive.engine.version=$HIVE_VERSION#g" $common_conf
fi

if [ "$PYTHON_VERSION" != "" ]
then
  sed -i ${txt}  "s#python-python2#python-$PYTHON_VERSION#g" $LINKIS_HOME/db/linkis_dml.sql
  sed -i ${txt}  "s#\#wds.linkis.python.engine.version.*#wds.linkis.python.engine.version=$PYTHON_VERSION#g" $common_conf
fi

echo "Linkis mysql DB will use this config: $MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB"

if test -z "$MYSQL_INSTALL_MODE"
then
  MYSQL_INSTALL_MODE=1
fi

##Label set end

#Deal special symbol '#'
HIVE_META_PASSWORD=$(echo ${HIVE_META_PASSWORD//'#'/'\#'})
MYSQL_PASSWORD=$(echo ${MYSQL_PASSWORD//'#'/'\#'})

#init db
if [[ '2' = "$MYSQL_INSTALL_MODE" ]];then
  # check mysql ready
  until mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD  -e ";" ; do
       echo "try to connect to linkis mysql $MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB failed, please check db configuration in:$LINKIS_DB_CONFIG_PATH"
       exit 1
  done

  mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD --default-character-set=utf8 -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DB DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
  ddl_result=`mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD -D$MYSQL_DB  --default-character-set=utf8 -e "source ${LINKIS_HOME}/db/linkis_ddl.sql;" 2>&1`
  # Check ddl-sql execution result
  if [[ $? -ne 0 || $ddl_result =~ "ERROR" ]];then
      echoErrMsgAndExit "$ddl_result"
  else
      echoSuccessMsg "source linkis_ddl.sql"
  fi

  dml_result=`mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD -D$MYSQL_DB  --default-character-set=utf8 -e "source ${LINKIS_HOME}/db/linkis_dml.sql;" 2>&1`
  # Check dml-sql execution result
  if [[ $? -ne 0 || $dml_result =~ "ERROR" ]];then
      echoErrMsgAndExit "$dml_result"
  else
      echoSuccessMsg "source linkis_dml.sql"
  fi

  echo "Rebuild the table"
fi
###########################################################################


#Deal common config
echo ""
echo "======= Step 5: Update config =========="

if test -z "$EUREKA_INSTALL_IP"
then
  export EUREKA_INSTALL_IP=$SERVER_IP
fi

if test -z "$EUREKA_URL"
then
  export EUREKA_URL=http://$EUREKA_INSTALL_IP:$EUREKA_PORT/eureka/
fi

if test -z "$GATEWAY_INSTALL_IP"
then
  export GATEWAY_INSTALL_IP=$SERVER_IP
fi

currentTime=`date +%Y%m%d%H%M%S`

##eureka
sed -i ${txt}  "s#defaultZone:.*#defaultZone: $EUREKA_URL#g" $LINKIS_HOME/conf/application-eureka.yml
sed -i ${txt}  "s#port:.*#port: $EUREKA_PORT#g" $LINKIS_HOME/conf/application-eureka.yml
sed -i ${txt}  "s#linkis.app.version:.*#linkis.app.version: $LINKIS_VERSION-$currentTime#g" $LINKIS_HOME/conf/application-eureka.yml

##server application.yml
sed -i ${txt}  "s#defaultZone:.*#defaultZone: $EUREKA_URL#g" $LINKIS_HOME/conf/application-linkis.yml
sed -i ${txt}  "s#linkis.app.version:.*#linkis.app.version: $LINKIS_VERSION-$currentTime#g" $LINKIS_HOME/conf/application-linkis.yml

sed -i ${txt}  "s#defaultZone:.*#defaultZone: $EUREKA_URL#g" $LINKIS_HOME/conf/application-engineconn.yml
sed -i ${txt}  "s#linkis.app.version:.*#linkis.app.version: $LINKIS_VERSION-$currentTime#g" $LINKIS_HOME/conf/application-engineconn.yml

if [ "$EUREKA_PREFER_IP" == "true" ]; then
  sed -i ${txt}  "s/# prefer-ip-address:/prefer-ip-address:/g" $LINKIS_HOME/conf/application-eureka.yml

  sed -i ${txt}  "s/# prefer-ip-address:/prefer-ip-address:/g" $LINKIS_HOME/conf/application-linkis.yml
  sed -i ${txt}  "s/# instance-id:/instance-id:/g" $LINKIS_HOME/conf/application-linkis.yml

  sed -i ${txt}  "s/# prefer-ip-address:/prefer-ip-address:/g" $LINKIS_HOME/conf/application-engineconn.yml
  sed -i ${txt}  "s/# instance-id:/instance-id:/g" $LINKIS_HOME/conf/application-linkis.yml

  sed -i ${txt}  "s#linkis.discovery.prefer-ip-address.*#linkis.discovery.prefer-ip-address=true#g" $common_conf
fi

##server linkis-cli.properties
sed -i ${txt}  "s#wds.linkis.client.common.gatewayUrl.*#wds.linkis.client.common.gatewayUrl=http://$GATEWAY_INSTALL_IP:$GATEWAY_PORT#g" $LINKIS_HOME/conf/linkis-cli/linkis-cli.properties

echo "update conf $common_conf"
sed -i ${txt}  "s#wds.linkis.server.version.*#wds.linkis.server.version=$LINKIS_SERVER_VERSION#g" $common_conf
sed -i ${txt}  "s#wds.linkis.gateway.url.*#wds.linkis.gateway.url=http://$GATEWAY_INSTALL_IP:$GATEWAY_PORT#g" $common_conf
sed -i ${txt}  "s#linkis.discovery.server-address.*#linkis.discovery.server-address=http://$EUREKA_INSTALL_IP:$EUREKA_PORT#g" $common_conf
sed -i ${txt}  "s#wds.linkis.server.mybatis.datasource.url.*#wds.linkis.server.mybatis.datasource.url=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DB}?${MYSQL_PARAMS}#g" $common_conf
sed -i ${txt}  "s#wds.linkis.server.mybatis.datasource.username.*#wds.linkis.server.mybatis.datasource.username=$MYSQL_USER#g" $common_conf
sed -i ${txt}  "s#wds.linkis.server.mybatis.datasource.password.*#wds.linkis.server.mybatis.datasource.password=$MYSQL_PASSWORD#g" $common_conf
# hadoop config
sed -i ${txt}  "s#\#hadoop.config.dir.*#hadoop.config.dir=$HADOOP_CONF_DIR#g" $common_conf
#hive config
sed -i ${txt}  "s#\#hive.config.dir.*#hive.config.dir=$HIVE_CONF_DIR#g" $common_conf
sed -i ${txt} "/wds.linkis.server.user.restful.uri.pass.auth/c\wds.linkis.metadata.hive.db.admin=$HIVE_ADMIN_USER" $common_conf
sed -i ${txt} "/wds.linkis.server.user.restful.uri.pass.auth/c\linkis.metadata.hive.permission.with-login-user-enabled=true" $common_conf
#spark config
sed -i ${txt}  "s#\#spark.config.dir.*#spark.config.dir=$SPARK_CONF_DIR#g" $common_conf
#flink
sed -i ${txt} "/wds.linkis.python.engine.version/a\wds.linkis.flink.engine.version=$FLINK_VERSION" $common_conf


if [ "true" == "$HADOOP_KERBEROS_ENABLE" ]
then
  sed -i ${txt}  "s#\#wds.linkis.keytab.enable.*#wds.linkis.keytab.enable=true#g" $common_conf
  sed -i ${txt}  "s#\#wds.linkis.keytab.file.*#wds.linkis.keytab.file=$HADOOP_KEYTAB_PATH#g" $common_conf
fi


sed -i ${txt}  "s#wds.linkis.home.*#wds.linkis.home=$LINKIS_HOME#g" $common_conf

sed -i ${txt}  "s#wds.linkis.filesystem.root.path.*#wds.linkis.filesystem.root.path=$WORKSPACE_USER_ROOT_PATH#g" $common_conf
sed -i ${txt}  "s#wds.linkis.filesystem.hdfs.root.path.*#wds.linkis.filesystem.hdfs.root.path=$HDFS_USER_ROOT_PATH#g" $common_conf

if [ "$RESULT_SET_ROOT_PATH" != "" ]
then
  sed -i ${txt}  "s#wds.linkis.resultSet.store.path.*#wds.linkis.resultSet.store.path=$RESULT_SET_ROOT_PATH#g" $common_conf
fi

##gateway
gateway_conf=$LINKIS_HOME/conf/linkis-mg-gateway.properties
echo "update conf $gateway_conf"
if [ "$deployPwd" == "" ]
then
  deployPwd=`date +%s%N | md5sum |cut -c 1-9`
fi


sed -i ${txt}  "s#wds.linkis.ldap.proxy.url.*#wds.linkis.ldap.proxy.url=$LDAP_URL#g" $gateway_conf
sed -i ${txt}  "s#wds.linkis.ldap.proxy.baseDN.*#wds.linkis.ldap.proxy.baseDN=$LDAP_BASEDN#g" $gateway_conf
sed -i ${txt}  "s#wds.linkis.ldap.proxy.userNameFormat.*#wds.linkis.ldap.proxy.userNameFormat=$LDAP_USER_NAME_FORMAT#g" $gateway_conf
sed -i ${txt}  "s#wds.linkis.admin.user.*#wds.linkis.admin.user=$deployUser#g" $gateway_conf
sed -i ${txt}  "s#\#wds.linkis.admin.password.*#wds.linkis.admin.password=$deployPwd#g" $gateway_conf

if [ "$GATEWAY_PORT" != "" ]
then
  sed -i ${txt}  "s#spring.server.port.*#spring.server.port=$GATEWAY_PORT#g" $gateway_conf
fi
sed -i ${txt}  "s#spring.eureka.instance.metadata-map.linkis.conf.version.*#spring.eureka.instance.metadata-map.linkis.conf.version=$LINKIS_VERSION-$currentTime#g" $gateway_conf

manager_conf=$LINKIS_HOME/conf/linkis-cg-linkismanager.properties
if [ "$MANAGER_PORT" != "" ]
then
  sed -i ${txt}  "s#spring.server.port.*#spring.server.port=$MANAGER_PORT#g" $manager_conf
fi
sed -i ${txt}  "s#spring.eureka.instance.metadata-map.linkis.conf.version.*#spring.eureka.instance.metadata-map.linkis.conf.version=$LINKIS_VERSION-$currentTime#g" $manager_conf

# ecm install
ecm_conf=$LINKIS_HOME/conf/linkis-cg-engineconnmanager.properties
if test -z $ENGINECONN_ROOT_PATH
then
  ENGINECONN_ROOT_PATH=$LINKIS_HOME/engineroot
fi

sed -i ${txt}  "s#wds.linkis.engineconn.root.dir.*#wds.linkis.engineconn.root.dir=$ENGINECONN_ROOT_PATH#g" $ecm_conf

if [ ! -d $ENGINECONN_ROOT_PATH ] ;then
    echo "create dir ENGINECONN_ROOT_PATH: $ENGINECONN_ROOT_PATH"
    mkdir -p $ENGINECONN_ROOT_PATH
fi
sudo chmod -R 777 $ENGINECONN_ROOT_PATH

if [ "$ENGINECONNMANAGER_PORT" != "" ]
then
  sed -i ${txt}  "s#spring.server.port.*#spring.server.port=$ENGINECONNMANAGER_PORT#g" $ecm_conf
fi

sed -i ${txt}  "s#spring.eureka.instance.metadata-map.linkis.conf.version.*#spring.eureka.instance.metadata-map.linkis.conf.version=$LINKIS_VERSION-$currentTime#g" $ecm_conf

entrance_conf=$LINKIS_HOME/conf/linkis-cg-entrance.properties
if [ "$ENTRANCE_PORT" != "" ]
then
  sed -i ${txt}  "s#spring.server.port.*#spring.server.port=$ENTRANCE_PORT#g" $entrance_conf
fi

sed -i ${txt}  "s#spring.eureka.instance.metadata-map.linkis.conf.version.*#spring.eureka.instance.metadata-map.linkis.conf.version=$LINKIS_VERSION-$currentTime#g" $entrance_conf

if [ "$RESULT_SET_ROOT_PATH" != "" ]
then
  sed -i ${txt}  "s#wds.linkis.resultSet.store.path.*#wds.linkis.resultSet.store.path=$RESULT_SET_ROOT_PATH#g" $entrance_conf
fi

publicservice_conf=$LINKIS_HOME/conf/linkis-ps-publicservice.properties
if [ "$PUBLICSERVICE_PORT" != "" ]
then
  sed -i ${txt}  "s#spring.server.port.*#spring.server.port=$PUBLICSERVICE_PORT#g" $publicservice_conf
fi

sed -i ${txt}  "s#spring.eureka.instance.metadata-map.linkis.conf.version.*#spring.eureka.instance.metadata-map.linkis.conf.version=$LINKIS_VERSION-$currentTime#g" $publicservice_conf

echo "update conf $publicservice_conf"
if [ "$HIVE_META_URL" != "" ]
then
  sed -i ${txt}  "s#hive.meta.url.*#hive.meta.url=$HIVE_META_URL#g" $publicservice_conf
fi
if [ "$HIVE_META_USER" != "" ]
then
  sed -i ${txt}  "s#hive.meta.user.*#hive.meta.user=$HIVE_META_USER#g" $publicservice_conf
fi
if [ "$HIVE_META_PASSWORD" != "" ]
then
  HIVE_META_PASSWORD=$(echo ${HIVE_META_PASSWORD//'#'/'\#'})
  sed -i ${txt}  "s#hive.meta.password.*#hive.meta.password=$HIVE_META_PASSWORD#g" $publicservice_conf
fi

##Eanble prometheus for monitoring
if [ "true" == "$PROMETHEUS_ENABLE" ]
then
  echo "prometheus is enabled"
  sed -i ${txt}  "s#\#wds.linkis.prometheus.enable.*#wds.linkis.prometheus.enable=true#g" $common_conf
  sed -i ${txt}  's#include: refresh,info.*#include: refresh,info,health,metrics,prometheus#g' $LINKIS_HOME/conf/application-linkis.yml
  sed -i ${txt}  's#include: refresh,info.*#include: refresh,info,health,metrics,prometheus#g' $LINKIS_HOME/conf/application-eureka.yml
  sed -i ${txt}  's#include: refresh,info.*#include: refresh,info,health,metrics,prometheus#g' $LINKIS_HOME/conf/application-engineconn.yml
fi

echo "preveliges linkis command shells"
sudo chmod -R 777 $LINKIS_HOME/bin/*
sudo chmod -R 777 $LINKIS_HOME/sbin/*

echo -e "\n"

echo -e "${GREEN}Congratulations!${NC} You have installed Linkis $LINKIS_VERSION successfully, please use sh $LINKIS_HOME/sbin/linkis-start-all.sh to start it!"
echo -e "Your default account/password is ${GREEN}[$deployUser/$deployPwd]${NC}, you can find in $LINKIS_HOME/conf/linkis-mg-gateway.properties"
