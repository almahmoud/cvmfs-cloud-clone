#!/bin/bash

set -xe

export CVMFS_PATH=/cvmfs/cloud.galaxyproject.org
export LOCAL_CVMFS_PATH=/full/cvmfs/cloud.galaxyproject.org

printf "Restarting automount"
service autofs restart

printf "\nTest CVMFS mounted"
ls -alh $CVMFS_PATH

printf "\nCreate dirs"
mkdir -p $LOCAL_CVMFS_PATH && \
mkdir -p /startup/cvmfs/cloud.galaxyproject.org && \
mkdir -p /partial/cvmfs/cloud.galaxyproject.org

printf "\nSync full tool and config dirs"
rsync -aP --exclude '*/.hg*' $CVMFS_PATH/tools $LOCAL_CVMFS_PATH/ && \
rsync -aP $CVMFS_PATH/config $LOCAL_CVMFS_PATH

printf "\nList local CVMFS dir"
ls -alh $LOCAL_CVMFS_PATH && \
du -h -d 1 $LOCAL_CVMFS_PATH

printf "\nSync startup dir"
rsync -amP --exclude='*-data/*' --include='*/' --include='*.xml' --exclude='*' $LOCAL_CVMFS_PATH/tools /startup/cvmfs/cloud.galaxyproject.org/ && \
rsync -aP $LOCAL_CVMFS_PATH/config /startup/cvmfs/cloud.galaxyproject.org/

printf "\nSync partial dir"
rsync -amP --exclude='*-data/*' $LOCAL_CVMFS_PATH/tools /partial/cvmfs/cloud.galaxyproject.org/ && \
rsync -aP $LOCAL_CVMFS_PATH/config /partial/cvmfs/cloud.galaxyproject.org/

printf "\nCreate archives"
mkdir -p /mnt/archives/ && \
(cd $LOCAL_CVMFS_PATH/../.. && tar -zcvf /mnt/archives/contents.tar.gz cvmfs/cloud.galaxyproject.org ) && \
(cd /startup && tar -zcvf /mnt/archives/startup.tar.gz cvmfs/cloud.galaxyproject.org ) && \
(cd /partial && tar -zcvf /mnt/archives/partial.tar.gz cvmfs/cloud.galaxyproject.org )

printf "\nCopy files to GCP bucket"
gsutil -m rsync -r -d /mnt/archives/ gs://cloud-cvmfs/

printf "\nDone."
