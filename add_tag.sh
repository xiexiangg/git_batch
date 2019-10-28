#!/bin/bash

#$1 branch_name
#$2 tag_version
#$3 project_name

x=0;
d=0;
hvn=5;
mark=''
empty=""
tag_arr=();
valid_version=false
reserved_arr=();
is_branch=false
is_checkout=true

del_history_version() {
    valid_version=true
    if [[ ${#tag_arr[*]} > 0 ]];then

        for ((i=0; i<${#tag_arr[*]};i++)) {
            echo -e "\033[33m start del git tag <<<${tag_arr[$i]}>>> \033[0m"
            git tag -d ${tag_arr[$i]}
            git push origin :refs/tags/${tag_arr[$i]}
            echo -e "\033[33m del success to <<<${tag_arr[$i]}>>> \033[0m"
        }

        #git tag | grep -Ev "'^$temp'" | xargs git push origin ':refs/tags/'
        #git tag | grep -Ev "'^$temp'" | xargs git tag -d
        echo -e "\033[36m del total old_version to <<<${#tag_arr[*]}>>> \033[0m"
    else
        echo -e "\033[32m no need del fo history tag \033[0m"
    fi
}

function group_tag_arr() {

    while [[ ${hvn} -gt 0 ]]
    do
        temp=0
        index=0
        #v_tag=""
        for((y=0; y<${#tag_arr[*]}; y++))
        do
            tag=${tag_arr[$y]}
            if [[ ${temp} == 0 ]]; then
                temp=${tag}
            else
                if [[ ${temp} < ${tag} ]]; then
                    temp=${tag}
                    index=${y}
                fi
            fi
            # 数字对比
            #        tag_number=`echo  "${tag}" | tr -cd "[0-9]" `
            #        temp_tag=${tag_number}"0000000000";
            #        tag=${temp_tag:0:10}
            #        if [[ ${temp} == 0 ]]; then
            #            temp=${tag}
            #            v_tag=${tag}
            #        else
            #            if [[ ${temp} < ${tag} ]]; then
            #                temp=${tag}
            #                v_tag=${tag}
            #                index=${y}
            #            fi
            #        fi
            #字符串对比
        done
        unset tag_arr[${index}]
        reserved_arr[$d]=${temp}
        let d++
        let hvn--
    done
}

function init_local_tag_arr() {

    for line in `git tag -l`
    do
        tag_arr[$x]="${line}"
        let x++
    done

    tag=$(git tag | grep "$tag_version")

    if [[ ${tag} != ${empty} ]];then
        let hvn=5
    else
        let hvn=4
    fi

    group_tag_arr

    if [[ ${reserved_arr[0]} > ${tag_version} ]];then
        echo -e "\033[31m invalid tag version to $tag_version,less than current<<<${reserved_arr[0]}>>> version !!! \033[0m"
        return
    fi
    del_history_version
}

function git_add_tag(){

    branch_name=$1
    tag_version=$2
    project_name=$3

    if [[ -d ${project_name} ]];then

        echo 'in project --> '${project_name}

        cd ${project_name}

        git fetch

        for branch in `git branch -r`
        do
            if [[ ${branch} == "origin/${branch_name}" ]];then
                is_branch=true
                break
            fi
        done

        if [[ ${is_branch} == true ]];then

            on_branch=$(git branch | awk  '$1 == "*"{print $2}')

            if [[ ${on_branch} == ${branch_name} ]];then
                is_checkout=false
            fi
        else
            echo -e "\033[31m no branch_name!!!<<<${branch_name}>>> \033[0m"
        fi

        if [[ ${is_checkout} == true ]];then
            git checkout ${branch_name}
        fi

        git pull origin ${branch_name}

        git pull --tags

        init_local_tag_arr

        if [[ ${valid_version} == true ]];then
        git tag -a ${tag_version} -m ''

        echo -e "\033[33m push remote tag: <<<${tag_version}>>> ing.. \033[0m"

        git push --tags -f

        echo -e "\033[32m push remote tag: <<<${tag_version}>>> success! \033[0m"
        fi


        cd ../

    else
        echo -e "\033[31m no project!!!<<<${project_name}>>> \033[0m"
    fi
}

if [[ ${2} == ${empty} ]];then
    echo -e "\033[31m must be filled in tag version!!! \033[0m"
    return
fi

if [[ ${3} != "$empty" ]];then

    git_add_tag $1 $2 $3

else

    for file in $(ls ./)
    do
        git_add_tag $1 $2 ${file}
    done

fi


