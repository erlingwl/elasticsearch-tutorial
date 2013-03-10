for i in 118 123 125 126 133 141 144 148 160 161 170 177 179 194
do
curl -s http://boosterconf.no/talks/$i.json | xargs -0 echo | curl -X POST "http://localhost:9200/talks/talk/$i" -d @-
done