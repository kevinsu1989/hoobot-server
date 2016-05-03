#    Author: 苏衎
#    E-mail: kevinsu1989@gmail.com
#    Date: 1/19/15 11:50 AM
#    Description:

_BaseEntity = require('bijou').BaseEntity
_async = require 'async'
_ = require 'lodash'

class ProjectData extends _BaseEntity
  constructor: ()->
    super require('../schema/project_page').schema

  insertOrUpdate: (list)->
    for item in list
      sql = "INSERT INTO 
                hoobot.project_page (project_id, page_id, preview_url, deploy_url)
              VALUES
                (#{item.project_id}, #{item.page_id}, '#{item.preview_url}', '#{item.deploy_url}')
              ON DUPLICATE KEY UPDATE
                preview_url='#{item.preview_url}', deploy_url='#{item.deploy_url}', project_id=#{item.project_id};" 

      @execute sql, ->


module.exports = new ProjectData