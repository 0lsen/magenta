# Magenta Musik 360 Downloader

## What?

[Magenta](https://www.magenta-musik-360.de) offers free concert streams. If you want to download the streams feel free to use this bash script.
It will automatically choose the best quality available.

## How?

Just provide the concert's URL as parameter and as optional parameter the desired output file name. That's it (hopefully).

```
. magenta.sh https://www.magenta-musik-360.de/abba-rock-case-studies-9208205928595215040 [ABBA.ts]
```

The result should be a [`.ts` file](https://en.wikipedia.org/wiki/MPEG_transport_stream) which should play in VLC / MPC-HC / MPlayer /... .

## TODO

- add/link a tutorial on how to create chapters for your downloaded concerts (hint: `MKVToolNix`)