#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 12/29/14 6:01 PM
#    Description:

_path = require("path")
_bijou = require("bijou")
_ = require 'lodash'
_async = require 'async'
_fs = require 'fs-extra'

_config = require './config'
_supervisor = require './biz/supervisor'


#初始化bijou
initBijou = (app)->
  options =
    log: process.env.DEBUG
    #指定数据库链接
    database: _config.database
    #指定路由的配置文件
    routers: []
  _bijou.initalize(app, options)

  queue = []
  queue.push(
    (done)->
      #扫描schema，并初始化数据库
      schema = _path.join __dirname, './schema'
      _bijou.scanSchema schema, done
  )


  _async.waterfall queue, (err)->
    console.log err if err
    console.log 'Hoobot Server is running now!'


module.exports = (app)->
  #初始化bijou
  initBijou app
  #初始化路由
  require('./router').init(app)
  _supervisor.execute()





