_path = require 'path'
_async = require 'async'
_fs = require 'fs-extra'

_utils = require '../utils'

_request = require 'request'

#执行构建
exports.execute = (task, cb)->
  projectName =  _utils.extractProjectName(task.repos)
  #本地仓库的目录
  reposProjectDir = _utils.reposDireectory projectName
  #构建的目标目录
  buildTarget = _utils.buildDireectory projectName
  # if task.type is 'editor'
  #   buildTarget = _utils.editorPreviewDirectory task.data_hash
  #shell脚本的位置

  env = if task.type is 'preview' then 'preview' else 'production'
  shellFile = _path.join __dirname, '..', 'shell', 'build.sh'
  commandText = "sh '#{shellFile}' '#{task.repos}' '#{reposProjectDir}' '#{buildTarget}' '#{task.hash}'"
  command =
    command: commandText
    task: task
    description: '执行构建脚本'
  build = ()->
      buildCommand = "cd #{reposProjectDir} && "
      if _fs.existsSync _path.join(reposProjectDir, '.hoobot')
        config = JSON.parse _fs.readFileSync(_path.join(reposProjectDir, '.hoobot'), 'utf-8')
        # projectName = config.projectName
        # buildTarget = _path.join(_utils.tempDirectory(), 'repos', config.buildTarget)
        buildCommand += config.command
      else
        buildCommand += task.command || "silky build -o \"#{buildTarget}\" -e #{env}"
        buildCommand += " -x #{task.hash.substr(0,8)}" if env is 'preview'
        buildCommand += " -i #{task.page_id} " if task.page_id
      # console.log buildCommand
      command =
        command: buildCommand
        task: task
        description: '执行构建脚本'
      _utils.execCommandWithTask command, (err)->
        cb err, null

  _utils.execCommandWithTask command, (err)->
    if _fs.existsSync _path.join(reposProjectDir, 'package.json')
      pkg = JSON.parse _fs.readFileSync(_path.join(reposProjectDir, 'package.json'), 'utf-8')
      console.log pkg
      if pkg.hoobot
        _request.post {url: "#{pkg.hoobot.server}:1518/api/app", form: task}, (err, res, result)->
          if err
            _utils.writeTaskLog task, err
            console.log err
          else
            _utils.writeTaskLog task, "任务完成"
            console.log "任务完成"
          
        cb null, pkg.hoobot.server
      else
        build()
    else
      build()
     

