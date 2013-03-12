Notes for my Elasticsearch tutorial at Boosterconf: http://boosterconf.no/talks/133/


Prereqiusites
=============

Install Elasticsearch (http://www.elasticsearch.org/guide/reference/setup/installation.html) (requires Java)

Install the Elasticsearch head plugin (http://mobz.github.com/elasticsearch-head/)


Indexing, mapping and queries
=============================

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

Facets:

    curl -XGET 'http://localhost:9200/talks/talk/_search?size=10&pretty' -d '{
      "query": {
        "query_string": {
          "query": "acceptance_status: accepted"
        }
      },
      "facets" : {
        "language" : {
            "terms" : { "field" : "language" }
        }
      }
    }'


Filters:

    curl -XGET 'http://localhost:9200/talks/talk/_search?size=10&pretty' -d '{
      "query": {
        "query_string": {
          "query": "acceptance_status: accepted"
        }
      },
      "filter" : {
        "term" : { "language" : "english" }
      }  
    }'


Nested documents
================

Run ./load_nested_data.sh

    curl -XGET localhost:9200/demo_cvs/cv/_search?pretty -d '{
      "query": {
        "query_string": {
          "query": "talks.title: type"
        }
      }
    }'

    curl -XGET localhost:9200/demo_cvs/cv/_search?pretty -d '{
      "query": {
        "query_string": {
          "query": "talks.title: \"tutorial type\""
        }
      }
    }'

Add mapping:
  
    curl -X DELETE http://localhost:9200/demo_cvs  

    curl -X PUT http://localhost:9200/demo_cvs -d '{
      "mappings":{
        "cv" : {
          "properties" : {
            "talks" : {"type" : "nested"}
          }
        }
      }
    }'

Try a the same a nested query:

    curl -XGET localhost:9200/demo_cvs/cv/_search?pretty -d '{
      "query": { 
        "nested" : {
          "path" : "talks",
          "query" : {
            "bool" : {
              "must" : [
                  {
                    "query_string" : {"query" : "talks.title:\"tutorial type\""}
                  }
                ]
            }
          }
        }
      }
    }'

    curl -XGET localhost:9200/demo_cvs/cv/_search?pretty -d '{
      "query": { 
        "nested" : {
          "path" : "talks",
          "query" : {
            "bool" : {
              "must" : [
                  {
                    "query_string" : {"query" : "talks.title:\"type driven\""}
                  }
                ]
            }
          }
        }
      }
    }'

Optionally, add a position_offset_gap to separate the fields

    curl -X DELETE http://localhost:9200/demo_cvs

    curl -X PUT http://localhost:9200/demo_cvs -d '{
      "mappings":{
        "cv" : {
          "properties" : {
            "talks" : {
              "type" : "nested", 
              "properties": {
                "title":{"type":"string","position_offset_gap":256}
              }
            }
          }
        }
      }
    }'


Parent / Child documents
========================

Load data and mappings by running ./load_parent_child_data

    curl -X GET localhost:9200/parent_cvs/child_talk/_search -d '{
      "query": {
        "has_parent": {
          "type": "parent_cv",
          "query" : {
            "query_string": {
              "query": "name: super"
            }
          }
        }
      }
    }'


    curl -X GET localhost:9200/parent_cvs/parent_cv/_search -d '{
      "query": {
        "has_child": {
          "type": "child_talk",
          "query" : {
            "query_string": {
              "query": "title: \"elasticsearch\""
            }
          }
        }
      }
    }'

Credits to http://www.spacevatican.org/2012/6/3/fun-with-elasticsearch-s-children-and-nested-documents/ for inspiration to this part of the tutorial