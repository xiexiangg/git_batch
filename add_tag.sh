#!/bin/bash

#$1 branch_name
#$2 tag_version
#$3 project_name

empty=""
is_branch=false
is_checkout=true

function gitAddTag(){

    branch_name=$1
    tag_version=$2
    project_name=$3

    if [[ -d ${project_name} ]];then

        echo 'in project --> '${project_name}

        cd ${project_name}

        git fetch

        for branch in `git branch -r`
        do
            if [[ "$branch" == "origin/$branch_name" ]];then
                is_branch=true
                break
            fi
        done

        if [[ ${is_branch} ]];then

            on_branch=$(git branch | awk  '$1 == "*"{print $2}')

            if [[ "$on_branch" == "$branch_name" ]];then
                is_checkout=false
            fi
        else
            echo 'no branch_name --> error!'
        fi

        if [[ ${is_checkout} ]];then
            git checkout ${branch_name}
        fi

        git pull origin ${branch_name}

        git pull --tags

        tag=$(git tag | grep "$tag_version") 

        if [[ "$tag_version" != "$empty" ]];then

            echo 'del local tag: **'${tag_version}'** ing...'

            git tag -d ${tag_version}

            echo 'del local tag: **'${tag_version}'** --> success!'

            echo 'del remote tag: **'${tag_version}'** ing...'

            git push origin :refs/tags/${tag_version}

            echo 'del remote tag: **'${tag_version}'** --> success!'
        fi

        git tag -a ${tag_version} -m ''

        echo 'push remote tag: **'${tag_version}'** ing..'

        git push --tags

        echo 'push remote tag: **'${tag_version}'** --> success!'

        cd ../

    else
        echo 'no project --> error!'
    fi
}

if [[ "$3" != "$empty" ]];then

    gitAddTag $1 $2 $3

else

    for file in $(ls ./)
    do
        gitAddTag $1 $2 ${file}
    done

fi


