#!/bin/bash

INSTANCE_NAME=ckan_2_3

sudo -u postgres dropdb ${INSTANCE_NAME}
sudo -u postgres dropdb ${INSTANCE_NAME}_datastore
sudo -u postgres dropuser ${INSTANCE_NAME}_user
sudo -u postgres dropuser ${INSTANCE_NAME}_user_ro

rm -rf ./$INSTANCE_NAME

