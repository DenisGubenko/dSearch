#!/usr/bin/env bash

# set locale 
# sudo update-locale LC_ALL=C.UTF-8
# Set non-interactive mode
export DEBIAN_FRONTEND=noninteractive


# abort on nonzero exitstatus
#set -o errexit
# abort on unbound variable
#set -o nounset
# don't mask errors in piped commands
#set -o pipefail

# Color definitions
readonly reset='\e[0m'
readonly cyan='\e[0;36m'
readonly red='\e[0;31m'
readonly yellow='\e[0;33m'	


info() {
 printf "${cyan}>>> %s${reset}\n" "${*}" 
}


if [ ! -e /home/dsearch/vagrant/.provision ];
then
	
    info "updating system packages"
    sudo apt-get update --fix-missing
    sudo apt-get --yes upgrade
    echo "."

    info "installing essentials and tools ..."
    sudo apt-get install --yes software-properties-common
    sudo apt-get install --yes python-software-properties
    sudo apt-get install --yes wget curl htop vim nano unzip
    sudo apt-get install --yes ssh
    sudo apt-get install --yes mc
    sudo apt-get install --yes git git-flow
    echo "."

    #--------------------------------------
    # Nginx
    #--------------------------------------

    if [ ${INSTALL_NGINX} = true ]; then
        info "installing lastest stable Nginx"
        sudo add-apt-repository -y ppa:nginx/stable
        sudo apt-get -y update > /dev/null
        sudo apt-get -y install nginx
        echo "."
    fi

    #--------------------------------------
    # NodeJS
    #--------------------------------------

    if [ ${INSTALL_NODEJS} = true ]; then
        info "installing NodeJS"
        curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
        sudo apt install -y nodejs
        sudo npm install -g yarn

        echo "."
    fi

    #--------------------------------------
    # Java 8
    #--------------------------------------

    if [ ${INSTALL_JAVA8} = true ]; then
        info "Installing Java 8"
        sudo add-apt-repository -y ppa:webupd8team/java
        sudo apt-get update -qq > /dev/null
        echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
	echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections
        sudo apt-get install --yes oracle-java8-installer
	yes "" | apt-get -f install
        sudo apt-get install --yes maven

        echo "."
    fi

    #--------------------------------------
    # Neo4j
    #--------------------------------------

    if [ ${INSTALL_NEO4J} = true ]; then
        info "Installing Neo4j"
        sudo wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
        echo 'deb https://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
        sudo apt-get update -qq > /dev/null
        sudo apt-get install --yes neo4j
        sudo sed -i 's/#dbms.security.auth_enabled=false/dbms.security.auth_enabled=false/' /etc/neo4j/neo4j.conf
        sudo sed -i 's/#dbms.connectors.default_listen_address=0.0.0.0/dbms.connectors.default_listen_address=0.0.0.0/' /etc/neo4j/neo4j.conf
        sudo sed -i 's/#dbms.connectors.default_advertised_address=localhost/dbms.connectors.default_advertised_address=localhost/' /etc/neo4j/neo4j.conf
        sudo sed -i 's/#dbms.connector.bolt.enabled=true/dbms.connector.bolt.enabled=true/' /etc/neo4j/neo4j.conf
        sudo sed -i 's/#dbms.connector.bolt.tls_level=OPTIONAL/dbms.connector.bolt.tls_level=OPTIONAL/' /etc/neo4j/neo4j.conf
        sudo sed -i 's/#dbms.connector.bolt.listen_address=:7687/dbms.connector.bolt.listen_address=:7687/' /etc/neo4j/neo4j.conf
        sudo sed -i 's/#dbms.connector.http.enabled=true/dbms.connector.http.enabled=true/' /etc/neo4j/neo4j.conf
        sudo sed -i 's/#dbms.connector.http.listen_address=:7474/dbms.connector.http.listen_address=:7474/' /etc/neo4j/neo4j.conf
        sudo sed -i 's/#dbms.connector.https.enabled=true/dbms.connector.https.enabled=true/' /etc/neo4j/neo4j.conf
        sudo sed -i 's/#dbms.connector.https.listen_address=:7473/dbms.connector.https.listen_address=:7473/' /etc/neo4j/neo4j.conf
        sudo update-rc.d neo4j enable
        sudo service neo4j start
        sudo service neo4j status

        if [ ${INSTALL_NODEJS} = true ]; then
            info "Install Neo4j Browser"
            sudo mkdir /tmp/neo4j
            cd /tmp/neo4j
            sudo wget https://github.com/neo4j/neo4j-browser/archive/master.zip
            sudo unzip -q master.zip
            sudo rm -fr /home/dsearch/neo4j
            sudo mv -fi /tmp/neo4j/neo4j-browser-master /home/dsearch/neo4j
            cd /home/dsearch/neo4j
            sudo rm -f -r yarn.lock
            sudo yarn
            sudo sed -i 's/    port: 8080,/    port: 63645,/' /home/dsearch/neo4j/webpack.config.js
        fi

        echo "."
    fi

    #--------------------------------------
    # configure fixes, clean and done
    #--------------------------------------

    #configure locales
    export LANGUAGE=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    locale-gen en_US.UTF-8
    dpkg-reconfigure locales

    #clean up
    sudo apt-get autoremove > /dev/null
    sudo apt-get autoclean > /dev/null
    sudo apt-get clean > /dev/null

    touch /home/dsearch/vagrant/.provision
    info "Provisioning done."
fi