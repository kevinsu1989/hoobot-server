hoobot的发布服务
APIS
1.新版本发布
URL:/api/release
METHOD:POST
```
{
	project_id: 1, //项目id
	commit_hash: '44e4cebf98d57a7d3f9b1ec9cfed2a176a879523', //commit的hash
	commit_message: 'Merge branch \'mgtv\' into \'master\' Mgtv See merge request !143',
	committed_date: '2016-02-23T15:24:02.000+08:00',
	committer_email: 'xuedudu@gmail.com',
	tag_name: 'v0.2.3', 
	ssh_git: 'git@git.hunantv.com:honey-lab/imgotv-pc.git', 
	token: 'xxxxxx' //release的token
}

```
2.编辑发布上线
URL:/api/deploy
METHOD:POST
```
{
	page_id: 1, //页面id
	hashKey: 'test', //VRS的任务id
	key: 'test' //dollargan的任务id
}

```


3.发布版本时的log
URL:/logs/:commit_id 
