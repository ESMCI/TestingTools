# TestingTools Tools for Docker Image and Github Actions 

The Dockerfiles at the top level provide builds of the Linux Ubuntu
distribution with builds of an mpi library (currently mpich, openmpi
and the mct mpi-serial library) along with parallel builds of hdf5
netcdf and pnetcdf.  Builds are pushed to dockerhub where they can be
downloaded for testing of other projects.

github actions will check the Dockerfiles and rebuild and push any
that have changed since the last build.