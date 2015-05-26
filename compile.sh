#!/bin/bash
source vars.sh

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

rm builds -r
rm packages -r

mkdir builds
mkdir packages

CURPATH=$PWD
FILES=$(find "$PWD" -iname \*.tar.gz -printf "%f\n" | grep -v "^openvas-libraries")

# Libraries need to be build prior to any other packages
FILES="$(find "$PWD" -iname openvas-libraries*.tar.gz -printf "%f\n") $FILES"

LIBRARY_VERSION=""

function create_overlay {
 # $1 = greenbone-security-assistant
 echo -e "$COL_GREEN*** Overlaying config for packages ($FN) $COL_RESET"
 cp "$CURPATH/_overlay/$1/"* "$CURPATH/builds/$FN/" -r
}

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

 echo -e "$COL_GREEN*** Building package $PKG (version: $VERSION) $COL_RESET"

 mkdir "builds/$FN"

 tar xfvz "$f"
 cd "$FN"

 cmake -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX= .
 make install DESTDIR="$CURPATH/builds/$FN"

 # Library requires an export for further processing of other packages
 if [[ "$PKG" == "openvas-libraries" ]];
 then
  # Special case package due to ordering
  export PKG_CONFIG_PATH="$CURPATH/builds/$FN/lib64/pkgconfig"
  echo -e "$COL_GREEN*** Set library: $PKG_CONFIG_PATH $COL_RESET"
 else
  echo -e "$COL_YELLOW*** Using library: $PKG_CONFIG_PATH"
 fi


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
-C "$CURPATH/builds/$FN" \
-a amd64 \
$(echo -e $PKG_DEP) \
-n $PKG .

echo -e "$COL_GREEN *** PKG built: $PKG (v $VERSION)!$COL_RESET"

cd -

done

# Group packages together
find . -name '*.deb' -exec mv -t "$CURPATH/packages" {} +
