#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 1/19/15 11:50 AM
#    Description:

_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_ = require 'lodash'

class Project extends _BaseEntity
  constructor: ()->
    super require('../schema/project').schema

  # fetch: (cond, cb)->
  #   sql = "SELECT * FROM project WHERE 1 = 1"
  #   cond = cond || {}
  #   sql += " AND repos_git LIKE '%honey-lab%'" if cond.honeyLabOnly
  #   @execute sql, cb

  # getGitUsers: (cb)->
  #   sql = "SELECT DISTINCT(git_username) FROM project"
  #   @execute sql, cb


  updateProjectAfterRelease: (task)->
    sql = "UPDATE project SET release_task_id = #{task.id} WHERE id=#{task.project_id}"
    console.log sql
    @execute sql, ()->

  getTaskByDataId: (page_id, cb)->
    sql = "SELECT 
            preview_url, deploy_url, 
            (SELECT release_task_id FROM project WHERE id = (SELECT project_id FROM project_page WHERE page_id=#{page_id})) AS task_id 
          FROM 
            project_page 
          WHERE 
            page_id=#{page_id}"

    @execute sql, cb

  getReleaseHashByGit: (git_id, cb)->
    sql = "SELECT A.hash as hash FROM
             task A LEFT JOIN project B
           ON
             A.project_id = B.id
           WHERE
             B.git_id = '#{git_id}' 
    "
    @execute sql, cb





module.exports = new Project
