#!/bin/bash

# Prompt for version
# Assumes the naming convention is consistent
read -p "Enter a database name [2.8.1]: " version
version=${version:-2.8.1}

# Create a database and user
# Prompt the user for the database details
read -p "Enter a database name [cabox]: " database
database=${database:-cabox}

read -p "Enter a database Username [cabox]: " database_user
database_user=${database_user:-cabox}

read -p "Enter a database User Password [cabox]: " database_password
database_password=${database_password:-cabox}

# Make sure we're in workspace
cd ~/workspace

# Download the latest install
wget https://modx.s3.amazonaws.com/releases/$version/modx-$version-pl.zip

# Extract the zip file
sudo su -c "unzip -q modx-$version-pl.zip -d temp" -p www-data

# Move the files to the current directory
sudo su -c "mv temp/modx-$version-pl/* ./" -p www-data

# Remove the unneeded files
rm -R temp/
rm modx-$version-pl.zip

sudo mysql -e "CREATE DATABASE ${database} CHARACTER SET utf8 COLLATE utf8_general_ci;"
sudo mysql -e "CREATE USER '${database_user}'@'localhost' IDENTIFIED BY '$database_password';"
sudo mysql -e "GRANT ALL PRIVILEGES on ${database}.* to '${database_user}'@'localhost';"

# Rename the htaccess files for rewriting friendly urls
sudo su -c "mv ht.access .htaccess" -p www-data
sudo su -c "mv manager/ht.access manager/.htaccess" -p www-data
sudo su -c "mv core/ht.access core/.htaccess" -p www-data

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
fi

# Remove the install script
rm ca-install.sh