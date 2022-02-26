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

RUN apt install -y file gcc-c++ gfortran doxygen wget libjpeg-dev libz-dev cmake && \
    rm -fr /var/lib/apt/lists/* && \
    apt clean

# Second, let's install MPI - we're doing this by hand because the default packages install into non-standard locations, and 
# we want our image as simple as possible.  We're also going to use MPICH, though any of the MPICH ABI-compatible libraries 
# will work.  This is for future compatibility with offloading to cloud.

RUN mkdir /tmp/sources && \
    cd /tmp/sources && \
    wget -q http://www.mpich.org/static/downloads/3.4.3/mpich-3.4.3.tar.gz && \
    tar zxf mpich-3.4.3.tar.gz && \
    cd mpich-3.4.3 && \
    ./configure --with-device=ch3 --prefix=/usr/local && \
    make -j 2 install && \
    rm -rf /tmp/sources 


# Next, let's install HDF5, NetCDF and PNetCDF - we'll do this by hand, since the packaged versions have 
# lots of extra dependencies (at least, as of CentOS 7) and this also lets us control their location (eg, put in /usr/local).
# NOTE: We do want to change where we store the versions / download links, so it's easier to change, but that'll happen later.
RUN  mkdir /tmp/sources && \
     cd /tmp/sources && \
     wget -q https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-1.12.1/src/hdf5-1.12.1.tar.gz && \
     tar zxf hdf5-1.12.1.tar.gz && \
     cd hdf5-1.12.1 && \
     ./configure --prefix=/usr/local && \
     make -j 2 install && \
     cd /tmp/sources && \
     wget -q ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-c-4.7.4.tar.gz  && \
     tar zxf netcdf-c-4.7.4.tar.gz && \
     cd netcdf-c-4.7.4 && \
     ./configure --prefix=/usr/local && \
     make -j 2 install && \
     ldconfig && \
     cd /tmp/sources && \
     wget -q ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.5.4.tar.gz && \
     tar zxf netcdf-fortran-4.5.4.tar.gz && \
     cd netcdf-fortran-4.5.4 && \
     ./configure --prefix=/usr/local && \
     make -j 2 install && \
     ldconfig && \
     cd /tmp/sources && \
     wget -q https://parallel-netcdf.github.io/Release/pnetcdf-1.12.3.tar.gz && \
     tar zxf pnetcdf-1.12.3.tar.gz && \
     cd pnetcdf-1.12.3 && \
     ./configure --prefix=/usr/local && \
     make -j 2 install && \
     ldconfig && \
     rm -rf /tmp/sources

RUN groupadd escomp && \
    useradd -c 'ESCOMP User' -d /home/user -g escomp -m -s /bin/bash user && \
    echo 'export USER=$(whoami)' >> /etc/profile.d/escomp.sh && \
    echo 'export PS1="[\u@escomp \W]\$ "' >> /etc/profile.d/escomp.sh && \
    echo 'user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/escomp

ENV SHELL=/bin/bash \
    LANG=C.UTF-8  \
    LC_ALL=C.UTF-8

USER user
WORKDIR /home/user
CMD ["/bin/bash", "-l"]
#ENTRYPOINT ["/bin/bash", "-l"]
