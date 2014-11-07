#!/bin/bash
# usage from git-repo:
#  ./gen-debian-package.sh -rfakeroot -sa

#
# Note to self:
# git archive --format tar release-3.5.0-GA newscoop/ | gzip -9 > /tmp/newscoop-3.5.0.tar.gz

DEBRELEASE=$(head -n1 debian/changelog | cut -d ' ' -f 2 | sed 's/[()]*//g')
DEBVERSION=$(echo $DEBRELEASE | sed 's/-.*$//g;s/~test[0-9]*//g')
UPSTREAMVERSION=$(echo $DEBVERSION | sed 's/~/-/g')
UPSTREAMDIST=$(echo $UPSTREAMVERSION | sed 's/^\([0-9]*\.[0-9]*\).*$/\1/')
SFOCUSTOM=""
DEBPATH=`pwd`/debian # TODO check dirname $0
MIRRORPATH=/tmp
BUILDDEST=/tmp/newscoop-${DEBVERSION}/

if test ! -d ${DEBPATH}; then
  echo "can not find debian/ folder. Please 'cd <newscoop-git>/packaging/'"
  exit;
fi

echo "Debian Release:   ${DEBRELEASE}"
echo "Upstream Version: ${UPSTREAMVERSION}${SFOCUSTOM}"
echo "Major:            ${UPSTREAMDIST}"
echo "debuild opts:     $@"
echo "build folder:     /tmp/newscoop-$DEBVERSION"

echo -n "OK? [enter|CTRL-C]" ; read

rm -rf /tmp/newscoop-$DEBVERSION
mkdir  /tmp/newscoop-$DEBVERSION
cd     /tmp/newscoop-$DEBVERSION

echo -n " +++ building newscoop-${DEBVERSION}.deb in: "
pwd
echo " +++ downloading upstream release..."

if [ -f ${MIRRORPATH}/newscoop-$UPSTREAMVERSION.tar.gz ]; then
	echo "using local file ${MIRRORPATH}/newscoop-$UPSTREAMVERSION.tar.gz"
  tar xzf ${MIRRORPATH}/newscoop-$UPSTREAMVERSION.tar.gz

elif [ -f ${MIRRORPATH}/newscoop-$UPSTREAMDIST$SFOCUSTOM.tar.gz ]; then
	echo "using local file ${MIRRORPATH}/newscoop-$UPSTREAMDIST$SFOCUSTOM.tar.gz"
  tar xzf ${MIRRORPATH}/newscoop-$UPSTREAMDIST$SFOCUSTOM.tar.gz

elif [ -n "$CUSTOMURL" ]; then
	echo "...from ${CUSTOMURL}"
	curl -L ${CUSTOMURL} \
		| tee ${MIRRORPATH}/newscoop-$UPSTREAMDIST.tar.gz \
		| tar xzf - || exit
else
	echo "...from GitHub"

  curl -L https://github.com/sourcefabric/Newscoop/releases/download/$UPSTREAMVERSION/newscoop-$UPSTREAMVERSION.tar.gz \
		| tee ${MIRRORPATH}/newscoop-$UPSTREAMVERSION.tar.gz \
		| tar xzf - || exit
fi

# done in README.Debian
#rm newscoop/INSTALL.txt

# Sourcefabric licenses covered by debian/copyright
rm newscoop/COPYING.txt
rm newscoop/LICENSE_3RD_PARTY.txt

# third party licences covered by debian/copyright
rm newscoop/include/html2pdf/_tcpdf_5.0.002/LICENSE.TXT
rm newscoop/js/domTT/LICENSE
rm newscoop/js/flowplayer/LICENSE.txt
rm newscoop/js/geocoding/openlayers/license.txt
rm newscoop/js/plupload/license.txt
rm newscoop/js/tinymce/license.txt
rm newscoop/library/Nette/license.txt
rm newscoop/include/html2pdf/_tcpdf_5.0.002/fonts/dejavu-fonts-ttf-2.30/LICENSE
rm newscoop/include/html2pdf/_tcpdf_5.0.002/fonts/freefont-20090104/COPYING
rm newscoop/js/tapmodo-Jcrop-5e58bc9/MIT-LICENSE.txt
rm newscoop/js/tapmodo-Jcrop-5e58bc9/build/LICENSE

rm newscoop/vendor/doctrine/common/LICENSE
rm newscoop/vendor/doctrine/dbal/LICENSE
rm newscoop/vendor/doctrine/orm/LICENSE
rm newscoop/vendor/bombayworks/zendframework1/LICENSE.txt
rm newscoop/vendor/guzzle/guzzle/LICENSE

# remove fonts installed as a package dependency
rm -r newscoop/include/captcha/fonts/

# fix the font path for captcha
sed -i "5s:('fonts/VeraBd.ttf', 'fonts/VeraIt.ttf', 'fonts/Vera.ttf'):('/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans-Bold.ttf', '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSansMono.ttf', '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSerif.ttf'):g" newscoop/include/captcha/image.php

