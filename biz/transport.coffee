#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 1/4/15 4:32 PM
#    Description: 处理http请求相关

_url = require 'url'
_http = require 'http'
_qs = require 'querystring'
_request = require 'request'
_fs = require 'fs-extra'
_ = require 'lodash'
_path = require 'path'

_utils = require '../utils'
_config = require '../config'


#分发tarboll到目标服务器
exports.deliverProject = (tarfile, projectName, task, cb)->
  #先从项目的.silky/config.js中提取honey-preview的分发项目名
  projectConfigFile = _path.join _utils.reposDireectory(projectName), '.silky', 'config.js'

  if _fs.existsSync projectConfigFile
    projectConfig = require projectConfigFile
    pluginOptions = projectConfig.plugins?["honey-preview"] || {}
    projectName = pluginOptions.project_name || pluginOptions.projectName || projectName

  formData = project_name: projectName
  for key, value of task
    formData[key] = value if not (value in [undefined, null])

  formData.attachment = _fs.createReadStream tarfile

  options =
    url: task.delivery_server
    method: 'POST'
    json: true
    formData: formData

  _utils.emitRealLog(
    description: "开始分发到服务器#{task.target}"
    task: task
    type: 'delivery'
  )

  _utils.writeTaskLog task, "开始分发到服务器#{task.target}"

  exports.request options, (err, res, body)->
    description = '分发完成'
    if err
      description += "，但递送到代理服服务器发生错误"
    else if res and res.statusCode isnt 200
      description += "，但服务器返回状态码不正确->#{res.statusCode}"

    _utils.emitRealLog 
      description: description
      task: task
      statusCode: res?.statusCode
      error: err
      responseBody: body
      type: 'delivery'

    _utils.writeTaskLog task, description

    return cb err if err
    if res.statusCode isnt 200
      # console.log res
      err = new Error('代理服务器返回状态码不正确，请检查')
      return cb err

    #检查接收服务器，是否返回了success: true
    cb err, body.success



#请求服务器
exports.request = (options, cb)->
  defaultOptions =
    timeout: 1000 * 5
    method: 'GET'

  ops = _.extend defaultOptions, options
  _request ops, cb