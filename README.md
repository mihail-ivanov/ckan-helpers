# ckan-helpers

Used to make local development install of ckan and datapusher from source.

Please be sure to install the following dependencies before running the install script:

* For CKAN: [dependencies](http://docs.ckan.org/en/latest/maintaining/installing/install-from-source.html#install-the-required-packages)
* For Datapusher: [dependencies](http://docs.ckan.org/projects/datapusher/en/latest/development.html)


## dev_install.sh

You can update the following variables before install:

* INSTANCE_NAME - the name of the instance (it will create folder with that name in the current directory and everything will be install inside)
* CKAN_REPOSITORY - git repository of the CKAN source
* DATAPUSHER_REPOSITORY - git repository of the datapusher source

