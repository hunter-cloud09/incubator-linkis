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

package org.apache.linkis.metadata.ddl

import org.apache.linkis.common.utils.Logging
import org.apache.linkis.metadata.domain.mdq.bo.{MdqTableBO, MdqTableFieldsInfoBO}
import org.apache.linkis.metadata.exception.MdqIllegalParamException

import org.apache.commons.lang3.StringUtils

import scala.collection.JavaConverters._
import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer

object ScalaDDLCreator extends DDLCreator with SQLConst with Logging {

  override def createDDL(tableInfo: MdqTableBO, user: String): String = {
    logger.info(s"begin to generate ddl for user $user using ScalaDDLCreator")
    val dbName = tableInfo.getTableBaseInfo.getBase.getDatabase
    val tableName = tableInfo.getTableBaseInfo.getBase.getName
    val fields = tableInfo.getTableFieldsInfo
    val lifecycle: Integer = tableInfo.getTableBaseInfo.getModel.getLifecycle
    val tblPropInfo: String = tableInfo.getTableBaseInfo.getModel.getTblProperties
    val createTableCode = new mutable.StringBuilder
    createTableCode.append(SPARK_SQL).append(LEFT_PARENTHESES).append(MARKS)

    if (tableInfo.getTableBaseInfo.getModel.getExternalTable) {
      createTableCode.append(CREATE_EXTERNAL_TABLE)
    } else { createTableCode.append(CREATE_TABLE) }

    createTableCode.append(dbName).append(".").append(tableName)
    createTableCode.append(LEFT_PARENTHESES)
    val partitions = new ArrayBuffer[MdqTableFieldsInfoBO]()
    val fieldsArray = new ArrayBuffer[String]()
    fields.asScala foreach { field =>
      if (field.getPartitionField != null && field.getPartitionField == true) partitions += field
      else {
        val name = field.getName
        val _type = field.getType
        val desc = field.getComment
        if (StringUtils.isNotEmpty(desc)) {
          fieldsArray += (name + SPACE + _type + SPACE + COMMENT + SPACE + SINGLE_MARK + desc + SINGLE_MARK)
        } else {
          fieldsArray += (name + SPACE + _type)
        }
      }
    }
    createTableCode
      .append(fieldsArray.mkString(COMMA))
      .append(RIGHT_PARENTHESES)
      .append(SPACE)
      .append(ICEBERG_TYPE)
      .append(SPACE)
    if (partitions.nonEmpty) {
      val partitionArr = new ArrayBuffer[String]()
      partitions foreach { p =>
        val name = p.getName
        val _type = p.getType
        if (StringUtils.isEmpty(name) || StringUtils.isEmpty(_type)) {
          throw MdqIllegalParamException("partition name or type is null")
        }
        partitionArr += (name + SPACE + _type)
      }
      createTableCode
        .append(PARTITIONED_BY)
        .append(LEFT_PARENTHESES)
        .append(partitionArr.mkString(COMMA))
        .append(RIGHT_PARENTHESES)
        .append(SPACE)
    } else {
      throw MdqIllegalParamException("Partition field is not allowed to be empty")
    }
    // TBL-PROPERTIES
    val tabPropArray = new ArrayBuffer[String]()
    if (lifecycle != null && lifecycle > 0) {
      tabPropArray += ("'data.ttl'=" + SINGLE_MARK + lifecycle + SINGLE_MARK)
      val strings: Array[String] = tblPropInfo.split(COMMA)
      strings.foreach(kv => {
        val strings1: Array[String] = kv.split(EQ)
        tabPropArray += (SINGLE_MARK + strings1.apply(0) + SINGLE_MARK + EQ + SINGLE_MARK + strings1
          .apply(1) + SINGLE_MARK)
      })
    } else {
      if (tblPropInfo.nonEmpty) {
        val strings: Array[String] = tblPropInfo.split(COMMA)
        strings.foreach(kv => {
          val strings1: Array[String] = kv.split(EQ)
          tabPropArray += (SINGLE_MARK + strings1.apply(
            0
          ) + SINGLE_MARK + EQ + SINGLE_MARK + strings1
            .apply(1) + SINGLE_MARK)
        })
      }
    }
    if (tabPropArray.nonEmpty) {
      createTableCode
        .append(TBLPROPERTIES)
        .append(SPACE)
        .append(LEFT_PARENTHESES)
        .append(tabPropArray.mkString(","))
        .append(RIGHT_PARENTHESES)
        .append(SPACE)
    }

    if (StringUtils.isNotBlank(tableInfo.getTableBaseInfo.getBase.getComment)) {
      createTableCode
        .append(COMMENT)
        .append(SPACE)
        .append(SINGLE_MARK)
        .append(tableInfo.getTableBaseInfo.getBase.getComment)
        .append(SINGLE_MARK)
        .append(SPACE)
    }
    createTableCode.append(MARKS)
    createTableCode.append(RIGHT_PARENTHESES)
    val finalCode = createTableCode.toString()
    logger.info(s"End to create ddl code, code is $finalCode")
    finalCode
  }

}
