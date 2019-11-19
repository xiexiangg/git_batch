#!/bin/bash

#$1 branch_name
#$2 tag_version
#$3 project_name

init_params() {
    x=0
    d=0
    hvn=5
    mark=''
    empty=''
    tag_arr=()
    valid_version=false
    reserved_arr=()
    is_branch=false
    is_checkout=true
    max_tag_version_number=0
}

del_history_version() {

    valid_version=true

    if [[ ${#tag_arr[*]} > 0 ]];then

        for del_tag in ${tag_arr[*]};
        do
            echo -e "\033[33m start del git tag <<<${del_tag}>>> \033[0m"
            git tag -d ${del_tag}
            git push origin :refs/tags/${del_tag}
            echo -e "\033[36m del success to <<<${del_tag}>>> \033[0m"
        done
    else
        echo -e "\033[32m no need del fo history tag \033[0m"
    fi
}

function get_max_compare_version() {
    v1=${1}
    v2=${2}
    v1_array=(${v1//./ })
    v2_array=(${v2//./ })
    len=$((${#v1_array[*]} > ${#v2_array[*]} ? ${#v1_array[*]} : ${#v2_array[*]}))

    if [[ ${#v1} == ${#v2} ]];then

        if [[ ${v1} == ${v2} ]];then
            echo 1
        elif [[ ${v1} > ${v2} ]];then
            echo 1
        else
            echo 0
        fi
    else
        for((i=0; i<${len}; i++))
        do
            v1_arr_number=`get_string_number ${v1_array[i]}`
            v2_arr_number=`get_string_number ${v2_array[i]}`

            if [[ ${v1_arr_number} -gt ${v2_arr_number} ]];then
                echo 1;break
            fi

            if [[ ${v1_arr_number} -lt ${v2_arr_number} ]];then
                echo 0;break
            fi
        done
    fi
}

function get_string_number() {
    echo `echo "${1}" | tr -cd "[0-9]"`
}

function group_tag_arr() {

    while [[ ${hvn} -gt 0 ]]
    do
        temp=0
        index=0
        for((y=0; y<${#tag_arr[*]}; y++))
        do
            tag=${tag_arr[$y]}
            if [[ `get_max_compare_version ${temp} ${tag}` -eq 0 ]]; then
                temp=${tag}
                index=${y}
            fi
        done
        unset tag_arr[${index}]
        reserved_arr[$d]=${temp}
        let d++
        let hvn--
    done
}

function init_tag_arr() {

    for line in `git tag -l`
    do
        tag_arr[$x]="${line}"
        let x++
    done

    group_tag_arr

    if [[ ${reserved_arr[0]} == ${tag_version} ]];then

        hvn=4
        tag_arr[1000]=${tag_version}
    else
        if [[ `get_max_compare_version ${reserved_arr[0]} ${tag_version}` -eq 1 ]];then
            echo -e "\033[31m invalid tag version to <<<${tag_version}>>>,less than current<<<${reserved_arr[0]}>>> version !!! \033[0m"
            return
        fi
    fi
    del_history_version
}

function git_add_tag(){

    branch_name=$1
    tag_version=$2
    project_name=$3

    if [[ -d ${project_name} ]];then

        echo -e "\033[33m in project <<<${project_name}>>> \033[0m"
        cd ${project_name}
        git tag | xargs git tag -d
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

        init_tag_arr

        if [[ ${valid_version} == true ]];then

            git tag -a ${tag_version} -m ''

            echo -e "\033[33m push remote tag: <<<${tag_version}>>> ing.. \033[0m"

            git push --tags -f

            echo -e "\033[32m push remote tag: <<<${tag_version}>>> success! \033[0m"
        fi
        init_params
        cd ../

    else
        echo -e "\033[31m no project!!!<<<${project_name}>>> \033[0m"
    fi
}

init_params

if [[ ${2} == ${empty} ]];then
    echo -e "\033[31m must be filled in tag version!!! \033[0m"
    return
fi

if [[ ${3} != ${empty} ]];then

    git_add_tag $1 $2 $3

else

    for file in $(ls ./)
    do
        git_add_tag $1 $2 ${file}
    done

fi


