/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

UPDATE `linkis_ps_configuration_config_key` SET `default_value` = 'default' WHERE `key` = 'wds.linkis.rm.yarnqueue';
UPDATE `linkis_ps_configuration_config_key` SET `description` = '范围：-1-10000，单位：个', `default_value` = '-1', `validate_range` = '[-1,10000]' WHERE `key` = 'mapred.reduce.tasks';
DELETE FROM `linkis_ps_configuration_config_key` WHERE `key` IN ('dfs.block.size','hive.exec.reduce.bytes.per.reducer','wds.linkis.engineconn.max.free.time');
INSERT INTO `linkis_ps_configuration_config_key` (`key`, `description`, `name`, `default_value`, `validate_type`, `validate_range`, `is_hidden`, `is_advanced`, `level`, `treeName`, `engine_conn_type`) VALUES ('wds.linkis.jdbc.driver', '例如:org.apache.hive.jdbc.HiveDriver', 'jdbc连接驱动', '', 'None', '', '0', '0', '1', '用户配置', 'jdbc');

INSERT INTO `linkis_mg_gateway_auth_token`(`token_name`,`legal_users`,`legal_hosts`,`business_owner`,`create_time`,`update_time`,`elapse_day`,`update_by`) VALUES ('DSM-AUTH','*','*','BDP',curdate(),curdate(),-1,'LINKIS');
INSERT INTO `linkis_mg_gateway_auth_token`(`token_name`,`legal_users`,`legal_hosts`,`business_owner`,`create_time`,`update_time`,`elapse_day`,`update_by`) VALUES ('LINKIS_CLI_TEST','*','*','BDP',curdate(),curdate(),-1,'LINKIS');

INSERT INTO `linkis_ps_dm_datasource_type_key` (`data_source_type_id`, `key`, `name`, `name_en`, `default_value`, `value_type`, `scope`, `require`, `description`, `description_en`, `value_regex`, `ref_id`, `ref_value`, `data_source`, `update_time`, `create_time`) VALUES (1, 'driverClassName', '驱动类名(Driver class name)', 'Driver class name', 'com.mysql.cj.jdbc.Driver', 'TEXT', NULL, 1, '驱动类名(Driver class name)', 'Driver class name', NULL, NULL, NULL, NULL,  now(), now());
INSERT INTO `linkis_ps_dm_datasource_type_key` (`data_source_type_id`, `key`, `name`, `name_en`, `default_value`, `value_type`, `scope`, `require`, `description`, `description_en`, `value_regex`, `ref_id`, `ref_value`, `data_source`, `update_time`, `create_time`) VALUES (1, 'databaseName', '数据库名(Database name)', 'Database name', NULL, 'TEXT', NULL, 0, '数据库名(Database name)', 'Database name', NULL, NULL, NULL, NULL,  now(), now());

UPDATE `linkis_ps_dm_datasource_type_key` SET `name` = '主机名(Host)', `name_en` = 'Host', `description` = '主机名(Host)', `description_en` = 'Host' WHERE `key` = 'host';
UPDATE `linkis_ps_dm_datasource_type_key` SET `name` = '端口号(Port)', `name_en` = 'Port', `description` = '端口号(Port)', `description_en` = 'Port' WHERE `key` = 'port';
UPDATE `linkis_ps_dm_datasource_type_key` SET `name` = '连接参数(Connection params)', `name_en` = 'Connection params', `description` = '输入JSON格式(Input JSON format): {"param":"value"}', `description_en` = 'Input JSON format: {"param":"value"}' WHERE `key` = 'params';
UPDATE `linkis_ps_dm_datasource_type_key` SET `name` = '用户名(Username)', `name_en` = 'Username', `description` = '用户名(Username)', `description_en` = 'Username' WHERE `key` = 'username';
UPDATE `linkis_ps_dm_datasource_type_key` SET `name` = '密码(Password)', `name_en` = 'Password', `description` = '密码(Password)', `description_en` = 'Password' WHERE `key` = 'password';
UPDATE `linkis_ps_dm_datasource_type_key` SET `name` = '集群环境(Cluster env)', `name_en` = 'Cluster env', `description` = '集群环境(Cluster env)', `description_en` = 'Cluster env' WHERE `key` = 'envId';

UPDATE `linkis_ps_configuration_config_key` set `default_value` = 'com.mysql.cj.jdbc.Driver' WHERE `key` = 'wds.linkis.jdbc.driver';