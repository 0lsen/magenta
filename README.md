# Magenta Musik 360 Download

## What?

[Magenta](https://www.magenta-musik-360.de) offers free concert streams. If you want to download the streams feel free to use this bash script.
I've tried this for a couple of Wacken Festival streams, no guarantee if this works for anything else.

## How?

Open the desired concert in your browser, have it play, open your browser's developer console (F12 for chrome/firefox) and take a look at the Network Tab.
You will see a segment loading every couple of seconds (apparently 10 per minute / each 6s long).

![asd](https://i.imgur.com/fY1TTdE.png)

The URL is something like `https://streaming-magenta-music-360.akamaized.net/vod/WOA2018_Alestorm/hd/3400/segment577.ts`.
`3400` in the URL denotes the video bitrate/resolution (`9000`: 1080p, `3400`: 720p, `2200`: 480p? - pick/guess your poison).
Copy the URL, cut the `/segmentXXX.ts` part and throw the URL to the script like

```
. magenta.sh https://streaming-magenta-music-360.akamaized.net/vod/WOA2018_Alestorm/hd/9000
```

The result will (hopefully) be a [`video.ts`](https://en.wikipedia.org/wiki/MPEG_transport_stream) file which should play on VLC / MPC-HC / etc.. Otherwise google how to convert that.

## TODO?

- be more idiot friendly, catch errors, be less/more verbose, etc.
- delete each segment directly after merge, thus saving hd space
- `cat` seems to be like lolslow (at least on my raspi)
- git gud in bash
