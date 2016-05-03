_path = require 'path'
_async = require 'async'
_fs = require 'fs-extra'

_utils = require '../utils'

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

  _utils.execCommandWithTask command, (err)->
    buildCommand = "cd #{reposProjectDir} && "
    if _fs.existsSync _path.join(reposProjectDir, '.hoobot')
      config = JSON.parse _fs.readFileSync(_path.join(reposProjectDir, '.hoobot'), 'utf-8')
      # projectName = config.projectName
      # buildTarget = _path.join(_utils.tempDirectory(), 'repos', config.buildTarget)
      buildCommand += config.command
    else
      buildCommand += task.command || "silky build -o \"#{buildTarget}\" -e #{env}"
      buildCommand += " -i #{task.page_id} " if task.page_id
    console.log buildCommand
    command =
      command: buildCommand
      task: task
      description: '执行构建脚本'
    _utils.execCommandWithTask command, cb

