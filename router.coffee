#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 12/29/14 6:01 PM
#    Description: 路由配置
_http = require('bijou').http
_ = require 'lodash'
_fs = require 'fs-extra'

_utils = require './utils'
_config = require './config'
_api = require './biz/api'


release = (req, res, next)->
  _api.release req.body, -> 
  _http.responseJSON null, null, res


deployByEditor = (req, res, next)->
  _api.deployByEditor req.body, -> 
  _http.responseJSON null, null, res
  




exports.init = (app)->

  app.post '/api/release', release

  app.post '/api/deploy', deployByEditor

