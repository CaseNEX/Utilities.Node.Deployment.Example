#!/bin/bash


BUILD_DIR='/home/www/node/build/HelloWorld/'
DESTINATION='/home/www/node/HelloWorld/'

cd ${BUILD_DIR}
# initiaite node version manager
source ~/.nvm/nvm.sh

#install in build dir
npm install

# did npm install succeed?
if [ $? -eq 0 ]; then
	#it did, so copy all files to destination
	cp ${BUILD_DIR}. ${DESTINATION}/ -R
	# gracefully reload the webserver
    pm2 gracefulReload all
fi
