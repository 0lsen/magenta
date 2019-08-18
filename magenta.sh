URL=$1
I=0

rm video.ts

while wget -q $URL/segment$I.ts
do
        cat segment$I.ts >> video.ts
        rm segment$I.ts
        echo "segment $I"
        I=$(($I+1))
done

echo "done."
