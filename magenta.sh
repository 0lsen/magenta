#!/usr/bin/env bash

# input parameters
URL=$1
if [[ ("$#" -eq 2 || "$#" -eq 3) ]];
then
  NAME=$2
else
  NAME="video.ts"
  rm video.ts
fi

# define certain URLs / constants
ASSET_ID_NAME="assetId"
DM_MOVIE_PREFIX="DMM_MOVIE_"
PLAYER_URL="https://wcps.t-online.de/cvss/magentamusic/vodclient/v2/player/58935"
MOVIE_URL="https://wcps.t-online.de/cmrs/magentamusic/media/v1/hlsstreaming/movie"

# fetch IDs and ultimately playlist
echo -e "\nfetching Asset ID...     (from $URL)"
ASSET_ID=$(curl $URL 2>&1 | grep -Eo "$ASSET_ID_NAME\":\"$DM_MOVIE_PREFIX[0-9]+" | grep -Eo "[0-9]+")
echo "Asset ID: $ASSET_ID"

echo -e "\nfetching Content ID...     (from $PLAYER_URL/$ASSET_ID/Main%20Movie)"
CONTENT_ID=$(curl "$PLAYER_URL/$ASSET_ID/Main%20Movie" 2>&1 | grep -Eo "$MOVIE_URL/$ASSET_ID/[0-9]+" | grep -Eo "[0-9]+$")
echo "Content ID: $CONTENT_ID"

echo -e "\nfetching Playlist URL...     (from $MOVIE_URL/$ASSET_ID/$CONTENT_ID)"
PLAYLIST_URL=$(curl "$MOVIE_URL/$ASSET_ID/$CONTENT_ID" 2>&1 | grep -Eo "src=\"[^\"]+\"" | grep -Eo "http.*\.m3u8")
echo "Playlist URL: $PLAYLIST_URL"

echo -e "\nparsing Maximum Bitrate from playlist..."
MAX_BIRATE=$(curl $PLAYLIST_URL 2>&1 | grep -Eo "[0-9]+/index.m3u8" | grep -Eo "[0-9]+" | sort -nr | head -n1)
echo "Maximum Bitrate: $MAX_BIRATE"

reverse() {
    read a
    len=${#a}
    for((i=$len-1;i>=0;i--)); do rev="$rev${a:$i:1}"; done
    echo $rev
}

echo -e "\nbuilding base download URL..."
DOWNLOAD_URL=`echo $PLAYLIST_URL | reverse | cut -c 12- | reverse`/$MAX_BIRATE
echo "base download URL: $DOWNLOAD_URL"

echo -e "\ndownloading segments..."
I=0
while curl -s -f $DOWNLOAD_URL/segment$I.ts -o segment$I.ts
do
        res=$?
        if test "$res" != "0"; then
            break;
        fi
        cat segment$I.ts >> "$NAME"
        rm segment$I.ts
        echo "  segment $I downloaded, merged and deleted"
        I=$(($I+1))
done

echo -e "\ndone."
