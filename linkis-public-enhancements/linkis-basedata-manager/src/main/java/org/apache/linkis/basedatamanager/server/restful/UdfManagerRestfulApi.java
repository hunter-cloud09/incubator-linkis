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

package org.apache.linkis.basedatamanager.server.restful;

import org.apache.linkis.basedatamanager.server.domain.UdfManagerEntity;
import org.apache.linkis.basedatamanager.server.service.UdfManagerService;
import org.apache.linkis.server.Message;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.github.pagehelper.PageInfo;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;

@Api(tags = "UdfManagerRestfulApi")
@RestController
@RequestMapping(path = "/basedata-manager/udf-manager")
public class UdfManagerRestfulApi {

  @Autowired UdfManagerService udfManagerService;

  @ApiImplicitParams({
    @ApiImplicitParam(paramType = "query", dataType = "string", name = "searchName"),
    @ApiImplicitParam(paramType = "query", dataType = "int", name = "currentPage"),
    @ApiImplicitParam(paramType = "query", dataType = "int", name = "pageSize")
  })
  @ApiOperation(value = "list", notes = "get list data", httpMethod = "GET")
  @RequestMapping(path = "", method = RequestMethod.GET)
  public Message list(String searchName, Integer currentPage, Integer pageSize) {
    PageInfo pageList = udfManagerService.getListByPage(searchName, currentPage, pageSize);
    return Message.ok("").data("list", pageList);
  }

  @ApiImplicitParams({@ApiImplicitParam(paramType = "path", dataType = "long", name = "id")})
  @ApiOperation(value = "get", notes = "get data by id", httpMethod = "GET")
  @RequestMapping(path = "/{id}", method = RequestMethod.GET)
  public Message get(@PathVariable("id") Long id) {
    UdfManagerEntity errorCode = udfManagerService.getById(id);
    return Message.ok("").data("item", errorCode);
  }

  @ApiImplicitParams({
    @ApiImplicitParam(paramType = "body", dataType = "UdfManagerEntity", name = "errorCode")
  })
  @ApiOperation(value = "add", notes = "add data", httpMethod = "POST")
  @RequestMapping(path = "", method = RequestMethod.POST)
  public Message add(@RequestBody UdfManagerEntity errorCode) {
    boolean result = udfManagerService.save(errorCode);
    return Message.ok("").data("result", result);
  }

  @ApiImplicitParams({@ApiImplicitParam(paramType = "path", dataType = "long", name = "id")})
  @ApiOperation(value = "remove", notes = "remove data by id", httpMethod = "DELETE")
  @RequestMapping(path = "/{id}", method = RequestMethod.DELETE)
  public Message remove(@PathVariable("id") Long id) {
    boolean result = udfManagerService.removeById(id);
    return Message.ok("").data("result", result);
  }

  @ApiImplicitParams({
    @ApiImplicitParam(paramType = "body", dataType = "UdfManagerEntity", name = "errorCode")
  })
  @ApiOperation(value = "update", notes = "update data", httpMethod = "PUT")
  @RequestMapping(path = "", method = RequestMethod.PUT)
  public Message update(@RequestBody UdfManagerEntity errorCode) {
    boolean result = udfManagerService.updateById(errorCode);
    return Message.ok("").data("result", result);
  }
}
