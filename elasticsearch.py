from elasticsearch import Elasticsearch

# Connect to Elasticsearch
es = Elasticsearch("http://localhost:9200")

# Create index with custom settings
index_settings = {
    "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0
    },
    "mappings": {
        "properties": {
            "title": {"type": "text"},
            "company": {"type": "text"},
            "location": {"type": "text"},
            "type": {"type": "text"}
        }
    }
}

# Create Elasticsearch index
if not es.indices.exists(index="gig-jobs"):
    es.indices.create(index="gig-jobs", body=index_settings)
    print("Index 'gig-jobs' created.")
else:
    print("Index already exists.")
