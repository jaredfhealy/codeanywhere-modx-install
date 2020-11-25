# Summary
Quick install script for Codeanywhere PHP Container. Quick download and install of MODX Revolution.

## Download and Run the Install
Simply copy and paste the below script into your SSH terminal. This is intended for a Codeanywhere container which uses a standard user 'cabox', Apache running as www-data, and a 'workspace' directory acting as your web root.
```
wget https://raw.githubusercontent.com/jaredfhealy/codeanywhere-modx-install/main/ca-install.sh \
&& chmod +x ca-install.sh \
&& ./ca-install.sh \
&& rm ca-install.sh
```
1. This will download the install shell script with 'wget'
2. It will modify the script so it can be executed
3. Then the install script itself is run
4. And after completion, it removes itself

## What is the ca-install.sh script doing?
At point 3 above, the install script does the following:

1. Prompts you for 3 inputs:
    1. Modx Version: Defaulted to the latest at this time [2.8.1]
    2. Database Name: Defaulted to 'cabox'
    3. Database User: Defaulted to 'cabox'
    4. Database Password: Defaulted to 'cabox'
2. For any of the parameters, hit enter to accept the defaults.
    1. NOTE: This is intended as a quick development instance that is not "always on" and does not have a high risk of attack.
3. It then changes directories to the ~/workspace directory just in case this is executed from elsewhere.
4. Next we download the specified version from the modx s3 releases
5. Unzip all files and move to the web root "workspace"
6. Remove the temporary directory and zip file download
7. Create the database, user, and grant privileges
8. Copy the ht.access files to .htaccess in root, /core/ and /manager/ to allow frienly URLs and prevent core from being web accessible.
9. Prompt if you want to run the CLI install. If you hit enter to accept the default 'Y', it will proceed to the next step, otherwise we end here.
10. Launch the included Modx cli-install.php process
    1. Enter the same values that you specified above for Database, Username, and Password.
    2. Create the desired Admin username/password
    3. Accept default parameters or adjust as needed