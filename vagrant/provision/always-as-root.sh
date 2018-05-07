if [ ${INSTALL_NEO4J} = true ]; then
    if [ ${INSTALL_NODEJS} = true ]; then
        sudo /home/dsearch/vagrant/custom/neo4j/neo4jBrowserInit  > /dev/null 2>&1 &
    fi
    if [ ${INSTALL_NGINX} = true ]; then
        sudo rm -fr /etc/nginx/sites-enabled/neo4j.conf && sudo ln -s /home/dsearch/vagrant/custom/nginx/neo4j.conf /etc/nginx/sites-enabled/neo4j.conf
        sudo service nginx restart
    fi
fi