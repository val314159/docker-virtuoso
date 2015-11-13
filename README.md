This docker image runs a Virtuoso Database.

Simple use like this just runs the DB:

    docker run -p 1111:1111 -p 8890:8890 joernhees/virtuoso run

The database is placed inside a volume of this container in Virtuoso's default
path /var/lib/virtuoso-opensource-7 . You can mount it to the host's filesystem
like this:

    docker run -p 8890:8890 -v /host/db/dir:/var/lib/virtuoso-opensource-7 \
        joernhees/virtuoso run

To import mass data such as Ntriple dumps (can be gzipped) you can mount an
external folder to /import and use the "import <graph>" args. This will
recursively import all files into the specified graph, e.g.:

    docker run -it \
        -v /host/db/dir:/var/lib/virtuoso-opensource-7 \
        -v /data/dbpedia:/import:ro \
        joernhees/virtuoso import 'http://dbpedia.org'

After importing, the container will spawn a bash for you if you specified the
`-it` arg as above. This allows you to inspect the results, for example by
starting an `isql-vt` in the container. If the `-it` flag is left away the
container will stop after the import. The importer will also check for errors
reported by Virtuoso and will set its exit-code accordingly. This allows
external scripts to easily check for errors during the import.

You can override the virtuoso.ini NumberOfBuffers, MaxDirtyBuffers and
MaxDirtyBuffers by setting environment variables like in the following. If you
only specify NumberOfBuffers the other will be computed according to the
recommendations by OpenLink. The recommended NumberOfBuffers per GB of RAM is
85000, so to use 8 GB do the following:

    docker run -v /data/dbpedia:/import:ro -e "NumberOfBuffers=$((8*85000))" \
        joernhees/virtuoso import 'http://dbpedia.org'

If you want to override more virtuoso.ini variables you can simply mount a host
virtuoso.ini file in the container like this:

    # to get a default virtuoso.ini in your home directory:
    container_id=$(docker run -d joernhees/virtuoso run)
    docker cp $container_id:/etc/virtuoso-opensource-7/virtuoso.ini ~/
    docker stop $container_id
    docker rm -v $container_id
    # to use it after you modified it:
    docker run -v ~/virtuoso.ini:/etc/virtuoso-opensource-7/virtuoso.ini:ro \
        joernhees/virtuoso run

Similar to the import mode the container supports interactive mode that will
spawn a bash for you in the database directory via the `-it` run args:

    docker run -it joernhees/virtuoso run


Putting it all together to create a DBpedia container:

    # importing DBpedia 2015-04 vocabulary and files with throw-away containers
    # note how any failures will prevent the following commands from running
    # by joining them with &&:
    db_dir=~/dbpedia_virtuoso_db
    dump_dir=/usr/local/data/datasets/remote/dbpedia/2015-04
    docker run --rm \
        -v "$db_dir":/var/lib/virtuoso-opensource-7 \
        -v "$dump_dir"/importedGraphs/classes.dbpedia.org:/import:ro \
        joernhees/virtuoso import 'http://dbpedia.org/resource/classes#' &&
    docker run --rm \
        -v "$db_dir":/var/lib/virtuoso-opensource-7 \
        -v "$dump_dir"/importedGraphs/dbpedia.org:/import:ro \
        -e "NumberOfBuffers=$((64*85000))" \
        joernhees/virtuoso import 'http://dbpedia.org' &&
    # running a local endpoint on port 8891:
    docker run --name dbpedia \
        -v "$db_dir":/var/lib/virtuoso-opensource-7 \
        -p 8891:8890 \
        -e "NumberOfBuffers=$((32*85000))" \
        joernhees/virtuoso run
    # access http://localhost:8891/sparql or http://localhost:8891/resource/Bonn

