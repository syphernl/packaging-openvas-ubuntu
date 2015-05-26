#!/bin/bash
source vars.sh

rm builds -r
rm packages -r

mkdir builds
mkdir packages

CURPATH=$PWD
FILES=$(find "$PWD" -iname \*.tar.gz -printf "%f\n" | grep -v "^openvas-libraries")

# Libraries need to be build prior to any other packages
FILES="$(find "$PWD" -iname openvas-libraries*.tar.gz -printf "%f\n") $FILES"

LIBRARY_VERSION=""

###############
## Create DEB
##############
REVISION=$[$(cat revision) + 1]
echo "$REVISION" > revision

for f in $FILES
do
 echo "Processing $f"
 FN=$(echo $f | sed 's/.tar.gz//g')
 VERSION=$(echo $FN | sed -nre 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p')
 PKG=$(echo $FN | sed "s/\-$VERSION//g")

 mkdir "builds/$FN"

 tar xfvz "$f"
 cd "$FN"

 if [[ "$PKG" == "openvas-libraries" ]];
 then
  # Special case package due to ordering
  export PKG_CONFIG_PATH="$CURPATH/$FN":$PKG_CONFIG_PATH
 fi

 cmake -DCMAKE_INSTALL_PREFIX= .
 make install DESTDIR="$CURPATH/builds/$FN"

function create_overlay {
 # $1 = greenbone-security-assistant
 cp "$CURPATH/_overlay/$1/"* "$PWD/builds/$FN/" -r
}

###############
## Create DEB
##############
# Add per-package dependencies
DEPENDENCIES=""
case "$PKG" in
"openvas-scanner")
    DEPENDENCIES="libgpgme11 libksba8 libsnmp30 libssh-4 libhiredis0.10 openvas-libraries libgnutls26 libgcrypt20 libsqlite3-0"
    ;;
"openvas-manager")
    DEPENDENCIES="libgnutls26 openvas-libraries libsqlite3-0"
    # Overlay init script
    create_overlay "openvas-manager"
    ;;
"openvas-libraries")
    DEPENDENCIES=""
    ;;
"openvas-cli")
    DEPENDENCIES=""
    ;;
"greenbone-security-assistant")
    DEPENDENCIES="openvas-libraries libgnutls26 libgcrypt11 libxml2 libxslt1.1 libmicrohttpd10 xsltproc"
    # Overlay init script
    create_overlay "greenbone-security-assistant"
    ;;

esac

# Deal with dependencies
PKG_DEP=""
for d in $DEPENDENCIES
do
   PKG_DEP+="-d $d\n"
done

 # FPM it
fpm -s dir -t deb \
--url "http://www.openvas.org/" \
--description "The world's most advanced Open Source vulnerability scanner and manager" \
--license "GPL" \
--maintainer "$PKG_MAINTAINER" \
--vendor "$PKG_VENDOR" \
--version "$VERSION" \
--iteration "$ITERATION_PREFIX$REVISION" \
-C "$PWD/builds/$FN" \
-a amd64 \
$(echo -e $PKG_DEP) \
-n $PKG .

 cd -

done

# Group packages together
find . -name '*.deb' -exec mv -t "$CURPATH/packages" {} +
