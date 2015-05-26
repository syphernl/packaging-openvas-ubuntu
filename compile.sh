#!/bin/bash
source vars.sh

# Stop on errors
set -e

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

rm release -r
rm packages -r

mkdir release
mkdir packages

CURPATH=$PWD
FILES=$(find "$PWD" -iname \*.tar.gz -printf "%f\n" | grep -v "^openvas-libraries")

# Libraries need to be build prior to any other packages
FILES="$(find "$PWD" -iname openvas-libraries*.tar.gz -printf "%f\n") $FILES"

LIBRARY_VERSION=""

function create_overlay {
  # $1 = greenbone-security-assistant
 if [[ -d "$CURPATH/_overlay/$1" ]];
 then
   echo -e "$COL_GREEN*** Overlaying config for packages ($FN) $COL_RESET"
   cp "$CURPATH/_overlay/$1/"* "$CURPATH/release/$FN/" -r
 fi
}

function compile_component {
  # $1 = greenbone-security-assistant-6.0.3
  cd "$CURPATH/$1"

  if [ -d "build" ];
  then
    echo "$COL_CYAN*** Cleaning up old build"
    rm "build" -r
  fi

  mkdir build
  cd build
  cmake -DCMAKE_BUILD_TYPE:STRING=Release ..
  make install DESTDIR="$CURPATH/release/$FN"
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

 mkdir "$CURPATH/release/$FN"

 tar xfvz "$f"
 cd "$FN"

 compile_component "$FN"

  # Library requires an export for further processing of other packages
  if [[ "$PKG" == "openvas-libraries" ]];
  then
    # This package requires an install before we can build other components.
    # Pretty annoying ..
    make install
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
    ;;
"openvas-libraries")
    DEPENDENCIES=""
    ;;
"openvas-cli")
    DEPENDENCIES=""
    ;;
"greenbone-security-assistant")
    DEPENDENCIES="openvas-libraries libgnutls26 libgcrypt11 libxml2 libxslt1.1 libmicrohttpd10 xsltproc"
    ;;
esac

# Overlay files required to be packaged
create_overlay "$PKG"

# Deal with dependencies
PKG_ACTIONS=""
for d in $DEPENDENCIES
do
  PKG_ACTIONS+="-d $d\n"
done

# Deal with post/after actions
ACTIONS="before-install before-remove before-upgrade after-install after-remove after-upgrade"
for a in $ACTIONS;
do
  # Deal with optional pre/post install scripts
  if [[ -f "$CURPATH/_debian/$PKG.$a" ]];
  then
    PKG_ACTIONS+="--$a $CURPATH/_debian/$PKG.$a\n"
  fi
done

cd "$CURPATH/release/$FN"

 # FPM it
fpm -s dir -t deb \
--url "http://www.openvas.org/" \
--description "The world's most advanced Open Source vulnerability scanner and manager" \
--license "GPL" \
--maintainer "$PKG_MAINTAINER" \
--vendor "$PKG_VENDOR" \
--version "$VERSION" \
--iteration "$ITERATION_PREFIX$REVISION" \
-C "$CURPATH/release/$FN" \
-a amd64 \
$(echo -e $PKG_ACTIONS) \
-n $PKG .

echo -e "$COL_GREEN *** PKG built: $PKG (v $VERSION)!$COL_RESET"

cd $CURPATH

done

# Group packages together
find . -name '*.deb' -exec mv -t "$CURPATH/packages" {} +
