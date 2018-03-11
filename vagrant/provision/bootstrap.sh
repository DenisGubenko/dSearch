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
    sudo apt-get install --yes wget curl htop vim nano
    sudo apt-get install --yes ssh
    sudo apt-get install --yes mc
    sudo apt-get install --yes git git-flow
    echo "."

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
        sudo update-rc.d neo4j enable
        sudo service neo4j start
        sudo service neo4j status

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