#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 1/4/15 4:53 PM
#    Description:

_async = require 'async'

_entity = require '../entity'
_enum = require('../enumerate').TaskStatus
_build = require './build'
_transport = require './transport'
_delivery = require './delivery'
_utils = require '../utils'
#_release = require './release'
_config = require '../config'

_request = require 'request'

class Labor
  isRunning: false
  runningTask: null
  #constructor: ()->

  #执行任务
  executeTask: (task, cb)->
    self = @
    queue = []

    #执行build操作
    queue.push(
      (done)-> _build.execute task, done
    )

    #执行分发，如果是编辑触发的preview的话，则不分发
    queue.push(
      (server, done)->
        if server is null
          _delivery.execute task, (err)-> done err
        else  
          done null
    )

#    #提交到svn，如果是release的话
#    queue.push(
#      (done)->
#        return done null if task.type isnt 'release'
#        _release.execute task, done
#    )

    # 更新活动服务器
    # queue.push(
    #   (done)->
    #     return done null if task.type is 'editor'
    #     _entity.active_task.updateActiveTask task.project_id, task.target, task.type, task.hash, done
    # )

    _async.waterfall queue, (err)->
      console.log err if err
      task.status = if err then _enum.Failure else _enum.Success
      self.finishTask task, (otherErr)-> cb(err || otherErr)

  #完成任务的操作
  finishTask: (task, cb)->
    self = @
    if task.type isnt 'editor'
      task.failure_counter++ if task.status isnt _enum.Success
      task.last_execute = new Date().valueOf()
      _entity.task.save task, (err)->
        _utils.emitEvent 'task:stop', task
        self.runningTask =  null
        cb err
    else
      cb null



  #获取任务，如果没有指定任务id，则获取最前一条
  getTask: (task_id, cb)->
    if task_id
      _entity.task.getTaskById task_id, cb
    else
      _entity.task.getForemostTask cb

  execute: (task_id, server_uuid)->
    return if @isRunning

    self = @
    @isRunning = true
    task = null
    queue = []

    #获取task
    queue.push(
      (done)->
        self.getTask task_id, (err, result)->
          task = result
          _utils.removeTaskLog task if task
          done err
    )

    #如果有指定server_uuid，则获取该server_uuid对应的任务
    queue.push(
      (done)->
        #
        if task
          task.delivery_server = _config.release.server 
          task.delivery_server = _config.preview.server if task.type is 'preview'
          return done null

        return done null if not (server_uuid and task)
    )

    _async.waterfall queue, (err)->
      if err
        message = "执行任务发生错误：#{err.message}"
        # _utils.emitRealLog message
        _utils.writeTaskLog task, message
        self.isRunning = false
        return

      #没有任务了
      if not task
        message = if task_id then "没有找到可执行的任务" else "所有任务都已经完成"
        # _utils.emitRealLog message
        self.isRunning = false
        return

      self.runningTask =  task
      _utils.emitEvent 'task:start', task

      _utils.emitRealLog (
        description: "提取任务执行"
        task: task
        type: 'task'
        process: 'start'
      )
      _utils.writeTaskLog task, "提取任务执行"
      #执行任务
      self.executeTask task, (err)->
        self.isRunning = false
        if err
          description = "任务执行失败"
          console.log JSON.stringify(err).red
        else
          description = "任务执行完成，成功分发至#{task.delivery_server}"

        if task.type is 'release'
          _entity.project.updateProjectAfterRelease task
          _request.post {url: _config.preview.api, form: task}, ->

        _utils.emitRealLog(
          description: description
          task: task
          type: 'task'
          success: !err
          process: 'end'
          error: err
        )
        
        _utils.writeTaskLog task, description
        #继续执行任务
        self.execute()


  executeByEditor: (data, cb)->
    self = @
    task = null
    queue = []

    #获取task
    queue.push(
      (done)->
        self.getTask data.task_id, (err, result)->
          task = result
          task.type = 'editor'
          task.delivery_server = _config.editor.deploy_server 
          task.data_hash = data.data_hash
          task.page_id = data.page_id
          task.preview_url = data.preview_url
          task.deploy_url = data.deploy_url
          task.host_url = data.host_url
          done err
    )
    #执行任务
    queue.push(
      (done)->
        #执行任务
        self.executeTask task, (err)->
          done err
    )

    _async.waterfall queue, (err)->
      data_cb = 
        task_id: task.data_hash
        #url: _utils.editorPreviewDirectory(task.data_hash, _config.previewPageName)
        success: err || true
        key: data.key

      #返回构建完成的消息给dollargan
      _request.post {url: _config.VRS.backUrl, form: data_cb}, ->

      cb err


exports.Labor = Labor

