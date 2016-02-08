#!/bin/bash

INSTANCE_NAME=ckan_2_5_1_mihail
CKAN_REPOSITORY=https://github.com/mihail-ivanov/ckan
DATAPUSHER_REPOSITORY=https://github.com/mihail-ivanov/ckan-datapusher

INSTALL_DIR=`pwd`/$INSTANCE_NAME
SOURCE_DIR=$INSTALL_DIR/src
STORAGE_DIR=$INSTALL_DIR/storage

CONFIG_PATH=$SOURCE_DIR/ckan/development.ini

DBNAME=${INSTANCE_NAME}
DBNAME_DATASTORE=${INSTANCE_NAME}_datastore
DBUSER=${INSTANCE_NAME}_user
DBUSER_RO=${INSTANCE_NAME}_user_ro
DBPASS=postgres

virtualenv --no-site-packages $INSTALL_DIR
. $INSTALL_DIR/bin/activate

mkdir -p $SOURCE_DIR
mkdir -p $STORAGE_DIR

cd $SOURCE_DIR
git clone $CKAN_REPOSITORY ckan
cd ckan
pip install -r requirements.txt
pip install -e .

deactivate
. $INSTALL_DIR/bin/activate

sudo -u postgres createuser -S -D -R -P $DBUSER
sudo -u postgres createdb -O $DBUSER $DBNAME -E utf-8

cd $SOURCE_DIR/ckan
paster make-config ckan $CONFIG_PATH

sed -i '/^sqlalchemy.url/c sqlalchemy.url = postgresql://'${DBUSER}':'${DBPASS}'@localhost/'${DBNAME} $CONFIG_PATH
sed -i '/^ckan.site_id/c ckan.site_id = '${INSTANCE_NAME} $CONFIG_PATH
sed -i '/^ckan.site_url/c ckan.site_url = http://127.0.0.1:5000' $CONFIG_PATH
sed -i '/^#solr_url/c solr_url = http://127.0.0.1:8983/solr' $CONFIG_PATH
sed -i '/^#ckan.storage_path/c ckan.storage_path = '${STORAGE_DIR} $CONFIG_PATH
sed -i '/^#ckan.datapusher.url/c ckan.datapusher.url = http://127.0.0.1:8800/' $CONFIG_PATH
sed -i '/^ckan.plugins/c ckan.plugins = stats text_view image_view recline_view datastore datapusher' $CONFIG_PATH

# Set up datastore
sudo -u postgres createuser -S -D -R -P $DBUSER_RO
sudo -u postgres createdb -O $DBUSER $DBNAME_DATASTORE -E utf-8

sed -i '/^#ckan.datastore.write_url/c ckan.datastore.write_url = postgresql://'${DBUSER}':'${DBPASS}'@localhost/'${DBNAME_DATASTORE} $CONFIG_PATH
sed -i '/^#ckan.datastore.read_url/c ckan.datastore.read_url = postgresql://'${DBUSER_RO}':'${DBPASS}'@localhost/'${DBNAME_DATASTORE} $CONFIG_PATH

# Database init
paster db init -c $CONFIG_PATH
paster --plugin=ckan datastore set-permissions -c $CONFIG_PATH | sudo -u postgres psql --set ON_ERROR_STOP=1

# Set up datapusher
cd $SOURCE_DIR
git clone $DATAPUSHER_REPOSITORY datapusher
cd datapusher
pip install -r requirements.txt
pip install -e .

# Set up run scripts
cd $SOURCE_DIR/ckan

echo '#!/bin/bash' > ./run_dev.sh
echo 'sudo ln -sf '${SOURCE_DIR}'/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml' >> ./run_dev.sh
echo 'sudo service jetty8 restart' >> ./run_dev.sh
echo 'paster serve ./development.ini' >> ./run_dev.sh

chmod 755 ./run_dev.sh

cd $SOURCE_DIR/datapusher

echo '#!/bin/bash' > ./run_dev.sh
echo 'python datapusher/main.py deployment/datapusher_settings.py' >> ./run_dev.sh

chmod 755 ./run_dev.sh


pip uninstall -y sqlalchemy
pip install SQLAlchemy==0.9.6
