#!/bin/bash
#
baseBuild () {
    bundle ;
    webpack ;
    bundle exec jekyll build ;
}

GitAddCommit () {
    echo "Enter a Commit Message for GitHub (No Quotes):"
    read commitMessage

    git add . &&
    git commit -a -m "$commitMessage"

    cd ../www
    pwd
    git add . &&
    git commit -a -m "$commitMessage"
    cd ../www-jekyll
    pwd
}

GitPush () {
    git push -u origin master

    cd ../www
    pwd
    git push -u origin master
    cd ../www-jekyll
    pwd
}

ServLocal () {
    bundle exec jekyll serve --livereload
}

buildOnly () {
    baseBuild
}

startLocalOnly () {
    baseBuild
    ServLocal
}

startNoServ () {
    baseBuild
    GitAddCommit
    GitPush
}

start () {
    baseBuild
    GitAddCommit
    GitPush
    ServLocal
}



if [[ $1 = "buildOnly" ]]; then
    buildOnly
elif [[ $1 = "startLocalOnly" ]]; then
    startLocalOnly
elif [[ $1 = "startNoServ" ]]; then
    startNoServ
elif [[ $1 = "start" ]]; then
    start
fi

