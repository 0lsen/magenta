#!/usr/bin/env bash

# input parameters
URL=$1
if [ "$#" -eq 2 ];
then
  NAME=$2
else
  NAME="video.ts"
  rm video.ts
fi

# define certain URLs / constants
ASSET_ID_NAME="data-asset-id"
MANIFEST_URL="https://wcps.t-online.de/bootstrap/magentamusic/v1/manifest"
MANIFEST_DEVICE_ID="00000000-0000-0000-0000-000000000000"
MANIFEST_MODEL="mm-web"
MANIFEST_FIRMWARE="xx"
MANIFEST_APPVERSION="2000"
MANIFEST_APPNAME="MagentaMusic"
MANIFEST_RUNTIMEVERSION="1"
PLAYER_URL="https://wcps.t-online.de/cvss/magentamusic/vodplayer/v3"
MOVIE_URL="https://wcps.t-online.de/cmrs/magentamusic/media/v1/hlsstreaming/movie"

# fetch IDs and ultimately playlist
echo -e "\nfetching Asset ID...     (from $URL)"
ASSET_ID=$(curl $URL 2>&1 | grep -Eo "$ASSET_ID_NAME=\"\d+" | grep -Eo "\d+")
echo "Asset ID: $ASSET_ID"

echo -e "\nfetching Detail ID...     (from $MANIFEST_URL?deviceId=$MANIFEST_DEVICE_ID&model=$MANIFEST_MODEL&firmware=$MANIFEST_FIRMWARE&appVersion=$MANIFEST_APPVERSION&appName=$MANIFEST_APPNAME&runtimeVersion=$MANIFEST_RUNTIMEVERSION)"
DETAIL_ID=$(curl "$MANIFEST_URL?deviceId=$MANIFEST_DEVICE_ID&model=$MANIFEST_MODEL&firmware=$MANIFEST_FIRMWARE&appVersion=$MANIFEST_APPVERSION&appName=$MANIFEST_APPNAME&runtimeVersion=$MANIFEST_RUNTIMEVERSION" 2>&1 | grep -Eo "\"value\": \"$PLAYER_URL/details/\d{2,}" | grep -Eo "\d{2,}")
echo "Detail ID: $DETAIL_ID"

echo -e "\nfetching Player ID...     (from $PLAYER_URL/details/$DETAIL_ID/$ASSET_ID)"
PLAYER_ID=$(curl "$PLAYER_URL/details/$DETAIL_ID/$ASSET_ID" 2>&1 | grep -Eo "$PLAYER_URL/player/\d+" | grep -Eo "\d+$")
echo "Player ID: $PLAYER_ID"

echo -e "\nfetching Content ID...     (from $PLAYER_URL/player/$PLAYER_ID/$ASSET_ID/Main%20Movie)"
CONTENT_ID=$(curl "$PLAYER_URL/player/$PLAYER_ID/$ASSET_ID/Main%20Movie" 2>&1 | grep -Eo "\"contentNumber\": \"\d+" | grep -Eo "\d+")
echo "Content ID: $CONTENT_ID"

echo -e "\nfetching Playlist URL...     (from $MOVIE_URL/$ASSET_ID/$CONTENT_ID)"
PLAYLIST_URL=$(curl "$MOVIE_URL/$ASSET_ID/$CONTENT_ID" 2>&1 | grep -Eo "src=\"[^\"]+\"" | grep -Eo "http.*\.m3u8")
echo "Playlist URL: $PLAYLIST_URL"

echo -e "\nparsing Maximum Bitrate from playlist..."
MAX_BIRATE=$(curl $PLAYLIST_URL 2>&1 | grep -Eo "URI=\"\d+" | grep -Eo "\d+" | sort -nr | head -n1)
echo "Maximum Bitrate: $MAX_BIRATE"

echo -e "\nbuilding base download URL..."
DOWNLOAD_URL=`echo $PLAYLIST_URL | rev | cut -c 12- | rev`/$MAX_BIRATE
echo "base download URL: $DOWNLOAD_URL"

echo -e "\ndownloading segments..."
I=0
while wget -q $DOWNLOAD_URL/segment$I.ts
do
        cat segment$I.ts >> "$NAME"
        rm segment$I.ts
        echo "  segment $I downloaded, merged and deleted"
        I=$(($I+1))
done

echo -e "\ndone."
