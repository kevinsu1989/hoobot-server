#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 1/4/15 3:22 PM
#    Description:

_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_ = require 'lodash'
_enum = require '../enumerate'

class Task extends _BaseEntity
  constructor: ()->
    super require('../schema/task').schema

  #获取指定ID的任务
  getTaskById: (task_id, cb)->
    sql = "SELECT
          A . *
      FROM
          task A
      WHERE
          A.id = #{task_id}"

    @execute sql, (err, data)-> cb err, data && data[0]


  #获取最前的Task，每个项目只取最新一条，一个项目多次build没有意义
  getForemostTask: (cb)->
    sql = "
        SELECT * FROM task 
        WHERE
          status = #{_enum.TaskStatus.Created}
          ORDER BY id ASC
        LIMIT 1"

    @execute sql, (err, result)->
      return cb err if err
      task = if result.length >= 0 then result[0] else undefined
      cb err, task


module.exports = new Task