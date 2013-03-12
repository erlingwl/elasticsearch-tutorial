curl -X DELETE http://localhost:9200/parent_cvs

curl -X PUT "http://localhost:9200/parent_cvs/parent_cv/1" -d '{
  name: "Super dev"
}'

curl -X PUT "http://localhost:9200/parent_cvs/parent_cv/2" -d '{
  name: "Test hero"
}'

curl -X POST "localhost:9200/parent_cvs/child_talk/_mapping" -d '{
  "child_talk":{
    "_parent": {"type": "parent_cv"}
  }
}'

curl -X PUT "http://localhost:9200/parent_cvs/child_talk/1?parent=1" -d '{
  "title":"Elasticsearch tutorial"
}'

curl -X PUT "http://localhost:9200/parent_cvs/child_talk/2?parent=1" -d '{
  "title":"Type Driven Development"
}'

curl -X PUT "http://localhost:9200/parent_cvs/child_talk/3?parent=2" -d '{
  "title":"Automated CSS Testing"
}'

curl -X PUT "http://localhost:9200/parent_cvs/child_talk/4?parent=2" -d '{
  "title":"HTML5 Pixel Magic"
}'