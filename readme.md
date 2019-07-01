git 批量操作
=======

add_tag.sh
=======

[tag命令](https://git-scm.com/docs/git-tag)就不普及了，微服务的流行导致项目数量加大，发布基于tag操作复杂,主要是因为自己懒......

主要参数为：

branch_name： 需要打tag的分支名称 例：test

tag_version：需要打tag的版本号 例：V2.0.1

project_name：项目名称

使用: 

cd work_space

当前你的work_space肯定是N个项目或1个，如果没有可忽略，后续的动作就可以不用看了^_^

批量：

sh add_tag.sh branch_name tag_version

单个：

sh add_tag.sh branch_name tag_version project_name


