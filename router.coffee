#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 12/29/14 6:01 PM
#    Description: 路由配置
_http = require('bijou').http
_ = require 'lodash'
_fs = require 'fs-extra'
_path = require 'path'

_utils = require './utils'
_config = require './config'
_api = require './biz/api'


release = (req, res, next)->
  _api.release req.body, -> 

  logUrl = [req.headers.host, "logs", req.body.commit_id].join('/')
  
  _http.responseJSON null, {logs:logUrl}, res

preview = (req, res, next)->
  _api.preview req.body, -> 

  logUrl = [req.headers.host, "logs", req.body.commit_id].join('/')
  
  _http.responseJSON null, {logs:logUrl, preview:"http://10.200.8.234:12299/#{req.body.commit_id.substr(0,8)}"}, res

deployByEditor = (req, res, next)->
  _api.deployByEditor req.body, -> 
  _http.responseJSON null, null, res

  
getHashByGit = (req, res, next)->
  _api.getHashByGit req.params.git_id, (err, result)->
    _http.responseJSON err, result, res

exports.init = (app)->

  app.post '/api/release', release

  app.post '/api/preview', preview

  app.post '/api/deploy', deployByEditor

  app.get '/api/:git_id/release', getHashByGit

  app.get '/logs/:hash',(req, res, next)->
    res.sendfile _path.resolve(__dirname, _config.logsDirectory, req.params.hash)
