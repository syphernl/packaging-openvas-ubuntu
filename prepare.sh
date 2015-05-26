#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  echo "This is required to be done by root (or via sudo)" 2>&1
  exit 1
fi

# Download all OpenVAS / build dependencies
#apt-get install build-essential bison flex cmake pkg-config libglib2.0-0 \
# libglib2.0-dev libgnutls28 libgnutls-dev libpcap0.8 libpcap0.8-dev libgpgme11 \
# libgpgme11-dev doxygen libuuid1 uuid-dev sqlfairy xmltoman sqlite3 libxml2-dev \
# libxslt1.1 libxslt1-dev xsltproc libmicrohttpd-dev libpopt0 libpopt-dev \
# pkg-config libssh-dev libgnutls-dev libglib2.0-dev libpcap-dev libgpgme11-dev \
# uuid-dev bison libksba-dev libhiredis-dev libsnmp-dev sqlite3 libsqlite3-dev \
# cmake build-essential pkg-config doxygen libgcrypt11-dev libglib2.0-dev \
# uuid-dev bison libldap-dev libpcap-dev libhiredis-dev libgpgme11-dev \
# libksba-dev libssh-dev xsltproc libgnutls-dev sqlfairy xmltoman \
# libmicrohttpd-dev libxml2-dev libxslt1-dev expect redis-server nmap \
# texlive-latex-base libldap-2.4-2 libldap2-dev libsqlite3-0 libsqlite3-dev \
# libgnutls-dev autoconf devscripts dpatch libassuan-dev libglib2.0-dev \
# libgpgme11-dev libpcre3-dev libpth-dev libwrap0-dev libgmp-dev libgmp3-dev \
# libgpgme11-dev libopenvas2 libpcre3-dev libpth-dev quilt cmake pkg-config \
# libssh-dev libglib2.0-dev libpcap-dev libgpgme11-dev uuid-dev bison libksba-dev \
# doxygen sqlfairy xmltoman sqlite3 libsqlite3-dev wamerican \
# libmicrohttpd-dev libxml2-dev libxslt1-dev xsltproc libssh2-1-dev libldap2-dev autoconf nmap libgnutls-dev

sudo apt-get install -y build-essential devscripts dpatch libassuan-dev \
 libglib2.0-dev libgpgme11-dev libpcre3-dev libpth-dev libwrap0-dev libgmp-dev libgmp3-dev \
 libgpgme11-dev libopenvas2 libpcre3-dev libpth-dev quilt cmake pkg-config \
 libssh-dev libglib2.0-dev libpcap-dev libgpgme11-dev uuid-dev bison libksba-dev \
 doxygen sqlfairy xmltoman sqlite3 libsqlite3-dev wamerican redis-server libhiredis-dev libsnmp-dev \
 libmicrohttpd-dev libxml2-dev libxslt1-dev xsltproc libssh2-1-dev libldap2-dev autoconf nmap libgnutls-dev \
libpopt-dev heimdal-dev heimdal-multidev libpopt-dev mingw32


# Download all OpenVAS packages
wget -c -N http://wald.intevation.org/frs/download.php/2067/openvas-libraries-8.0.3.tar.gz
wget -c -N http://wald.intevation.org/frs/download.php/2071/openvas-scanner-5.0.3.tar.gz
wget -c -N http://wald.intevation.org/frs/download.php/2075/openvas-manager-6.0.3.tar.gz
wget -c -N http://wald.intevation.org/frs/download.php/2079/greenbone-security-assistant-6.0.3.tar.gz
wget -c -N http://wald.intevation.org/frs/download.php/1987/openvas-cli-1.4.0.tar.gz
#wget -c -N http://wald.intevation.org/frs/download.php/1975/openvas-smb-1.0.1.tar.gz
#wget -c -N https://wald.intevation.org/frs/download.php/1999/ospd-1.0.0.tar.gz
#wget -c -N https://wald.intevation.org/frs/download.php/2005/ospd-ancor-1.0.0.tar.gz
#wget -c -N http://wald.intevation.org/frs/download.php/2003/ospd-ovaldi-1.0.0.tar.gz
#wget -c -N https://wald.intevation.org/frs/download.php/2004/ospd-w3af-1.0.0.tar.gz
