#!/bin/bash

echo ">>> This is in deply.sh"

# ----------------------
# KUDU Deployment Script
# Version: 0.2.2
# ----------------------

# Helpers
# -------

exitWithMessageOnError () {
  if [ ! $? -eq 0 ]; then
    echo "An error has occurred during web site deployment."
    echo $1
    exit 1
  fi
}

# Prerequisites
# -------------

# Verify node.js installed
hash node 2>/dev/null
exitWithMessageOnError "Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment."

# Setup
# -----

SCRIPT_DIR="${BASH_SOURCE[0]%\\*}"
SCRIPT_DIR="${SCRIPT_DIR%/*}"
ARTIFACTS=$SCRIPT_DIR/../artifacts
KUDU_SYNC_CMD=${KUDU_SYNC_CMD//\"}

if [[ ! -n "$DEPLOYMENT_SOURCE" ]]; then
  DEPLOYMENT_SOURCE=$SCRIPT_DIR
fi

if [[ ! -n "$NEXT_MANIFEST_PATH" ]]; then
  NEXT_MANIFEST_PATH=$ARTIFACTS/manifest

  if [[ ! -n "$PREVIOUS_MANIFEST_PATH" ]]; then
    PREVIOUS_MANIFEST_PATH=$NEXT_MANIFEST_PATH
  fi
fi

if [[ ! -n "$DEPLOYMENT_TARGET" ]]; then
  DEPLOYMENT_TARGET=$ARTIFACTS/wwwroot
else
  KUDU_SERVICE=true
fi

if [[ ! -n "$KUDU_SYNC_CMD" ]]; then
  # Install kudu sync
  echo Installing Kudu Sync
  npm install kudusync -g --silent
  exitWithMessageOnError "npm failed"

  if [[ ! -n "$KUDU_SERVICE" ]]; then
    # In case we are running locally this is the correct location of kuduSync
    KUDU_SYNC_CMD=kuduSync
  else
    # In case we are running on kudu service this is the correct location of kuduSync
    KUDU_SYNC_CMD=$APPDATA/npm/node_modules/kuduSync/bin/kuduSync
  fi
fi

# Node Helpers
# ------------

selectNodeVersion () {
  if [[ -n "$KUDU_SELECT_NODE_VERSION_CMD" ]]; then
    SELECT_NODE_VERSION="$KUDU_SELECT_NODE_VERSION_CMD \"$DEPLOYMENT_SOURCE\" \"$DEPLOYMENT_TARGET\" \"$DEPLOYMENT_TEMP\""
    eval $SELECT_NODE_VERSION
    exitWithMessageOnError "select node version failed"

    if [[ -e "$DEPLOYMENT_TEMP/__nodeVersion.tmp" ]]; then
      NODE_EXE=`cat "$DEPLOYMENT_TEMP/__nodeVersion.tmp"`
      exitWithMessageOnError "getting node version failed"
    fi

    if [[ -e "$DEPLOYMENT_TEMP/.tmp" ]]; then
      NPM_JS_PATH=`cat "$DEPLOYMENT_TEMP/__npmVersion.tmp"`
      exitWithMessageOnError "getting npm version failed"
    fi

    if [[ ! -n "$NODE_EXE" ]]; then
      NODE_EXE=node
    fi

    NPM_CMD="\"$NODE_EXE\" \"$NPM_JS_PATH\""
  else
    NPM_CMD=npm
    NODE_EXE=node
  fi
}

##################################################################################################################################
# Deployment
# ----------

echo Handling node.js deployment.

# 1. KuduSync
if [[ "$IN_PLACE_DEPLOYMENT" -ne "1" ]]; then
  "$KUDU_SYNC_CMD" -v 50 -f "$DEPLOYMENT_SOURCE" -t "$DEPLOYMENT_TARGET" -n "$NEXT_MANIFEST_PATH" -p "$PREVIOUS_MANIFEST_PATH" -i ".git;.hg;.deployment;deploy.sh"
  exitWithMessageOnError "Kudu Sync failed"
fi

# 2. Select node version
selectNodeVersion

# 3. Install npm packages
if [ -e "$DEPLOYMENT_TARGET/package.json" ]; then
  cd "$DEPLOYMENT_TARGET"
  eval $NPM_CMD install --production
  exitWithMessageOnError "npm failed"
  cd - > /dev/null
fi


echo ">>>>> Build TM QA Version in Windows"
git status
npm --version
node --version

git config user.email "you@example.com"
git config user.name "Your Name"

mkdir ../git_repos
cd ../git_repos
echo ">>>>> cloning TM_4_0_Design and TM_4_0_GraphDB"
git clone https://github.com/TeamMentor/TM_4_0_Design.git
git clone https://github.com/TeamMentor/TM_4_0_GraphDB.git
git clone https://github.com/tm-build/TM_4_0_Windows.git

mv TM_4_0_Windows/tm-design-node-modules TM_4_0_Design/node_modules
mv TM_4_0_Windows/tm-graphdb-node-modules TM_4_0_GraphDB/node_modules

cd TM_4_0_GraphDB
mkdir .tmCache
cd .tmCache
git clone https://tm-build:$GIT_PWD@github.com/TMContent/Lib_UNO-json.git
cd ..
#"D:\Program Files (x86)\NodeJs\0.12.2\node" --version

#"D:\Program Files (x86)\NodeJs\0.12.2\node" ./node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register --recursive -R list
#cp -R .tmCache ../../wwwroot/

#cd ../git_repos/TM_4_0_Windows
#pwd
#git pull -f origin master

#echo ">>>>> cloning Lib_UNO-json into tm-graphdb/.tmCache"
#cd tm-graphdb/
#mkdir .tmCache
#git clone https://tm-build:$GIT_PWD@github.com/TMContent/Lib_UNO-json.git ./.tmCache/Lib_UNO-json
#cd ./.tmCache/Lib_UNO-json
#pwd
#git pull -f origin master
#cd ..
#cd ..
#ls .tmCache

#echo ">>>>> running tm-graphdb tests"
#npm test -- --bail

#"D:\Program Files (x86)\NodeJs\0.12.2\node" ./node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register --recursive -R list
#--bail
#echo ">>>>> all done"
pwd

#cd  ../git_repos/TM_4_0_Windows/tm-design
#cd ../../../
#npm start &



#curl -O https://dl.ngrok.com/ngrok_2.0.17_windows_386.zip
#unzip ngrok_2.0.17_windows_386.zip
#ngrok http 1332 &


##################################################################################################################################


curl https://tm-qa-3.azurewebsites.net/

# Post deployment stub
if [[ -n "$POST_DEPLOYMENT_ACTION" ]]; then
  POST_DEPLOYMENT_ACTION=${POST_DEPLOYMENT_ACTION//\"}
  cd "${POST_DEPLOYMENT_ACTION_DIR%\\*}"
  "$POST_DEPLOYMENT_ACTION"
  exitWithMessageOnError "post deployment action failed"
fi

echo "Finished successfully."
