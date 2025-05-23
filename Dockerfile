FROM quay.io/rockylinux/rockylinux:8.9

LABEL version="1.0"
LABEL description="OpenPBS Server setting Image"

# Give the version of OpenPBS
ARG version="23.06.06"

# Install some packages. See https://github.com/openpbs/openpbs
RUN dnf install -y dnf-plugins-core && dnf config-manager --set-enabled powertools && dnf install -y epel-release \
    && dnf install -y \
       gcc \
       make \
       rpm-build \
       libtool \
       hwloc-devel \
       libX11-devel \
       libXt-devel \
       libedit-devel \
       libical-devel \
       ncurses-devel \
       perl \
       postgresql-devel \
       postgresql-contrib \
       python3-devel tcl-devel \
       tk-devel \
       swig \
       expat-devel \
       openssl-devel \
       libXext \
       libXft \
       autoconf \
       automake \
       gcc-c++ \
       cjson-devel \
       expat \
       libedit \
       postgresql-server \
       postgresql-contrib python3 \
       sendmail \
       sudo \
       tcl \
       tk \
       libical \
       chkconfig \
       wget \
       cjson

# Download the openpbs packages.
RUN wget https://github.com/openpbs/openpbs/archive/refs/tags/v${version}.tar.gz && tar xzvf v${version}.tar.gz

# Build the package here
WORKDIR /openpbs-${version}
RUN ./autogen.sh && /openpbs-${version}/configure --prefix=/opt/pbs \
    && make -C /openpbs-${version} && make -C /openpbs-${version} install \
    && /opt/pbs/libexec/pbs_postinstall

# Change the parameter, MOM if you don't want to process the job on headnode
# RUN sed -i 's/PBS_START_MOM=0/PBS_START_MOM=1/' /etc/pbs.conf
RUN sed -i 's/PBS_SERVER=[^ ]*/PBS_SERVER=headnode/' /etc/pbs.conf \
    && sed -i 's/ulimit -n/#ulimit -n/' /opt/pbs/lib/init.d/limits.post_services \
    && sed -i 's/cp "$PGSQL_BIN\/pg_resetxlog" "$PBS_HOME\/pgsql\.forupgrade\/bin"//' /opt/pbs/libexec/pbs_habitat \
    && chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp

# Following Ports are used in communication between PBS master and MoM
EXPOSE 15001
EXPOSE 15002
EXPOSE 15003
EXPOSE 15004
EXPOSE 15005
EXPOSE 15006
EXPOSE 15007
EXPOSE 15008
EXPOSE 15009
EXPOSE 17001

# Start bash in default
CMD ["/bin/bash"]

# Please start the service /etc/init.d/pbs start in the container and quit ctrl+p,q (Bug??)