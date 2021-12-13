#!/bin/bash

# Prompt for version
# Assumes the naming convention is consistent
read -p "Enter the MODX version to download [2.8.1]: " version
version=${version:-2.8.1}

read -p "Enter a patch level [pl]: " patch_level
patch_level=${patch_level:-pl}

# Create a database and user
# Prompt the user for the database details
read -p "Enter a database name [cabox]: " database
database=${database:-cabox}

read -p "Enter a database Username [cabox]: " database_user
database_user=${database_user:-cabox}

read -p "Enter a database User Password [cabox]: " database_password
database_password=${database_password:-cabox}

# Install in root workspace or current directory
read -p "Install in root workspace? [Y]: " install_workspace
install_workspace=${install_workspace:-Y}

# If yes, run it
if [[ $install_workspace -eq 'y' ]] || [[ $install_workspace -eq 'Y' ]]
then
    # Make sure we're in workspace
    cd ~/workspace
fi

# Download the latest install
wget https://modx.s3.amazonaws.com/releases/$version/modx-$version-$patch_level.zip

# Extract the zip file
sudo su -c "unzip -q modx-$version-$patch_level.zip -d temp" -p www-data

# Move the files to the current directory
sudo su -c "mv temp/modx-$version-$patch_level/* ./" -p www-data

# Remove the unneeded files
sudo su -c "rm -R temp/" -p www-data
sudo su -c "rm modx-$version-$patch_level.zip" -p www-data

# Copy the htaccess files for rewriting friendly urls
sudo su -c "cp ht.access .htaccess" -p www-data
sudo su -c "cp manager/ht.access manager/.htaccess" -p www-data
sudo su -c "cp core/ht.access core/.htaccess" -p www-data

# Setup the database user
sudo mysql -e "CREATE DATABASE ${database} CHARACTER SET utf8 COLLATE utf8_general_ci;"
sudo mysql -e "CREATE USER '${database_user}'@'localhost' IDENTIFIED BY '$database_password';"
sudo mysql -e "GRANT ALL PRIVILEGES on ${database}.* to '${database_user}'@'localhost';"

# Run the CLI installer
read -p "Run the CLI Installer? [Y]: " cli
cli=${cli:-y}

# If yes, run it
if [[ $cli -eq 'y' ]] || [[ $cli -eq 'Y' ]]
then
    echo -e "--------------------------------------------------"
    echo -e "- Starting cli-install.php                       -"
    echo -e "- Enter the same db, user, password just created -"
    echo -e "--------------------------------------------------"
    sudo su -c "php setup/cli-install.php" -p www-data
    
    # Set the default unmask for apache so that both Modx and the Codeanywhere editor can write to files
    sudo su -c "echo '' >> /etc/apache2/envvars" -p root
    sudo su -c "echo '# umask 002 to create files with 0664 and folders with 0775' >> /etc/apache2/envvars" -p root
    sudo su -c "echo 'umask 002' >> /etc/apache2/envvars" -p root
    sudo service apache2 restart
fi
