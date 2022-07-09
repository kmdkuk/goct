#!/usr/bin/env bash
ARR=($(echo $1 | tr '/' ' '))
REPO_NAME=${ARR[1]}
if [ ${#ARR[@]} != 2 ]; then
  echo "invalid args, please enter <your GitHub ID>/<new repository>"
  exit 1
fi
if [ "$(uname)" == 'Darwin' ]; then
  find . -type d -name .git -prune -o -type d -name scripts -prune -o -type f -name .DS_Store -prune -o -type d -name bin -prune -o -type f -print | xargs sed -i '' "s#kmdkuk/go-cli-template#$1#g"
  find . -type d -name .git -prune -o -type d -name scripts -prune -o -type f -name .DS_Store -prune -o -type d -name bin -prune -o -type f -print | xargs sed -i '' "s#go-cli-template#$REPO_NAME#g"
elif [ "$(uname)" == "Linux" ]; then
  find . -type d -name .git -prune -o -type d -name scripts -prune -o -type f -print | xargs sed -i "s#kmdkuk/goct#$1#g"
  find . -type d -name .git -prune -o -type d -name scripts -prune -o -type f -print | xargs sed -i "s#goct#$REPO_NAME#g"
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi
echo "kmdkuk/goctを$1に置換しました．"
