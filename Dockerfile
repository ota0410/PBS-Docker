FROM quay.io/rockylinux/rockylinux:8.9

LABEL version="0.8"
LABEL description="OpenPBS Server setting Image"

ARG version="23.06.06"

RUN dnf install -y dnf-plugins-core && dnf config-manager --set-enabled powertools && dnf install -y epel-release
RUN dnf install -y gcc make rpm-build libtool hwloc-devel libX11-devel libXt-devel libedit-devel libical-devel \
                   ncurses-devel perl postgresql-devel postgresql-contrib python3-devel tcl-devel \
                   tk-devel swig expat-devel openssl-devel libXext libXft autoconf automake gcc-c++ cjson-devel

RUN dnf install -y expat libedit postgresql-server postgresql-contrib python3 \
                   sendmail sudo tcl tk libical chkconfig wget cjson

RUN wget https://github.com/openpbs/openpbs/archive/refs/tags/v${version}.tar.gz && tar xzvf v${version}.tar.gz

WORKDIR /openpbs-23.06.06
RUN ./autogen.sh && /openpbs-23.06.06/configure --prefix=/opt/pbs

RUN make -C /openpbs-23.06.06 && make -C /openpbs-23.06.06 install
RUN /opt/pbs/libexec/pbs_postinstall

# change the parameter if you don't want to process the job on headnode
RUN sed -i 's/PBS_START_MOM=0/PBS_START_MOM=1/' /etc/pbs.conf
RUN sed -i 's/PBS_SERVER=[^ ]*/PBS_SERVER=headnode/' /etc/pbs.conf
RUN sed -i 's/ulimit -n/#ulimit -n/' /opt/pbs/lib/init.d/limits.post_services
RUN sed -i 's/cp "$PGSQL_BIN\/pg_resetxlog" "$PBS_HOME\/pgsql\.forupgrade\/bin"//' /opt/pbs/libexec/pbs_habitat
RUN chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp

EXPOSE 15001 15002 15003 15004 15005 15006 15007 15008 15009 17001
COPY hosts /etc/hosts
CMD ["/bin/bash"]

#CMD ["/etc/init.d/pbs","start"]
#CMD ["start"]
