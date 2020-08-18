#!/usr/bin/env bash

if [ "$(uname)" == 'Darwin' ]; then
  find . -type d -name .git -prune -o -type d -name scripts -prune -o -type f -name .DS_Store -prune -o -type d -name bin -prune -o -type f -print | xargs sed -i '' "s#kmdkuk/go-cli-template#$1#g"
elif [ "$(uname)" == "Linux" ]; then
  find . -type d -name .git -prune -o -type d -name scripts -prune -o -type f -print | xargs sed -i "s#kmdkuk/go-cli-template#$1#g"
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi
echo "kmdkuk/go-cli-templateを$1に置換しました．"
