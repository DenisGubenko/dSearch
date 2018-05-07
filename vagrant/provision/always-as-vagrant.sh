if [ ${INSTALL_NEO4J} = true ]; then
    if [ ${INSTALL_NODEJS} = true ]; then
        echo "Neo4j Browser: "
        echo " - http://neo4j.dsearch.int (bolt://dsearch.int user:neo4j (without password))"
        echo " - timeout with start ~ 10 min"
    fi
fi
