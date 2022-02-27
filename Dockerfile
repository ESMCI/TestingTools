################################################################################################################
# ESMCI TestingTools/Dockerfile                                                                                    #
#--------------------------------------------------------------------------------------------------------------#
# A base stream9 install + MPI, HDF5, NetCDF and PNetCDF, as well as other core packages for escomp containers #
################################################################################################################

# Use latest Ubuntu:
FROM ubuntu:latest
# Disable prompt
ARG DEBIAN_FRONTEND=noninteractive

# First, we upate the default packages and install some other necessary ones - while this may give
# some people updated versions of packages vs. others, these differences should not be numerically
# important or affect run-time behavior (eg, a newer Bash version, or perl-XML-LibXML version).
RUN apt update

RUN apt install -y file build-essential gfortran doxygen wget \
                   m4 curl libjpeg-dev libz-dev cmake && \
    rm -fr /var/lib/apt/lists/* && \
    apt clean

# Second, let's install MPI - we're doing this by hand because the default packages install into non-standard locations, and 
# we want our image as simple as possible.  We're also going to use MPICH, though any of the MPICH ABI-compatible libraries 
# will work.  This is for future compatibility with offloading to cloud.
ARG MPI_VERSION=3.4.3
RUN mkdir /tmp/sources && \
    cd /tmp/sources && \
    wget -q http://www.mpich.org/static/downloads/${MPI_VERSION}/mpich-${MPI_VERSIN}.tar.gz && \
    tar zxf mpich-${MPI_VERSION}.tar.gz && \
    cd mpich-${MPI_VERSION} && \
    ./configure --with-device=ch3 --prefix=/usr/local && \
    make -j 2 install && \
    rm -rf /tmp/sources 


# Next, let's install HDF5, NetCDF and PNetCDF - we'll do this by hand, since the packaged versions have 
# lots of extra dependencies (at least, as of CentOS 7) and this also lets us control their location (eg, put in /usr/local).
# NOTE: We do want to change where we store the versions / download links, so it's easier to change, but that'll happen later.

ARG HDF5_VERSION_MAJOR=1.12
ARG HDF5_VERSION_MINOR=1
ARG HDF5_VERSION=${HDF5_VERSION_MAJOR}.${HDF5_VERSION_MINOR}
RUN  mkdir /tmp/sources && \
     cd /tmp/sources && \
     wget -q https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${HDF5_VERSION_MAJOR}/hdf5-${HDF5_VERSION}/src/hdf5-${HDF5_VERSION}.tar.gz && \
     tar zxf hdf5-${HDF5_VERSION}.tar.gz && \
     cd hdf5-${HDF5_VERSION} && \
     ./configure --prefix=/usr/local --disable-dap && \
     make -j 2 install && \
     cd /tmp/sources 

ARG NETCDF_C_VERSION=4.7.4
RUN  wget -q https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDF_C_VERSION}.tar.gz && \
     tar -xzf v${NETCDF_C_VERSION}.tar.gz
     cd netcdf-c-${NETCDF_C_VERSION} && \
     ./configure --prefix=/usr/local --disable-dap && \
     make -j 2 install && \
     ldconfig && \
     cd /tmp/sources

ARG NETCDF_F_VERSION=4.5.4
RUN  wget -q  https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${NETCDF_F_VERSION}.tar.gz&& \
     tar zxf v${NETCDF_F_VERSION}.tar.gz && \
     cd netcdf-fortran-${NETCDF_F_VERSION} && \
     ./configure --prefix=/usr/local && \
     make -j 2 install && \
     ldconfig && \
     cd /tmp/sources 

ARG  PNETCDF_VERSION=1.12.3
RUN  wget -q https://parallel-netcdf.github.io/Release/pnetcdf-${PNETCDF_VERSION}.tar.gz && \
     tar zxf pnetcdf-${PNETCDF_VERSION}.tar.gz && \
     cd pnetcdf-${PNETCDF_VERSION} && \
     ./configure --prefix=/usr/local && \
     make -j 2 install && \
     ldconfig && \
     rm -rf /tmp/sources

#RUN groupadd escomp && \
#    useradd -c 'ESCOMP User' -d /home/user -g escomp -m -s /bin/bash user && \
#    echo 'export USER=$(whoami)' >> /etc/profile.d/escomp.sh && \
#    echo 'export PS1="[\u@escomp \W]\$ "' >> /etc/profile.d/escomp.sh && \
#    echo 'user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/escomp
#
#ENV SHELL=/bin/bash \
#    LANG=C.UTF-8  \
#    LC_ALL=C.UTF-8

#USER user
#WORKDIR /home/user
#CMD ["/bin/bash", "-l"]
#ENTRYPOINT ["/bin/bash", "-l"]
