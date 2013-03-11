curl -X PUT "http://localhost:9200/demo_cvs/cv/1" -d '{
  "talks": [
    {
      "title":"Elasticsearch tutorial"
    },
    {
      "title":"Type Driven Development"
    }
  ]
}'

curl -X PUT "http://localhost:9200/demo_cvs/cv/2" -d '{
  "talks": [
    {
      "title":"Automated CSS Testing"
    }
  ]
}'