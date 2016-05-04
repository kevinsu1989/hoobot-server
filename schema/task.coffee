#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 1/4/15 9:46 AM
#    Description:

exports.schema =
  name: 'task'
  fields:
    #提交的hash
    hash: {type: 'string', index: true}
    #项目，对于到bhf的项目列表
    project_id: 'integer'
    #仓库的地址，eg. git:
    repos: 'text'
    #任务的类型
    type: {type: 'string', index: true}
    #任务的状态
    status: 'integer'