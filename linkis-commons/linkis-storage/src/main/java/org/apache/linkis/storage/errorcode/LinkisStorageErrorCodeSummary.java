/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.linkis.storage.errorcode;

public enum LinkisStorageErrorCodeSummary {
  UNSUPPORTED_FILE(
      50000,
      "Unsupported file system type(不支持的文件系统类型)：{}",
      "Unsupported file system type(不支持的文件系统类型)：{}"),
  UNSUPPORTED_RESULT(
      50000, "Unsupported result type(不支持的结果类型)：{}", "Unsupported result type(不支持的结果类型)：{}"),
  CONFIGURATION_NOT_READ(
      50001,
      "HDFS configuration was not read, please configure hadoop.config.dir or add env:HADOOP_CONF_DIR(HDFS 配置未读取，请配置 hadoop.config.dir 或添加 env:HADOOP_CONF_DIR)",
      "HDFS configuration was not read, please configure hadoop.config.dir or add env:HADOOP_CONF_DIR(HDFS 配置未读取，请配置 hadoop.config.dir 或添加 env:HADOOP_CONF_DIR)"),
  FAILED_TO_READ_INTEGER(51000, "failed to read integer(读取整数失败)", "failed to read integer(读取整数失败)"),
  THE_FILE_IS_EMPTY(51000, "The file{}is empty(文件{}为空)", "The file{}is empty(文件{}为空)"),
  TO_BE_UNKNOW(51001, "", ""),
  FSN_NOT_INIT_EXCEPTION(52000, "FSNotInitException", "FSNotInitException"),
  PARSING_METADATA_FAILED(
      52001, "Parsing metadata failed(解析元数据失败)", "Parsing metadata failed(解析元数据失败)"),
  TABLE_ARE_NOT_SUPPORTED(
      52002,
      "Result sets that are not tables are not supported(不支持不是表格的结果集)",
      "Result sets that are not tables are not supported(不支持不是表格的结果集)"),
  MUST_REGISTER_TOC(
      52004,
      "You must register IOClient before you can use proxy mode.(必须先注册IOClient,才能使用代理模式)",
      "You must register IOClient before you can use proxy mode.(必须先注册IOClient,才能使用代理模式)"),
  MUST_REGISTER_TOM(
      52004,
      "You must register IOMethodInterceptorCreator before you can use proxy mode.(必须先注册IOMethodInterceptorCreator，才能使用代理模式)",
      "You must register IOMethodInterceptorCreator before you can use proxy mode.(必须先注册IOMethodInterceptorCreator，才能使用代理模式)"),
  UNSUPPORTED_OPEN_FILE_TYPE(
      54001, "Unsupported open file type(不支持打开的文件类型)", "Unsupported open file type(不支持打开的文件类型)"),
  INCALID_CUSTOM_PARAMETER(
      65000, "Invalid custom parameter(不合法的自定义参数)", "Invalid custom parameter(不合法的自定义参数)");

  /** 错误码 */
  private int errorCode;
  /** 错误描述 */
  private String errorDesc;
  /** 错误可能出现的原因 */
  private String comment;

  LinkisStorageErrorCodeSummary(int errorCode, String errorDesc, String comment) {
    this.errorCode = errorCode;
    this.errorDesc = errorDesc;
    this.comment = comment;
  }

  public int getErrorCode() {
    return errorCode;
  }

  public void setErrorCode(int errorCode) {
    this.errorCode = errorCode;
  }

  public String getErrorDesc() {
    return errorDesc;
  }

  public void setErrorDesc(String errorDesc) {
    this.errorDesc = errorDesc;
  }

  public String getComment() {
    return comment;
  }

  public void setComment(String comment) {
    this.comment = comment;
  }

  @Override
  public String toString() {
    return "errorCode: " + this.errorCode + ", errorDesc:" + this.errorDesc;
  }
}
