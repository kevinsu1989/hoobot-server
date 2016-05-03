#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 12/29/14 5:08 PM
#    Description:
_path = require 'path'
_fs = require 'fs-extra'
_async = require 'async'
_events = require 'events'
_Convert = require('ansi-to-html')
_child = require('child_process')

_config = require './config'

_realEvent = new _events.EventEmitter()

#触发事件
exports.emitEvent = (name, args...)->
  _realEvent.emit.apply _realEvent, [name].concat(args)

#监听事件
exports.addListener = (event, listener)-> _realEvent.addListener event, listener

#监听
exports.removeListener = (event, listener)-> _realEvent.removeListener event, listener

exports.onRealLog = (cb)->
  _realEvent.addListener 'realLog', (log)-> cb?(log)

#触发实时的日志
exports.emitRealLog = (data)->
  _realEvent.emit 'realLog', data

exports.emitStream = (message)->
  message = message.replace(/\n/g, '<br />')
  message = exports.ansi2html message
  exports.emitEvent 'stream', message

exports.ansi2html = (message)->
  convert = new _Convert()
  message = convert.toHtml(message)

#移除扩展名
exports.removeExt = (filename)-> filename.replace /\.\w+/, ''

#从仓库名称中，提取项目的名称
exports.extractProjectName = (repos)->
  return '' if not repos
  repos.replace(/.+\/(.+)\.git$/, '$1')

#临时工作目录
exports.tempDirectory = -> _path.join(exports.homeDirectory(), '.hoobot')

#仓库的工作目录
exports.reposDireectory = (projectName)-> _path.join(exports.tempDirectory(), 'repos', projectName)

#silky的构建目录
exports.buildDireectory = (projectName)-> _path.join(exports.tempDirectory(), 'build', projectName)


#用于存放打包的目录
exports.projectPackagePath = (projectName)-> _path.join(exports.tempDirectory(), 'tar', projectName + '.tar')

#获取项目的工作目录
exports.previewDirectory = ->
  _path.resolve __dirname, _config.previewDirectory


#获取编辑预览的目录
exports.editorPreviewDirectory = (hash, pageName)-> 
  return _path.resolve(__dirname, _config.previewDirectory, hash, pageName) if typeof(pageName) is 'string'

  _path.resolve __dirname, _config.previewDirectory, hash

#获取svn的工作目录
exports.svnDirectory = (projectName)->
  _path.resolve __dirname, _config.svnDirectory, projectName

#用户的home目录
exports.homeDirectory = ->
  process.env[if process.platform is 'win32' then 'USERPROFILE' else 'HOME']

#如果目录存在，则清除
exports.cleanTarget = (target)->
  return if not _fs.existsSync target
  _fs.removeSync target

#执行命令，返回结果以及错误
exports.execCommand = (command, cb)->
  options =
    env: process.env
    maxBuffer: 20*1024*1024
  message = ''
  error = ''

  exec = _child.exec command, options
  exec.on 'close', (code)->
    cb code, message, error

  exec.stdout.on 'data',  (chunk)-> message += chunk + '\n'
  exec.stderr.on 'data', (chunk)->  error += chunk + '\n'

exports.execCommand = (command)->
  options =
    env: process.env
    maxBuffer: 20*1024*1024

  exec = _child.exec command.command, options


#批量执行命令，遇到问题即返回
exports.execCommandWithTask = (command, cb)->
  options =
    env: process.env
    maxBuffer: 20*1024*1024

  console.log command.command
  console.log command.description
  exports.writeTaskLog command.task, command.command
  exports.writeTaskLog command.task, command.description

  exec = _child.exec command.command, options
  exec.on 'close', (code)->
    err = null
    data =
      command: command.command
      success: code is 0
      type: 'command'
      task: command.task
      description: command.description

    err = "任务发生错误，执行失败" if not data.success
    #推送实时的日志
    # exports.emitRealLog data
    cb err

  exec.stdout.on 'data', (message)->
    console.log message
    exports.writeTaskLog command.task, message

  exec.stderr.on 'data', (message)->
    console.log message.red
    exports.writeTaskLog command.task, message

#批量执行命令
exports.execCommandsWithTask = (items, cb)->
  index = 0
  _async.whilst(
    -> index < items.length
    ((done)->
      item = items[index++]
#      data =
#        type: 'log'
#        description: "正在#{item.description}..."
#        task: item.task
#
#      exports.emitRealLog data
      exports.execCommandWithTask item, done
    ), cb
  )

#从git commit message中提取指令
exports.extractCommandFromGitMessage = (message)->
  pattern = /#(p|push|preview)\-(.+?)\s/i
  return if not message
  matches = message.match pattern
  return if not matches
  return type: matches[1], target: matches[2]

exports.writeTaskLog = (task, log)->
  _fs.appendFile _path.join(_config.logsDirectory, task.hash), (log + '\n')

exports.removeTaskLog = (task)->
  _fs.removeSync _path.join(_config.logsDirectory, task.hash)

#读取文件
exports.readFile = (file)-> _fs.readFileSync file, 'utf-8'
#保存文件
exports.writeFile = (file, content)-> _fs.outputFileSync file, content

