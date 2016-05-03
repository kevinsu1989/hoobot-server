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
          A . *, B.server AS delivery_server, C.command
      FROM
          task A
              LEFT JOIN
          delivery_server B ON A.target = B.uuid
              LEFT JOIN
          project C ON A.project_id = C.id
      WHERE
          A.id = #{task_id}"

    @execute sql, (err, data)-> cb err, data && data[0]

  #获取指定ID的任务
  getPreviewTasks: (cb)->
    sql = "SELECT
          A . *, B.server AS delivery_server, C.command
      FROM
          task A
              LEFT JOIN
          delivery_server B ON A.target = B.uuid
              LEFT JOIN
          project C ON A.project_id = C.id
      WHERE
          A.id in (
            SELECT release_task_id FROM project D WHERE D.id in (
              SELECT project_id FROM project_page E GROUP BY project_id
          ))"

    @execute sql, (err, data)-> cb err, data

  #获取最前的Task，每个项目只取最新一条，一个项目多次build没有意义
  getForemostTask: (cb)->
    sql = "
            SELECT
          C . *, D.server AS delivery_server
      FROM
          (SELECT
              project_id,
                  (SELECT
                          id
                      FROM
                          task X
                      WHERE
                          X.status = #{_enum.TaskStatus.Created}
                              AND X.project_id = A.project_id
                              AND X.type = 'preview'
                      ORDER BY X.id DESC
                      LIMIT 1) AS task_id
          FROM
              task A
          WHERE
              A.status = 1 AND A.type = 'preview'
          GROUP BY project_id) B
              LEFT JOIN
          task C ON B.task_id = C.id
              LEFT JOIN
          delivery_server D ON C.target = D.uuid
      ORDER BY C.id ASC
      LIMIT 1"

    @execute sql, (err, result)->
      return cb err if err
      task = if result.length >= 0 then result[0] else undefined
      cb err, task

  #获取所有的项目，并按最近提交的排序
  getAllProject: (cond,cb)->
    sql = "SELECT
          C . *,
          (SELECT
                  COUNT(*)
              FROM
                  active_task
              WHERE
                  active_task.project_id = C.project_id) AS active_task_total
      FROM
          (SELECT
              project_id,
                  (SELECT
                          id
                      FROM
                          task X
                      WHERE
                          X.project_id = A.project_id
                              AND X.type = 'preview'
                      ORDER BY X.status DESC , X.timestamp DESC
                      LIMIT 1) AS task_id
          FROM
              task A
          WHERE
              A.type = 'preview'"

    sql += " AND repos LIKE '%#{cond.git_username}%' " if cond.git_username

    sql += "GROUP BY project_id) B
              LEFT JOIN
          task C ON B.task_id = C.id
      ORDER BY C.last_execute ASC"
    
    @execute sql, cb

module.exports = new Task