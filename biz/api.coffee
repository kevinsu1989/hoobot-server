#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 1/4/15 10:07 AM
#    Description: 处理githook
_async = require 'async'
_http = require('bijou').http
_ = require 'lodash'

_entity = require '../entity'
_supervisor = require './supervisor'
_utils = require '../utils'
_enum = require '../enumerate'
_config = require '../config'


#发布
exports.release = (data, cb)->
  queue = []
  task_id = 0

  #检查token是否一致
  if data.token isnt _config.release.token
    err = _http.notAcceptableError('您的授权码输入有误，三次连续输入错误服务器将会自爆')
    return cb err

  #第一步，检测是否在任务当中
  queue.push(
    (done)->
      cond =
        type: 'release'
        hash: data.commit_id

      _entity.task.findOne cond, (err, result)->
        return done err if err
        task_id = result.id if result

        #不需要更改状态
        return done err if result?.status is _enum.TaskStatus.Created

        updateData = status: _enum.TaskStatus.Created
        _entity.task.updateById task_id, updateData, (err)-> done err
  )

  #可能需要创建任务
  queue.push(
    (done)->
      return done null if task_id
      taskData =
        project_id: data.project_id
        hash: data.commit_id
        tag: data.name
        message: data.commit_message
        email: data.committer_email
        timestamp: new Date(data.committed_date).valueOf()
        status: _enum.TaskStatus.Created
        repos: data.ssh_git
        type: 'release'

      _entity.task.save taskData, (err, id)->
        task_id = id
        done err
  )

  #执行任务
  queue.push(
    (done)->
      if _supervisor.runningTask
        err = _http.notAcceptableError("其它任务正在运行中，请稍候再试")
        return done err

      done null
  )

  _async.waterfall queue, (err)->
    cb err, task_id
    _supervisor.runTask task_id if not err


#发布
exports.previewByEditor = (data, cb)->
  _supervisor.runTaskFromEditor data, cb


exports.deployByEditor = (data, cb)->
  _supervisor.deployFromEditor data, cb

