Delete the index:

    curl -X DELETE http://localhost:9200/talks

Chech the index:

    curl -I "http://localhost:9200/talks"

Create initial index:

    curl -X POST http://localhost:9200/talks -d '{"mappings":{},"settings":{"number_of_shards":1,"number_of_replicas":0}}'

Load some test data:

    curl -s http://boosterconf.no/talks/194.json | xargs -0 echo | curl -X POST "http://localhost:9200/talks/talk/194" -d @-
    curl -s http://boosterconf.no/talks/170.json | xargs -0 echo | curl -X POST "http://localhost:9200/talks/talk/170" -d @-
    curl -s http://boosterconf.no/talks/177.json | xargs -0 echo | curl -X POST "http://localhost:9200/talks/talk/177" -d @-
    curl -s http://boosterconf.no/talks/179.json | xargs -0 echo | curl -X POST "http://localhost:9200/talks/talk/179" -d @-

Or you could run load_data.sh


Run a simple query:

    curl -XGET 'http://localhost:9200/talks/talk/_search?size=10&pretty' -d '{"query": {"query_string":{"query": "kafka"}}}'

With highlights:

    curl -XGET 'http://localhost:9200/talks/talk/_search?size=10&pretty' -d '{
      "query": {
        "query_string": {
          "query": "kafka"
        }
      }, 
      "highlight": {
        "fields": {
          "title": {},
          "description":{}
        }
      }
    }'

Search for HTML-markup:

    curl -XGET 'http://localhost:9200/talks/talk/_search?size=10&pretty' -d '{
      "query": {
        "query_string": {
          "query": "description: <p>"
        }
      }, 
      "highlight": {
        "fields": {
          "title": {},
          "description":{}
        }
      }
    }'

Delete the index:

    curl -X DELETE http://localhost:9200/talks

Recreate index with our own custom analyzer:

    curl -X PUT http://localhost:9200/talks -d '{
      "mappings":{},
      "settings":{
        "index": { 
          "number_of_shards":1,
          "number_of_replicas":0,
          "analysis": {
            analyzer: {
              "descriptionAnalyzer": {
                "type": "custom",
                "tokenizer": "standard",
                "filter": "standard",
                "char_filter": "html_strip"
              }
            }  
          }
        }  
      }  
    }'

Test the analyzer:

    curl -XGET 'localhost:9200/talks/_analyze?analyzer=standard' -d '<p>this is a test</p>'
    curl -XGET 'localhost:9200/talks/_analyze?analyzer=descriptionAnalyzer' -d '<p>this is a test</p>'

Update the mapping:

    curl -XPUT 'http://localhost:9200/talks/talk/_mapping' -d '{
        "talk" : {
            "properties" : {
                "description" : {"type" : "string", "store" : "yes", "analyzer": "descriptionAnalyzer"}
            }
        }
    }'

Reload the test data, try to search for the html markup again.
