#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 12/29/14 4:55 PM
#    Description:

_express = require 'express.io'
_http = require 'http'
_app = _express()
_path = require 'path'
_sysUtil = require 'util'
_redisStore = new require('connect-redis')(_express)
_app.http().io()
require 'shelljs/global'
require 'colors'
_utils = require './utils'
_config = require './config'

# console.log = (args...)->
#   message = _sysUtil.format.apply null, args
#   _utils.emitStream message

#   process.stdout.write message
#   process.stdout.write '\n'


_app.configure(()->
  _app.use(_express.methodOverride())
  _app.use(_express.bodyParser(
    uploadDir: _config.uploadTemporary
    limit: '1024mb'
    keepExtensions: true
  ))

  _app.use(_express.cookieParser())

  _app.set 'port', _config.port.delivery || 1520
)

require('./initialize')(_app)

_app.listen _app.get 'port'
console.log "Port: #{_app.get 'port'}, Now: #{new Date()}"



