hoobot的发布服务

部署在 http://10.100.5.113:1520

APIS

1.新版本发布

URL:/api/release

METHOD:POST
接收的参数：
```javascript
{
	project_id: 1, 
	commit_id '44e4cebf98d57a7d3f9b1ec9cfed2a176a879523', //commit的hash
	tag_name: 'v0.2.3', 
	ssh_git: 'git@git.hunantv.com:honey-lab/imgotv-pc.git', 
	token: 'xxxxxx' //release的token
}

```

返回：
```javascript
{
	logs:'123.59.21.92:1520/logs/44e4cebf98d57a7d3f9b1ec9cfed2a176a879523'  
}

```

现在支持node项目的部署，需要在package.json文件中做以下配置：
```
{
  "scripts": {
    "build": "cross-env NODE_ENV=production webpack --progress --hide-modules",
    "start": "NODE_ENV=production pm2 start ./bin/www -n hoobot-interface-test",
    "stop": "pm2 delete hoobot-interface-test"
  },
  "command": "npm install && npm build && npm start",//启动项目执行的指令
  "command_restart": "npm install && npm build && npm stop && npm start",//重启项目执行的指令
  "server": "http://192.168.8.156"//目标服务器地址

}

command,command_restart,server均为必填项
```


2.编辑发布上线

URL:/api/deploy

METHOD:POST


接收的参数：
```javascript
{
	page_id: 1, //页面id
	hashKey: 'test', //VRS的任务id
	key: 'test' //dollargan的任务id
}

```


3.发布版本时的log

URL:/logs/:commit_id



4.获取项目当前版本的hash

URL:/api/:git_id/release

返回:

```javascript
{
	hash: '44e4cebf98d57a7d3f9b1ec9cfed2a176a879523'
}
```



5.预览接口

URL:/api/preview

METHOD:POST
接收的参数：
```javascript
{
	project_id: 1, 
	commit_id: '44e4cebf98d57a7d3f9b1ec9cfed2a176a879523', //commit的hash
	tag_name: 'v0.2.3', 
	ssh_git: 'git@git.hunantv.com:honey-lab/imgotv-pc.git'
}

```

返回：
```javascript
{
	logs:'123.59.21.92:1520/logs/44e4cebf98d57a7d3f9b1ec9cfed2a176a879523'  
	preview:'123.59.21.92:12299/44e4cebf'  
}

```