#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 1/19/15 10:17 AM
#    Description:

exports.schema =
  name: 'project'
  fields:
    #仓库名
    repos_name: {type: 'string', index: true}
    #仓库地址
    repos_git: ''
    #仓库的url
    repos_url: ''
    #读取api的token
    token: ''
    #最后的执行时间
    timestamp: 'bigInteger'
    #发布时将要执行的命令，默认会执行silky build
    command: 'text'
    #gitlab的username
    git_username: 'text'