#    Author: 易晓峰
#    E-mail: wvv8oo@gmail.com
#    Date: 12/29/14 5:12 PM
#    Description:

module.exports =
  #默认的token
  gitlabToken: 'JxboEXSjxFU7F51HcZpe'
  release:
    #发布的服务器
    #server: 'http://10.1.172.104:1518/'
    server: 'http://127.0.0.1:1518/'
    #发布的验证密码
    token: 'stayfoolish'

  preview:
    #发布新release之后通知给preview服务器拉取新版本
    api: 'http://127.0.0.1:1519/api/release'
    server: 'http://127.0.0.1:1518/'

  editor:
    #编辑发布的接收服务器
    deploy_server: 'http://127.0.0.1:1518/'
    #接收服务器的发布路径
    deploy_path: '/data/data20/www/fcms'
    #生成的页面名称
    deploy_pageName: 'preview.html'
    
  VRS:
    #编辑发布成功后通知给dollargan
    backUrl: 'http://10.200.8.234:8301/api/deploycomplete'

  logsDirectory: './logs'
  #用于发布正式版，同步给运维的目录
  syncDirectory: './.hoobot/sync'
  #svn的目录(已经废弃，不再使用svn)
  svnDirectory: './.hoobot/svn'
  #部署项目的目录，可以是preview的部署，也可以是release的部署
  # previewDirectory: '/var/www/release'
  previewDirectory: '/Users/sukan/tmp'
  previewPageName: 'previewPage.html'
  #临时工作目录，用于clone临时文件
  tempDirectory: './.hoobot/repos'
  #代理临时的上传目录
  uploadTemporary: './.hoobot/uploadTemporary'
  #更新代理服务器状态的间隔，以分钟为单位
  updateAgentStatusInterval: 5
  bhf:
    #bhf的base url
    baseUrl: 'http://bhf.hunantv.com/api/'
    acccount:
      account: 'root'
      password: '+10086'
  database:
    client: 'mysql',
    connection:
      host     : '192.168.8.108',
      user     : 'root',
      password : '123456',
      database : 'hoobot_develop'
  redis:
    server: 'localhost'
    port: 6379
    database: 0
    unique: 'bhf-c63a6d217'
  port:
    delivery: 1517
    agent: 1518
    preview: 1519
    server:1521


    # NODE_ENV=production forever start -a -c coffee app.coffee -n hoobot-delivery
