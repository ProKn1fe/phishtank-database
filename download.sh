#!/bin/bash

if [ $# -lt 2 ]
then
echo "Must be 2 parameters api_key and user name. "
exit
fi

API_KEY=$1
USER_NAME=$2

API_URL="http://data.phishtank.com/data/$API_KEY/online-valid.json.bz2"
MAX_OLD_FILES=20

CURRENT_DB_DATE=$(date -r online-valid.json.bz2 "+%m_%d_%Y_%H_%M_%S")
CURRENT_HASH=$(cat online-valid.json.bz2.sha256)

wget --user-agent="phishtank/$USER_NAME" -O "new-online-valid.json.bz2" $API_URL
NEW_HASH=$(sha256sum new-online-valid.json.bz2)

if [ "$CURRENT_HASH" != "$NEW_HASH" ]; then
	mv online-valid.json.bz2 Archive/$CURRENT_DB_DATE.json.bz2
	mv new-online-valid.json.bz2 online-valid.json.bz2

	echo $NEW_HASH > online-valid.json.bz2.sha256
	bzip2 -f -k -d online-valid.json.bz2

	ls -d $PWD/Archive/* -t | sed -e "1,"$MAX_OLD_FILES"d" | xargs -d '\n' rm

	COMMIT_DATE=$(date "+%m-%d-%Y %H:%M:%S")
	git add -A

	git commit -m "Update $COMMIT_DATE"
	#git push
else
	rm new-online-valid.json.bz2
fi
