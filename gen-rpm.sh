#/bin/sh
# run  gen-debian-package.sh first!
# edit rpm/newscoop.spec file -> set version number
#

RPMVERS=$(awk '/Version:/{print $2;}' rpm/newscoop.spec)
RPMRELEASE=$(awk '/Release:/{printf "-%s",$2;}' rpm/newscoop.spec)
VERSION=$(echo $RPMVERS | sed 's/-.*$//g')
TMP=/tmp
echo "rpm-vers: $RPMVERS"
echo "rpm-release: $RPMRELEASE"
echo "version:  $VERSION"
echo "base-dir: ${TMP}/newscoop-${VERSION}"

if [ ! -d ${TMP}/newscoop-${VERSION}/debian ]; then
	echo "debian pre-build dir not found. run gen-debian-package.sh first."
	exit 1
fi

echo -n "OK? [enter|CTRL-C]" ; read

cp -r ./rpm /tmp/newscoop-${VERSION}/
cd ${TMP}/

# workarounds for Newscoop 4.3.1 spaces in filenames, symbolic links etc.
mv newscoop-${VERSION}/newscoop/vendor/symfony/symfony/src/Symfony/Component/Finder/Tests/Fixtures/with\ space/ newscoop-${VERSION}/newscoop/vendor/symfony/symfony/src/Symfony/Component/Finder/Tests/Fixtures/withspace/

mv newscoop-${VERSION}/newscoop/vendor/symfony/symfony/src/Symfony/Component/Finder/Tests/Fixtures/r+e.gex\[c\]a\(r\)s/ newscoop-${VERSION}/newscoop/vendor/symfony/symfony/src/Symfony/Component/Finder/Tests/Fixtures/regexcars/

mv newscoop-${VERSION}/newscoop/vendor/smarty/smarty-dev/development/Smarty3Doc/Smarty/Compiler/_libs---sysplugins---smarty_internal_compile_block\ -\ new.php.html newscoop-${VERSION}/newscoop/vendor/smarty/smarty-dev/development/Smarty3Doc/Smarty/Compiler/_libs---sysplugins---smarty_internal_compile_block-new.php.html

mv newscoop-${VERSION}/newscoop/vendor/smarty/smarty-dev/development/lexer/Lempar\ Original.php newscoop-${VERSION}/newscoop/vendor/smarty/smarty-dev/development/lexer/LemparOriginal.php
# end workarounds

tar czf /tmp/rpm_newscoop-${VERSION}.tar.gz newscoop-${VERSION}/
cd /tmp/newscoop-${VERSION}/

mv -vi /tmp/rpm_newscoop-${VERSION}.tar.gz ${HOME}/rpmbuild/SOURCES/newscoop-${VERSION}.tar.gz
rpmbuild -bb --sign rpm/newscoop.spec || exit 1

ls -l ${HOME}/rpmbuild/RPMS/*/newscoop-${RPMVERS}${RPMRELEASE}*.rpm
#ls -l ${HOME}/rpmbuild/SRPMS/newscoop-${RPMVERS}${RPMRELEASE}*.src.rpm

if [ `hostname` != "soyuz" ]; then
	exit
fi

echo -n "UPLOAD? [enter|CTRL-C]" ; read

YUMSIG=$(grep -v "^#" ~/.rpmmacros  | grep "_gpg_name  Sourcefabric")

if [ -z "$YUMSIG" ]; then
	YUMHOST=yum.example.com
	YUMPATH=/var/www/yum
else
	YUMHOST=yum.sourcefabric.org
	YUMPATH=/var/www/yum
fi

rsync -P --bwlimit=70 ${HOME}/rpmbuild/RPMS/noarch/newscoop-${RPMVERS}${RPMRELEASE}.noarch.rpm ${YUMHOST}:${YUMPATH}/20/i386/ || exit
rsync -P --bwlimit=70 ${HOME}/rpmbuild/SRPMS/newscoop-${RPMVERS}${RPMRELEASE}.src.rpm ${YUMHOST}:${YUMPATH}/20/source/ || exit

ssh ${YUMHOST} << EOF
cd ${YUMPATH}/20/x86_64/
ln ../i386/newscoop-${RPMVERS}${RPMRELEASE}.noarch.rpm

createrepo ${YUMPATH}/20/source/
createrepo ${YUMPATH}/20/i386/
createrepo ${YUMPATH}/20/x86_64/
EOF
