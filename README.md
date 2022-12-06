Used to clone the Galaxy tools from CVMFS to a bucket.

## Why does this functionality exist?

This is done to allow others to provide their own tool suite, to eliminate the
need for CVMFS on startup, and to speed up the Galaxy startup time.

## How does it work?

Defining which tools are included in the default installation is governed by the
[usegalaxy-tools/cloud](https://github.com/galaxyproject/usegalaxy-tools/tree/master/cloud)
repo, which places the tool definitions onto Galaxy's CVMFS. The code in this
repo uses GitHub Actions to mount CMVFS, create archives of the tool
definitions, and places copies of the archives to a [public GCP
bucket](https://console.cloud.google.com/storage/browser/cloud-cvmfs). When
Galaxy is deployed using Galaxy Helm, these [archives are retrieved at
startup](https://github.com/galaxyproject/galaxy-helm/blob/a08bbae28a3dbd991489fdfa9cf1b839cc9357a7/galaxy/values.yaml#L200),
providing tool definitions in Galaxy.

### Why are there multiple archives?

There are 3 archives in total, `startup`, `partial`, and `full`. The *startup*
one contains Galaxy configuration files and tool XML wrappers. The archive is a
few MB in size and this is enough information for Galaxy handlers to start. The
*partial* archive is a couple hundred MB and it also includes any tool scripts
allowing the tools to actually run when invoked. The *full* archive (~1.2GB)
includes the tool test data so it can be used as part of tool testing infrastructure.
