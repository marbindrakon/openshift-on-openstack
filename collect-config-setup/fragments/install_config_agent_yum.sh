#!/bin/bash
set -eux

# OSP_VERSION is set by ENV or by heat string replacement
[ -n "$OSP_VERSION" ] || (echo "Missing required value OSP_VERSION" ; exit 1)

# on Atomic host os-collect-config runs inside a container which is
# fetched&started in another step
[ -e /run/ostree-booted ] && exit 0

if ! yum info os-collect-config; then
    # if os-collect-config package is not available, first check if
    # the repo is available but disabled, otherwise install the package
    # from epel
    subscription-manager repos --disable="rhel-7-server-ose-$OCP_VERSION-rpms"
    if yum repolist disabled|grep rhel-7-server-openstack-$OSP_VERSION-rpms; then
        subscription-manager repos --enable="rhel-7-server-openstack-$OSP_VERSION-rpms"
        if [ "$OSP_VERSION" -lt 10 ] ; then
            subscription-manager repos --enable="rhel-7-server-openstack-$OSP_VERSION-director-rpms"
        fi
    else
        yum -y install centos-release-openstack-liberty
    fi
    subscription-manager repos --enable="rhel-7-server-ose-$OCP_VERSION-rpms"
fi
yum -y install os-collect-config python-zaqarclient os-refresh-config os-apply-config openstack-heat-templates python-oslo-log python-psutil
#yum-config-manager --disable 'epel*'
