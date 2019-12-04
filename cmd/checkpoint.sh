#!/bin/bash
if [ ! -e /cp/$1/descriptors.json ]; then
  echo "チェックポイントが見つかりません"
  exit 1
fi
while [ -z "$CID" ] 
do
CID=`docker ps -qf name=user --no-trunc`
echo $CID
done

#docker kill $CID
echo 'before cp'
sudo cp -r /cp/$1 /var/lib/docker/containers/$CID/checkpoints/
echo 'after cp && before decker kill'
docker kill $CID
echo 'after docker kill && before docker start'
docker start --checkpoint=$1 $CID
echo 'after docker start'
