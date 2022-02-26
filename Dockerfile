################################################################################################################
# ESMCI TestingTools/Dockerfile                                                                                    #
#--------------------------------------------------------------------------------------------------------------#
# A base stream9 install + MPI, HDF5, NetCDF and PNetCDF, as well as other core packages for escomp containers #
################################################################################################################

# Use latest Ubuntu:
FROM ubuntu:latest

# First, we upate the default packages and install some other necessary ones - while this may give
# some people updated versions of packages vs. others, these differences should not be numerically
# important or affect run-time behavior (eg, a newer Bash version, or perl-XML-LibXML version).

RUN yum -y update && \
    yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    yum -y install vim emacs-nox git subversion which sudo csh make m4 cmake wget file byacc curl-devel zlib-devel && \
    yum -y install perl-XML-LibXML gcc-gfortran gcc-c++ dnf-plugins-core python3 perl-core && \
    yum -y install ftp xmlstarlet diffutils  && \
    yum -y install git-lfs latexmk texlive-amscls texlive-anyfontsize texlive-cmap texlive-fancyhdr texlive-fncychap \
                   texlive-dvisvgm texlive-metafont texlive-ec texlive-titlesec texlive-babel-english texlive-tabulary \ 
                   texlive-framed texlive-wrapfig texlive-parskip texlive-upquote texlive-capt-of texlive-needspace \
                   texlive-times texlive-makeindex texlive-helvetic texlive-courier texlive-gsftopk texlive-dvips texlive-mfware texlive-dvisvgm && \
    pip3 install rst2pdf sphinx sphinxcontrib-programoutput && \
    pip3 install git+https://github.com/esmci/sphinx_rtd_theme.git@version-dropdown-with-fixes && \
    dnf --enablerepo=powertools install -y blas-devel lapack-devel && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf && \
    ldconfig && \
    yum clean all


# Second, let's install MPI - we're doing this by hand because the default packages install into non-standard locations, and 
# we want our image as simple as possible.  We're also going to use MPICH, though any of the MPICH ABI-compatible libraries 
# will work.  This is for future compatibility with offloading to cloud.

RUN mkdir /tmp/sources && \
    cd /tmp/sources && \
    wget -q http://www.mpich.org/static/downloads/3.3.2/mpich-3.3.2.tar.gz && \
    tar zxf mpich-3.3.2.tar.gz && \
    cd mpich-3.3.2 && \
    ./configure --prefix=/usr/local && \
    make -j 2 install && \
    rm -rf /tmp/sources 


# Next, let's install HDF5, NetCDF and PNetCDF - we'll do this by hand, since the packaged versions have 
# lots of extra dependencies (at least, as of CentOS 7) and this also lets us control their location (eg, put in /usr/local).
# NOTE: We do want to change where we store the versions / download links, so it's easier to change, but that'll happen later.
RUN  mkdir /tmp/sources && \
     cd /tmp/sources && \
     wget -q https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-1.12.0/src/hdf5-1.12.0.tar.gz && \
     tar zxf hdf5-1.12.0.tar.gz && \
     cd hdf5-1.12.0 && \
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
     wget -q ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.5.3.tar.gz && \
     tar zxf netcdf-fortran-4.5.3.tar.gz && \
     cd netcdf-fortran-4.5.3 && \
     ./configure --prefix=/usr/local && \
     make -j 2 install && \
     ldconfig && \
     cd /tmp/sources && \
     wget -q https://parallel-netcdf.github.io/Release/pnetcdf-1.12.1.tar.gz && \
     tar zxf pnetcdf-1.12.1.tar.gz && \
     cd pnetcdf-1.12.1 && \
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