# documentation for /usr/share/doc/newscoop
for file in ChangeLog; do
  mv -vi newscoop/${file}.txt newscoop/${file}
done
mv newscoop/ChangeLog newscoop/changelog
cp -vi newscoop/htaccess.dist newscoop/.htaccess

# remove sample data now in separate package
rm -r newscoop/install/Resources/sample_data/*
rm newscoop/install/Resources/sql/campsite_demo_data.sql
rm newscoop/install/Resources/sql/campsite_demo_tables.sql

# remove geonames.org data now in separate package
rm newscoop/install/Resources/sql/CityLocations.csv
rm newscoop/install/Resources/sql/CityNames.csv

### fixes for 4.3.0 ###
if test "${UPSTREAMVERSION}" == "4.3.0"; then

#sed -i "1s:sh:bash:" newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/build_tarball.sh

rm -rf newscoop/vendor/behat/behat/.git/
rm -rf newscoop/vendor/behat/common-contexts/.git/
rm -rf newscoop/vendor/behat/gherkin/.git/
rm -rf newscoop/vendor/doctrine/cache/.git/
rm -rf newscoop/vendor/doctrine/collections/.git/
rm -rf newscoop/vendor/doctrine/dbal/.git/
rm -rf newscoop/vendor/doctrine/doctrine-bundle/Doctrine/Bundle/DoctrineBundle/.git/
rm -rf newscoop/vendor/doctrine/inflector/.git/
rm -rf newscoop/vendor/doctrine/lexer/.git/
rm -rf newscoop/vendor/doctrine/orm/.git/
rm -rf newscoop/vendor/friendsofsymfony/rest/FOS/Rest/.git/
rm -rf newscoop/vendor/guzzle/guzzle/.git/
rm -rf newscoop/vendor/hybridauth/hybridauth/.git/
rm -rf newscoop/vendor/jdorn/sql-formatter/.git/
rm -rf newscoop/vendor/jms/aop-bundle/JMS/AopBundle/.git/
rm -rf newscoop/vendor/jms/cg/.git/
rm -rf newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/.git/
rm -rf newscoop/vendor/jms/metadata/.git/
rm -rf newscoop/vendor/jms/parser-lib/.git/
rm -rf newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/.git/
rm -rf newscoop/vendor/jms/serializer-bundle/JMS/SerializerBundle/.git/
rm -rf newscoop/vendor/kriswallsmith/buzz/.git/
rm -rf newscoop/vendor/monolog/monolog/.git/
rm -rf newscoop/vendor/noiselabs/smarty-bundle/NoiseLabs/Bundle/SmartyBundle/.git/
rm -rf newscoop/vendor/phpcollection/phpcollection/.git/
rm -rf newscoop/vendor/phpoption/phpoption/.git/
rm -rf newscoop/vendor/rezzza/mailchimp/Rezzza/MailChimp/.git/
rm -rf newscoop/vendor/sensio/distribution-bundle/Sensio/Bundle/DistributionBundle/.git/
rm -rf newscoop/vendor/sensio/framework-extra-bundle/Sensio/Bundle/FrameworkExtraBundle/.git/
rm -rf newscoop/vendor/sensio/generator-bundle/Sensio/Bundle/GeneratorBundle/.git/
rm -rf newscoop/vendor/symfony/monolog-bundle/Symfony/Bundle/MonologBundle/.git/
rm -rf newscoop/vendor/symfony/swiftmailer-bundle/Symfony/Bundle/SwiftmailerBundle/.git/
rm -rf newscoop/vendor/symfony/symfony/.git/
rm -rf newscoop/vendor/twig/twig/.git/

rm newscoop/vendor/behat/behat/.gitignore
rm newscoop/vendor/behat/common-contexts/.gitignore
rm newscoop/vendor/behat/gherkin/.gitignore
rm newscoop/vendor/doctrine/annotations/.gitignore
rm newscoop/vendor/doctrine/common/.gitignore
rm newscoop/vendor/doctrine/common/tests/.gitignore
rm newscoop/vendor/doctrine/dbal/.gitignore
rm newscoop/vendor/doctrine/dbal/tests/.gitignore
rm newscoop/vendor/doctrine/doctrine-bundle/Doctrine/Bundle/DoctrineBundle/.gitignore
rm newscoop/vendor/doctrine/orm/.gitignore
rm newscoop/vendor/doctrine/orm/tests/.gitignore
rm newscoop/vendor/friendsofsymfony/rest-bundle/FOS/RestBundle/.gitignore
rm newscoop/vendor/friendsofsymfony/rest/FOS/Rest/.gitignore
rm newscoop/vendor/guzzle/guzzle/.gitignore
rm newscoop/vendor/jdorn/sql-formatter/.gitignore
rm newscoop/vendor/jms/metadata/.gitignore
rm newscoop/vendor/jms/parser-lib/.gitignore
rm newscoop/vendor/jms/serializer-bundle/JMS/SerializerBundle/.gitignore
rm newscoop/vendor/jms/serializer/.gitignore
rm newscoop/vendor/knplabs/knp-components/.gitignore
rm newscoop/vendor/knplabs/knp-paginator-bundle/Knp/Bundle/PaginatorBundle/.gitignore
rm newscoop/vendor/kriswallsmith/buzz/.gitignore
rm newscoop/vendor/noiselabs/smarty-bundle/NoiseLabs/Bundle/SmartyBundle/.gitignore
rm newscoop/vendor/phpcollection/phpcollection/.gitignore
rm newscoop/vendor/phpoption/phpoption/.gitignore
rm newscoop/vendor/psr/log/.gitignore
rm newscoop/vendor/sensio/distribution-bundle/Sensio/Bundle/DistributionBundle/.gitignore
rm newscoop/vendor/sensio/framework-extra-bundle/Sensio/Bundle/FrameworkExtraBundle/.gitignore
rm newscoop/vendor/sensio/generator-bundle/Sensio/Bundle/GeneratorBundle/.gitignore
rm newscoop/vendor/swiftmailer/swiftmailer/.gitignore
rm newscoop/vendor/symfony/assetic-bundle/Symfony/Bundle/AsseticBundle/.gitignore
rm newscoop/vendor/symfony/monolog-bundle/Symfony/Bundle/MonologBundle/.gitignore
rm newscoop/vendor/symfony/symfony/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bridge/Doctrine/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bridge/Monolog/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bridge/Propel1/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bridge/Twig/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bundle/SecurityBundle/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bundle/TwigBundle/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bundle/WebProfilerBundle/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/BrowserKit/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/ClassLoader/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Config/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Console/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/CssSelector/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/DependencyInjection/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/DomCrawler/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/EventDispatcher/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Filesystem/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Finder/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Form/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/HttpFoundation/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/HttpKernel/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Locale/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/OptionsResolver/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Process/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/PropertyAccess/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Routing/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Security/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Serializer/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Stopwatch/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Templating/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Translation/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Validator/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Yaml/.gitignore
rm newscoop/vendor/twig/twig/.gitignore
rm newscoop/vendor/twig/twig/ext/twig/.gitignore

rm newscoop/vendor/dflydev/doctrine-orm-service-provider/.gitignore
rm newscoop/vendor/doctrine/cache/.gitignore
rm newscoop/vendor/doctrine/collections/.gitignore
rm newscoop/vendor/doctrine/inflector/.gitignore
rm newscoop/vendor/doctrine/instantiator/.gitignore
rm newscoop/vendor/friendsofsymfony/jsrouting-bundle/FOS/JsRoutingBundle/.gitignore
rm newscoop/vendor/friendsofsymfony/oauth-server-bundle/FOS/OAuthServerBundle/.gitignore
rm newscoop/vendor/friendsofsymfony/oauth2-php/.gitignore
rm newscoop/vendor/hellogerard/jobby/.gitignore
rm newscoop/vendor/imagine/imagine/.gitignore
rm newscoop/vendor/imagine/imagine/docs/_themes/.gitignore
rm newscoop/vendor/incenteev/composer-parameter-handler/Incenteev/ParameterHandler/.gitignore
rm newscoop/vendor/jeremeamia/SuperClosure/.gitignore
rm newscoop/vendor/knplabs/knp-menu-bundle/Knp/Bundle/MenuBundle/.gitignore
rm newscoop/vendor/knplabs/knp-menu/.gitignore
rm newscoop/vendor/knplabs/packagist-api/.gitignore
rm newscoop/vendor/mtdowling/cron-expression/.gitignore
rm newscoop/vendor/nelmio/api-doc-bundle/Nelmio/ApiDocBundle/.gitignore
rm newscoop/vendor/phpdocumentor/reflection-docblock/.gitignore
rm newscoop/vendor/phpspec/prophecy-phpunit/Prophecy/PhpUnit/.gitignore
rm newscoop/vendor/phpspec/prophecy/.gitignore
rm newscoop/vendor/phpunit/php-code-coverage/.gitignore
rm newscoop/vendor/phpunit/php-file-iterator/.gitignore
rm newscoop/vendor/phpunit/php-text-template/.gitignore
rm newscoop/vendor/phpunit/php-timer/.gitignore
rm newscoop/vendor/phpunit/php-token-stream/.gitignore
rm newscoop/vendor/phpunit/phpunit-mock-objects/.gitignore
rm newscoop/vendor/phpunit/phpunit/.gitignore
rm newscoop/vendor/pimple/pimple/.gitignore
rm newscoop/vendor/raulfraile/ladybug-bundle/RaulFraile/Bundle/LadybugBundle/.gitignore
rm newscoop/vendor/raulfraile/ladybug/.gitignore
rm newscoop/vendor/raven/raven/.gitignore
rm newscoop/vendor/sebastian/comparator/.gitignore
rm newscoop/vendor/sebastian/diff/.gitignore
rm newscoop/vendor/sebastian/environment/.gitignore
rm newscoop/vendor/sebastian/exporter/.gitignore
rm newscoop/vendor/sebastian/global-state/.gitignore
rm newscoop/vendor/sebastian/version/.gitignore
rm newscoop/vendor/silex/silex/.gitignore
rm newscoop/vendor/smarty/smarty-dev/.gitignore
rm newscoop/vendor/smarty/smarty/.gitignore
rm newscoop/vendor/symfony/swiftmailer-bundle/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bridge/ProxyManager/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bridge/Swiftmailer/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bundle/FrameworkBundle/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Debug/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Intl/.gitignore
rm newscoop/vendor/twig/extensions/.gitignore
rm newscoop/vendor/willdurand/js-translation-bundle/Bazinga/ExposeTranslationBundle/.gitignore
rm newscoop/vendor/willdurand/jsonp-callback-validator/.gitignore
rm newscoop/vendor/willdurand/negotiation/.gitignore
rm newscoop/vendor/yzalis/crontab/.gitignore

rm newscoop/vendor/smarty/smarty-dev/documentation/entities/.cvsignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Console/Resources/bin/hiddeninput.exe

chmod +x newscoop/bin/post-install.sh
chmod +x newscoop/vendor/doctrine/dbal/bin/doctrine-dbal
chmod +x newscoop/vendor/knplabs/knp-components/bin/vendors.php
chmod +x newscoop/vendor/doctrine/orm/bin/doctrine

chmod +x newscoop/application/console
chmod +x newscoop/bin/events-notifier
chmod +x newscoop/bin/newscoop-autopublish
chmod +x newscoop/bin/newscoop-indexer
chmod +x newscoop/bin/newscoop-statistics
chmod +x newscoop/bin/newscoop-stats
chmod +x newscoop/bin/subscription-notifier
chmod +x newscoop/scripts/fixer.php
chmod +x newscoop/vendor/raulfraile/ladybug/bin/deploy.php
chmod +x newscoop/vendor/smarty/smarty-dev/development/PHPunit/_phpunit-tests-coverage.sh
chmod +x newscoop/vendor/smarty/smarty-dev/development/PHPunit/_phpunit-tests-single.sh
chmod +x newscoop/vendor/smarty/smarty-dev/development/PHPunit/_phpunit-tests.sh
chmod +x newscoop/vendor/swiftmailer/swiftmailer/tests/_samples/smime/create-cert.sh

chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7e.php
chmod -x newscoop/admin-files/media-archive/multiedit_file.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x97.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumEntry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/App/FeedEntryParent.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumQuery.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9a.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumFeed.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GmlPos.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb4.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/Extension/Ccr.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x01.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x81.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6a.php
chmod -x newscoop/vendor/friendsofsymfony/rest-bundle/FOS/RestBundle/Controller/Annotations/Options.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc5.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x66.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer/Disk.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x04.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb5.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Nickname.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Checksum.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Control.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Time.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/QuotaCurrent.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x78.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Value/Messaging/ArrayCollection.php
chmod -x newscoop/template_engine/classes/CampContext.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Entry.php
chmod -x newscoop/template_engine/metaclasses/MetaActionPreview_Comment.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Position.php
chmod -x newscoop/classes/Translation.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcf.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Writer/Json.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x50.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/LICENSE
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCategory.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x20.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/CommentingEnabled.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x86.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaContent.php
chmod -x newscoop/admin-files/articles/context_box/popup.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xff.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5b.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa4.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer/ShMem.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Adapter/ZendQueue.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xce.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x94.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x1f.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x12.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaContent.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x73.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4f.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xca.php
chmod -x newscoop/vendor/behat/behat/bin/behat.bat
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xad.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x2e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Token.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6d.php
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Config/Tests/Definition/Builder/NumericNodeDefinitionTest.php
chmod -x newscoop/library/Newscoop/Entity/Repository/PlaylistRepository.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0b.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x75.php
chmod -x newscoop/application.php
chmod -x newscoop/index.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd2.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x25.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb0.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x72.php
chmod -x newscoop/library/Newscoop/Entity/Issue.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer.php
chmod -x newscoop/template_engine/metaclasses/MetaActionSubmit_Comment.php
chmod -x newscoop/application/modules/admin/views/scripts/playlist/popup.phtml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaText.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbb.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x10.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x16.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Twitter.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd6.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/DocumentListEntry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Twitter/Exception.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Distance.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc7.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/FStop.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Client.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/MediaEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x90.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileListEntry.php
chmod -x newscoop/admin-files/articles/add.php
chmod -x newscoop/application/layouts/scripts/admin_menu.phtml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/TagEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x28.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x03.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaThumbnail.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/CountHint.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5d.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x52.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3/Exception.php
chmod -x newscoop/library/Newscoop/Entity/Topic.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8a.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GeoRssWhere.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/CommentEntry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Rotation.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc2.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc1.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x24.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x15.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x82.php
chmod -x newscoop/js/newscoop_rest_api.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x92.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Writer/Yaml.php
chmod -x newscoop/include/smarty/campsite_plugins/function.uri.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x77.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x21.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Tags.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcb.php
chmod -x newscoop/vendor/doctrine/orm/bin/doctrine.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Version.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Auth/Abstract.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x87.php
chmod -x newscoop/classes/Article.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Entry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/Query.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x65.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x64.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x57.php
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Security/Tests/Core/Util/StringUtilsTest.php
chmod -x newscoop/library/Newscoop/Services/Ingest/PublisherService.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/AbstractFactory.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x58.php
chmod -x newscoop/application/modules/admin/controllers/LegacyController.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0f.php
chmod -x newscoop/upgrade.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbf.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4d.php
chmod -x newscoop/classes/ArticleIndex.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaRating.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x05.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x63.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x98.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x13.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaDescription.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x80.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x55.php
chmod -x newscoop/src/Newscoop/GimmeBundle/Serializer/Article/RenditionsHandler.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserFeed.php
chmod -x newscoop/application/modules/admin/controllers/PlaylistController.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x83.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Feed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x95.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc3.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/App/Feed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x32.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Id.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x76.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/DocumentService/Adapter/WindowsAzure.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileListFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/CommentCount.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa2.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserQuery.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x69.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Make.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCredit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Iso.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb8.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x1e.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7a.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x51.php
chmod -x newscoop/vendor/doctrine/orm/tests/Doctrine/Tests/ORM/Functional/Ticket/DDC2012Test.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Link.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x17.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Name.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc9.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoQuery.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GmlPoint.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb7.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaHash.php
chmod -x newscoop/library/Newscoop/Router/RouterFactory.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Weight.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x59.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Message.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Parse/Resource/MysqlResult.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfa.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd4.php
chmod -x newscoop/template_engine/metaclasses/MetaTopic.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Thumbnail.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Entry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x93.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x61.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc8.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x07.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo.php
chmod -x newscoop/library/Newscoop/Services/IngestService.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x26.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xae.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/ImageUniqueId.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Captcha/Exception.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xba.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0c.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaKeywords.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Flash.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x79.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Books.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x99.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd7.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfd.php
chmod -x newscoop/template_engine/classes/CampVersion.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaGroup.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd5.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x68.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x31.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x02.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/Auth.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x11.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Http/Client/Adapter/Stream.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Height.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Location.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x54.php
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Security/Tests/Core/Util/SecureRandomTest.php
chmod -x newscoop/vendor/bombayworks/zendframework1/bin/zf.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Access.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Width.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5a.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Parse/Resource/Stream.php
chmod -x newscoop/library/Newscoop/Tools/Console/Command/UpdateIngestCommand.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd0.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa1.php
chmod -x newscoop/application/controllers/TopicController.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/FocalLength.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcc.php
chmod -x newscoop/admin-files/camp_html.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Model.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xaf.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Timestamp.php
chmod -x newscoop/application/Bootstrap.php
chmod -x newscoop/admin-files/articles/get.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6e.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x22.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbd.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x74.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd3.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcd.php
chmod -x newscoop/admin-files/media-archive/add_file.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xac.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6b.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x27.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfc.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0a.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x62.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaPlayer.php
chmod -x newscoop/vendor/bombayworks/zendframework1/bin/zf.bat
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/Query.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6f.php
chmod -x newscoop/src/Newscoop/GimmeBundle/Resources/config/serializer/newscoop/Article.yml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Private.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/DocumentService/Adapter/WindowsAzure/Query.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x89.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/Exception.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x33.php
chmod -x newscoop/admin-files/libs/ContextList/ContextList.php
chmod -x newscoop/library/Newscoop/Entity/Repository/ArticleRepository.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7f.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb9.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x56.php
chmod -x newscoop/application/views/scripts/topic_articles.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3/Stream.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaRestriction.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaGroup.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x70.php
chmod -x newscoop/vendor/guzzle/guzzle/tests/Guzzle/Tests/TestData/FileBody.txt
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/HttpKernel/Tests/Config/FileLocatorTest.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x2f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaTitle.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Yaml.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa0.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbc.php
chmod -x newscoop/library/Newscoop/Entity/Article.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/NumPhotosRemaining.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCopyright.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8b.php
chmod -x newscoop/admin-files/libs/ArticleList/do_action.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xf9.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Feed.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Exposure.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x00.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x84.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd1.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc0.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Books/VolumeQuery.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb2.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x23.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x67.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x18.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9e.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/BytesUsed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/Transliterator.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/DublinCore.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x53.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Feed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb6.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/PhotoId.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8e.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x30.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/User.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfb.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/AlbumId.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb1.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/DbInspector.php
chmod -x newscoop/src/Newscoop/GimmeBundle/Resources/config/serializer/newscoop/Comment.yml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Http/Response/Stream.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa3.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x88.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/DocumentListFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x91.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Json.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x60.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbe.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Adapter/WindowsAzure.php
chmod -x newscoop/application/controllers/ImageController.php
chmod -x newscoop/admin-files/articles/add_move.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb3.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/Introspector.php
chmod -x newscoop/admin-files/pub/edit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Size.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/MaxPhotosPerAlbum.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/NumPhotos.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x06.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaRating.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc4.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x09.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x71.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x96.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/QuotaLimit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x85.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7b.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x14.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfe.php
chmod -x newscoop/classes/RequestObject.php
chmod -x newscoop/admin-files/pub/index.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc6.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9b.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7e.php
chmod -x newscoop/admin-files/media-archive/multiedit_file.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x97.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumEntry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/App/FeedEntryParent.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumQuery.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9a.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumFeed.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GmlPos.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb4.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/Extension/Ccr.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x01.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x81.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6a.php
chmod -x newscoop/vendor/friendsofsymfony/rest-bundle/FOS/RestBundle/Controller/Annotations/Options.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc5.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x66.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer/Disk.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x04.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb5.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Nickname.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Checksum.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Control.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Time.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/QuotaCurrent.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x78.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Value/Messaging/ArrayCollection.php
chmod -x newscoop/template_engine/classes/CampContext.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Entry.php
chmod -x newscoop/template_engine/metaclasses/MetaActionPreview_Comment.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Position.php
chmod -x newscoop/classes/Translation.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcf.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Writer/Json.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x50.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/LICENSE
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCategory.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x20.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/CommentingEnabled.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x86.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaContent.php
chmod -x newscoop/admin-files/articles/context_box/popup.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xff.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5b.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa4.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer/ShMem.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Adapter/ZendQueue.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xce.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x94.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x1f.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x12.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaContent.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x73.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4f.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xca.php
chmod -x newscoop/vendor/behat/behat/bin/behat.bat
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xad.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x2e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Token.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6d.php
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Config/Tests/Definition/Builder/NumericNodeDefinitionTest.php
chmod -x newscoop/library/Newscoop/Entity/Repository/PlaylistRepository.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0b.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x75.php
chmod -x newscoop/application.php
chmod -x newscoop/index.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd2.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x25.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb0.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x72.php
chmod -x newscoop/library/Newscoop/Entity/Issue.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer.php
chmod -x newscoop/template_engine/metaclasses/MetaActionSubmit_Comment.php
chmod -x newscoop/application/modules/admin/views/scripts/playlist/popup.phtml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaText.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbb.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x10.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x16.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Twitter.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd6.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/DocumentListEntry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Twitter/Exception.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Distance.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc7.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/FStop.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Client.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/MediaEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x90.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileListEntry.php
chmod -x newscoop/admin-files/articles/add.php
chmod -x newscoop/application/layouts/scripts/admin_menu.phtml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/TagEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x28.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x03.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaThumbnail.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/CountHint.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5d.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x52.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3/Exception.php
chmod -x newscoop/library/Newscoop/Entity/Topic.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8a.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GeoRssWhere.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/CommentEntry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Rotation.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc2.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc1.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x24.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x15.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x82.php
chmod -x newscoop/js/newscoop_rest_api.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x92.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Writer/Yaml.php
chmod -x newscoop/include/smarty/campsite_plugins/function.uri.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x77.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x21.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Tags.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcb.php
chmod -x newscoop/vendor/doctrine/orm/bin/doctrine.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Version.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Auth/Abstract.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x87.php
chmod -x newscoop/classes/Article.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Entry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/Query.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x65.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x64.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x57.php
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Security/Tests/Core/Util/StringUtilsTest.php
chmod -x newscoop/library/Newscoop/Services/Ingest/PublisherService.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/AbstractFactory.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x58.php
chmod -x newscoop/application/modules/admin/controllers/LegacyController.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0f.php
chmod -x newscoop/upgrade.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbf.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4d.php
chmod -x newscoop/classes/ArticleIndex.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaRating.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x05.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x63.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x98.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x13.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaDescription.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x80.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x55.php
chmod -x newscoop/src/Newscoop/GimmeBundle/Serializer/Article/RenditionsHandler.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserFeed.php
chmod -x newscoop/application/modules/admin/controllers/PlaylistController.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x83.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Feed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x95.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc3.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/App/Feed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x32.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Id.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x76.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/DocumentService/Adapter/WindowsAzure.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileListFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/CommentCount.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa2.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserQuery.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x69.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Make.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCredit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Iso.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb8.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x1e.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7a.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x51.php
chmod -x newscoop/vendor/doctrine/orm/tests/Doctrine/Tests/ORM/Functional/Ticket/DDC2012Test.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Link.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x17.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Name.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc9.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoQuery.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GmlPoint.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb7.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaHash.php
chmod -x newscoop/library/Newscoop/Router/RouterFactory.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Weight.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x59.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Message.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Parse/Resource/MysqlResult.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfa.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd4.php
chmod -x newscoop/template_engine/metaclasses/MetaTopic.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Thumbnail.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Entry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x93.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x61.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc8.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x07.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo.php
chmod -x newscoop/library/Newscoop/Services/IngestService.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x26.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xae.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/ImageUniqueId.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Captcha/Exception.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xba.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0c.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaKeywords.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Flash.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x79.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Books.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x99.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd7.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfd.php
chmod -x newscoop/template_engine/classes/CampVersion.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaGroup.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd5.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x68.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x31.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x02.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/Auth.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x11.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Http/Client/Adapter/Stream.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Height.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Location.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x54.php
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Security/Tests/Core/Util/SecureRandomTest.php
chmod -x newscoop/vendor/bombayworks/zendframework1/bin/zf.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Access.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Width.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5a.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Parse/Resource/Stream.php
chmod -x newscoop/library/Newscoop/Tools/Console/Command/UpdateIngestCommand.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd0.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa1.php
chmod -x newscoop/application/controllers/TopicController.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/FocalLength.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcc.php
chmod -x newscoop/admin-files/camp_html.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Model.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xaf.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Timestamp.php
chmod -x newscoop/application/Bootstrap.php
chmod -x newscoop/admin-files/articles/get.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6e.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x22.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbd.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x74.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd3.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcd.php
chmod -x newscoop/admin-files/media-archive/add_file.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xac.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6b.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x27.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfc.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0a.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x62.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaPlayer.php
chmod -x newscoop/vendor/bombayworks/zendframework1/bin/zf.bat
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/Query.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6f.php
chmod -x newscoop/src/Newscoop/GimmeBundle/Resources/config/serializer/newscoop/Article.yml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Private.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/DocumentService/Adapter/WindowsAzure/Query.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x89.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/Exception.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x33.php
chmod -x newscoop/admin-files/libs/ContextList/ContextList.php
chmod -x newscoop/library/Newscoop/Entity/Repository/ArticleRepository.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7f.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb9.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x56.php
chmod -x newscoop/application/views/scripts/topic_articles.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3/Stream.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaRestriction.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaGroup.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x70.php
chmod -x newscoop/vendor/guzzle/guzzle/tests/Guzzle/Tests/TestData/FileBody.txt
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/HttpKernel/Tests/Config/FileLocatorTest.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x2f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaTitle.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Yaml.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa0.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbc.php
chmod -x newscoop/library/Newscoop/Entity/Article.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/NumPhotosRemaining.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCopyright.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8b.php
chmod -x newscoop/admin-files/libs/ArticleList/do_action.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xf9.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Feed.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Exposure.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x00.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x84.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd1.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc0.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Books/VolumeQuery.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb2.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x23.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x67.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x18.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9e.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/BytesUsed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/Transliterator.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/DublinCore.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x53.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Feed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb6.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/PhotoId.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8e.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x30.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/User.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfb.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/AlbumId.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb1.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/DbInspector.php
chmod -x newscoop/src/Newscoop/GimmeBundle/Resources/config/serializer/newscoop/Comment.yml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Http/Response/Stream.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa3.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x88.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/DocumentListFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x91.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Json.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x60.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbe.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Adapter/WindowsAzure.php
chmod -x newscoop/application/controllers/ImageController.php
chmod -x newscoop/admin-files/articles/add_move.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb3.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/Introspector.php
chmod -x newscoop/admin-files/pub/edit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Size.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/MaxPhotosPerAlbum.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/NumPhotos.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x06.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaRating.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc4.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x09.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x71.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x96.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/QuotaLimit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x85.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7b.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x14.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfe.php
chmod -x newscoop/classes/RequestObject.php
chmod -x newscoop/admin-files/pub/index.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc6.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9b.php

chmod -x newscoop/vendor/smarty/smarty-dev/documentation/fr/bookinfo.xml
chmod -x newscoop/library/Newscoop/Services/ArticleService.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOamsr
chmod -x newscoop/library/Newscoop/Entity/Language.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOcyr2
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISObox
chmod -x newscoop/template_engine/metaclasses/MetaArticle.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOpub
chmod -x newscoop/application/modules/admin/controllers/SubscriptionController.php
chmod -x newscoop/library/Newscoop/Tools/Console/Command/ClearOldStatisticsCommand.php
chmod -x newscoop/library/Newscoop/Tools/Console/Command/SubscriptionsNotifierCommand.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/es/make_chm_index.html
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/de/bookinfo.xml
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/ru/bookinfo.xml
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/es/designers/language-basic-syntax/language-syntax-variables.xml
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOgrk3
chmod -x newscoop/library/Newscoop/Tools/Console/Command/EventsNotifierCommand.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOamsa
chmod -x newscoop/vendor/dflydev/doctrine-orm-service-provider/src/Dflydev/Pimple/Provider/DoctrineOrm/DoctrineOrmServiceProvider.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/es/bookinfo.xml
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/en/make_chm_index.html
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/pt_BR/bookinfo.xml
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/en/bookinfo.xml
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOlat2
chmod -x newscoop/vendor/hybridauth/hybridauth/additional-providers/hybridauth-github/Providers/GitHub.php
chmod -x newscoop/library/Newscoop/Entity/ArticleAuthor.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOamsc
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOnum
chmod -x newscoop/library/Newscoop/Entity/AutoId.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOamsn
chmod -x newscoop/library/Newscoop/Entity/Log.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOlat1
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/pt_BR/livedocs.ent
chmod -x newscoop/library/Newscoop/Entity/Publication.php
chmod -x newscoop/cache/.htaccess
chmod -x newscoop/library/Newscoop/Tools/Console/Command/AutopublishCommand.php
chmod -x newscoop/js/tinymce/plugins/campsiteinternallink/img/newscoopinternallink.gif
chmod -x newscoop/library/Newscoop/Entity/User.php
chmod -x newscoop/library/Newscoop/Tools/Console/Command/LogMaintenanceCommand.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOgrk1
chmod -x newscoop/vendor/nelmio/api-doc-bundle/Nelmio/ApiDocBundle/Resources/views/layout.html.twig
chmod -x newscoop/vendor/doctrine/dbal/lib/Doctrine/DBAL/Types/JsonArrayType.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOamso
chmod -x newscoop/library/Newscoop/Tools/Console/Command/UpdateImageStorageCommand.php
chmod -x newscoop/library/Newscoop/Entity/Section.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOgrk2
chmod -x newscoop/library/Newscoop/Entity/AuditEvent.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOdia
chmod -x newscoop/library/Newscoop/Entity/Request.php
chmod -x newscoop/library/Newscoop/TemplateList/SlideshowsList.php
chmod -x newscoop/vendor/knplabs/knp-components/src/Knp/Component/Pager/Paginator.php
chmod -x newscoop/vendor/knplabs/knp-paginator-bundle/Knp/Bundle/PaginatorBundle/Subscriber/SlidingPaginationSubscriber.php
chmod -x newscoop/library/Newscoop/TemplateList/UsersList.php
chmod -x newscoop/constants.php
chmod -x newscoop/bin/cli_script_lib.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/pt_BR/make_chm_index.html
chmod -x newscoop/vendor/recaptcha/php5/Package/Captcha/Exception.php
chmod -x newscoop/template_engine/classes/ArticleImagesList.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOgrk4
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOcyr1
chmod -x newscoop/library/Newscoop/Tools/Console/Command/IndexerCommand.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/es/livedocs.ent
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOtech
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/scripts/revcheck.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/ISOamsb
chmod -x newscoop/vendor/imagine/imagine/tests/Imagine/Fixtures/resize/210-design-19933.jpg
chmod -x newscoop/classes/ArticleData.php
chmod -x newscoop/vendor/smarty/smarty-dev/documentation/entities/ISO/catalog
chmod -x newscoop/library/Newscoop/Entity/Session.php
chmod -x newscoop/vendor/phpunit/phpunit/src/Util/Blacklist.php
chmod -x newscoop/vendor/doctrine/instantiator/.travis.install.sh
chmod -x newscoop/library/Newscoop/Services/FilesystemService.php
chmod -x newscoop/admin-files/articles/post.php
chmod -x newscoop/conf/saas_config_sample.php
chmod -x newscoop/library/Newscoop/Entity/Event.php
chmod -x newscoop/library/Newscoop/Tools/Console/Command/SendStatsCommand.php
chmod -x newscoop/vendor/doctrine/dbal/lib/Doctrine/DBAL/Types/SimpleArrayType.php

fi

############################

cd ../
tar czf newscoop_${UPSTREAMVERSION}.orig.tar.gz  newscoop-${DEBVERSION}/newscoop/
cd ${BUILDDEST} || exit

cp -avi $DEBPATH ./ || exit
debuild -k174C1854 $@ || exit

ls -l /tmp/newscoop*deb
ls -l /tmp/newscoop*changes

lintian -i --pedantic /tmp/newscoop_${DEBRELEASE}_*.changes | tee /tmp/newscoop-${DEBRELEASE}.issues

#echo -n "UPLOAD? [enter|CTRL-C]" ; read

#dput sfo /tmp/newscoop_${DEBRELEASE}_*.changes
