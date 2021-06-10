#!/usr/bin/env bash
#
# boorstrap.sh
# Copyright (C) 2020 malzahar
#

export REPO="hextechs"
export DOCKERFILE_DIFF=()
export IGNORE_ARRAY=()

public::common::log() {
    echo -e "\033[0;32m[ $1 ]\033[0m"
}

public::common::prepare() {
    local GIT=$(which git)
    if [[ ! -x "${GIT}" ]];then
        public::common::log "git command not found"
    fi
    local MAKE=$(which make)
    if [[ ! -x "${MAKE}" ]];then
        public::common::log "make command not found"
    fi
    local DOCKER="$(which docker)"
    if [[ ! -x "${DOCKER}" ]];then
        public::common::log "docker command not found"
    fi
}

private::git::diff() {
    if [[ ${COMMIT1} == "" && ${COMMIT2} == "" ]];then
        local COMMIT=$(git log -2 --pretty=format:"%h")
        COMMIT2=$(echo $COMMIT | awk -F" " '{print $1}')
        COMMIT1=$(echo $COMMIT | awk -F" " '{print $2}')
    fi
    local FILE=($(git diff --name-only ${COMMIT1} ${COMMIT2} | awk -F" " '{for (i = 0; i < NF; i++) print $i}'))
    for a in ${FILE[@]}
    do
        echo $a | grep "Dockerfile" >> /dev/null
        if [[ $? == 0 ]];then
            DOCKERFILE_DIFF+=($a)
        fi
    done
}

public::common::ignore() {
    IGNORE_ARRAY=(`echo ${IGNORE} | tr ',' ' '`)
}

private::docker::build() {
    if [[ ${#DOCKERFILE_DIFF[@]} == 0 ]];then
        public::common::log "no image is required to build"
        exit 0
    fi
    export BUILD=1
    public::common::ignore
    for file in ${DOCKERFILE_DIFF[@]}
    do
        local repo=$(echo ${file} | awk -F"/" '{print $1}')
        echo ${IGNORE_ARRAY[@]}
        for i in ${IGNORE_ARRAY[@]}
        do
            if [[ ${i} == ${repo} ]];then
                BUILD=0
                break
            fi
        done
        if [[ ${BUILD} == 0 ]];then
            public::common::log "skip ignore repo ${file}"
            continue
        fi
        local tag=$(echo ${file} | awk -F"/" '{print $2}')
        public::common::log "Build Command: docker build -t ${REPO}/${repo}:${tag} -f ${file} ${repo}/${tag}"
        docker build -t ${REPO}/${repo}:${tag} -f ${file} ${repo}/${tag}
        if [[ ${PUSH} == "true" ]];then
            public::common::log "Push Command: docker push ${REPO}/${repo}:${tag}"
            docker push ${REPO}/${repo}:${tag}
        fi
    done
}

public::common::help() {
  echo -e "bootstrap.sh will build and push image to repository

Usage:
  bootstrap.sh [options]

Flags:
      --commit1 string              Old git commit id
      --commit2 string              New git commit id
      --ignore  list                Ignore which repo and separate them with commas (e.g. --ignore phabricator,phabricator-notification)
      --push    string              Whether to push the image to the repository (must be \"true\" or not set)

if commit1 and commit2 are null, use the lastest two commit ID.
    "
}

public::common::main() {
    while
        [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
        --help)
            public::common::help
            exit 0
            ;;
        --commit1)
            export COMMIT1=$2
            shift
            ;;
        --commit2)
            export COMMIT2=$2
            shift
            ;;
        --ignore)
            export IGNORE=$2
            shift
            ;;
        --push)
            export PUSH=$2
            if [[ ${PUSH} != "" ]];then
                if [[ ${PUSH} != "true" ]];then
                    public::common::log "If you want to push directly, you must set the option --push=true"
                    exit 1
                fi
            fi
            shift
            ;;
        *)
            public::common::log "unknown option $key"
            public::common::help
            exit 1
            ;;
        esac
        shift
    done
    if [[ ${COMMIT1} == "" && ${COMMIT2} != "" ]];then
        public::common::log "--commit1 or --commit2 must given all"
    fi
    if [[ ${COMMIT1} != "" && ${COMMIT2} == "" ]];then
        public::common::log "--commit1 or --commit2 must given all"
    fi

    private::git::diff
    private::docker::build
}

public::common::main "$@"
