#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 1/4/15 3:04 PM
#    Description: 分发到目标服务器
_path = require 'path'
_fs = require 'fs-extra'

_utils = require '../utils'
_transport = require './transport'

#远程分发
deliverProject = (source, projectName, task, cb)->
  tarFile = _utils.projectPackagePath projectName
  #确保文件夹存在
  _fs.ensureDirSync _path.dirname(tarFile)

  #打包文件
  command = {
    command: "cd #{source} && tar -cf #{tarFile} ."
    description: "对文件进行打包"
    task: task
  }
  console.log command
  _utils.execCommandWithTask command, (err)->
    return cb err if err
    #分发到服务器
    _transport.deliverProject tarFile, projectName, task, cb

exports.execute = (task, cb)->
  projectName = _utils.extractProjectName task.repos
  source = _utils.buildDireectory projectName
  reposProjectDir = _utils.reposDireectory projectName

  if _fs.existsSync _path.join(reposProjectDir, '.hoobot')
    config = JSON.parse _fs.readFileSync(_path.join(reposProjectDir, '.hoobot'), 'utf-8')
    projectName = config.projectName
    source = _path.join(reposProjectDir, config.buildTarget)
  deliverProject source, projectName, task, cb