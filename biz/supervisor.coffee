#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 1/4/15 4:06 PM
#    Description: 执行队列任务

_entity = require '../entity'
_Labor = require('./labor').Labor
_labor = new _Labor()

#执行队列任务
exports.execute = ->
  _labor.execute()

#强行执行某个任务，必需没有任务执行
exports.runTask = (task_id, server_uuid)->
  return false if _labor.isRunning
  _labor.execute task_id, server_uuid
  return true


exports.deployFromEditor = (data, cb)->
  _entity.project.getTaskByDataId data.page_id,(err, result)->

    _labor.executeByEditor {
      task_id: result[0].task_id
      preview_url: result[0].preview_url
      deploy_url: result[0].deploy_url
      host_url: data.url
      data_hash: data.hashKey
      page_id: data.page_id
      key: data.key
    }, ()->

  cb true

# exports.runningTask = _labor.runningTask