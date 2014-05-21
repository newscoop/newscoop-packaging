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
echo " +++ downloading upstream release.."

if [ -f ${MIRRORPATH}/newscoop-$UPSTREAMVERSION.tar.gz ]; then
	echo "using local file ${MIRRORPATH}/newscoop-$UPSTREAMVERSION.tar.gz"
  tar xzf ${MIRRORPATH}/newscoop-$UPSTREAMVERSION.tar.gz
elif [ -f ${MIRRORPATH}/newscoop-$UPSTREAMDIST$SFOCUSTOM.tar.gz ]; then
	echo "using local file ${MIRRORPATH}/newscoop-$UPSTREAMDIST$SFOCUSTOM.tar.gz"
  tar xzf ${MIRRORPATH}/newscoop-$UPSTREAMDIST$SFOCUSTOM.tar.gz
elif [ -n "$CUSTOMURL" ]; then
	echo "download ${CUSTOMURL}"
	curl -L ${CUSTOMURL} \
		| tee ${MIRRORPATH}/newscoop-$UPSTREAMDIST.tar.gz \
		| tar xzf - || exit
else
	echo "download from sourceforge."
  #curl -L http://downloads.sourceforge.net/project/newscoop/$UPSTREAMDIST/newscoop-$UPSTREAMVERSION.tar.gz | tar xzf -
  curl -L http://downloads.sourceforge.net/project/newscoop/$UPSTREAMVERSION/newscoop-$UPSTREAMVERSION.tar.gz \
		| tee ${MIRRORPATH}/newscoop-$UPSTREAMDIST$SFOCUSTOM.tar.gz \
		| tar xzf - || exit
fi

# done in README.Debian
rm newscoop/INSTALL.txt

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
for file in ChangeLog CREDITS; do
  mv -vi newscoop/${file}.txt newscoop/${file}
done
mv newscoop/ChangeLog newscoop/changelog
cp -vi newscoop/htaccess newscoop/.htaccess

# remove sample data now in separate package
rm -r newscoop/install/sample_data/files/
rm -r newscoop/install/sample_data/images/
rm newscoop/install/sql/campsite_demo_data.sql
rm newscoop/install/sql/campsite_demo_prepare.sql
rm newscoop/install/sql/campsite_demo_tables.sql

# remove geonames.org data now in separate package
rm newscoop/install/sql/CityLocations.csv
rm newscoop/install/sql/CityNames.csv

### fixes for 4.2.3 ###
if test "${UPSTREAMVERSION}" == "4.2.3"; then

sed -i "1s:sh:bash:" newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/build_tarball.sh

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
rm newscoop/vendor/jms/cg/.gitignore
rm newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/.gitignore
rm newscoop/vendor/jms/metadata/.gitignore
rm newscoop/vendor/jms/parser-lib/.gitignore
rm newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/.gitignore
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
rm newscoop/vendor/symfony/monolog-bundle/Symfony/Bundle/MonologBundle/.gitignore
rm newscoop/vendor/symfony/swiftmailer-bundle/Symfony/Bundle/SwiftmailerBundle/.gitignore
rm newscoop/vendor/symfony/symfony/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bridge/Doctrine/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bridge/Monolog/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bridge/Propel1/.gitignore
rm newscoop/vendor/symfony/symfony/src/Symfony/Bridge/Twig/.gitignore
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

rm newscoop/vendor/symfony/symfony/src/Symfony/Component/Console/Resources/bin/hiddeninput.exe

rm newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/.DS_Store
rm newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/.DS_Store
rm newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/fonts/.DS_Store
rm newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/libs/.DS_Store
rm newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/.DS_Store
rm newscoop/themes/unassigned/set_rockstar/assets/.DS_Store
rm newscoop/themes/unassigned/set_rockstar/assets/css/.DS_Store
rm newscoop/themes/unassigned/set_rockstar/assets/fonts/.DS_Store
rm newscoop/themes/unassigned/set_rockstar/assets/js/libs/.DS_Store
rm newscoop/themes/unassigned/set_rockstar/pictures/.DS_Store

chmod +x newscoop/bin/post-install.sh
chmod +x newscoop/vendor/doctrine/dbal/bin/doctrine-dbal
chmod +x newscoop/vendor/knplabs/knp-components/bin/vendors.php
chmod +x newscoop/vendor/doctrine/orm/bin/doctrine

chmod -x newscoop/plugins/debate/template_engine/classes/DebateIssue.php
chmod -x newscoop/application/console
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/rating/star_full.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7e.php
chmod -x newscoop/admin-files/media-archive/multiedit_file.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x97.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_highlight-soft_75_ffe45c_1x100.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumEntry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/App/FeedEntryParent.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3-4.jpg
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumQuery.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/article-comments.tpl
chmod -x newscoop/admin-files/lang/uk/article_topics.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/article-icons.tpl
chmod -x newscoop/admin-files/lang/pl/home.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/extensions/recorder/test/test.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Security/Util/SeedProviderInterface.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/archive.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/rating/star_highlight.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoFeed.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/front-morenews.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_sw.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9a.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumFeed.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GmlPos.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/article-icons.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/layout.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_nav_left.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon-precomposed.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb4.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/Extension/Ccr.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_e.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x01.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/comment-avatar.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x81.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6a.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Tests/Security/Util/StringTest.php
chmod -x newscoop/vendor/friendsofsymfony/rest-bundle/FOS/RestBundle/Controller/Annotations/Options.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/libs/modernizr-2.0.6.js
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/video.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc5.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icons/locked.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x66.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer/Disk.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x04.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_w.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb5.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/vendor/html5shiv.js
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_s.png
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.org/test/package/fr/no-synchronisation.xml
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/themethumbs/front.jpg
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Nickname.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Checksum.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon-144x144-precomposed.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Control.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/section.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Time.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/theme.xml
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/auth_password-restore.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/QuotaCurrent.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x78.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/video-js.css
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Value/Messaging/ArrayCollection.php
chmod -x newscoop/template_engine/classes/CampContext.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_loading.png
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Generator/RepositoryInjectionGenerator.php
chmod -x newscoop/plugins/poll/smarty_camp_plugins/block.pollanswer_ajax.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/article.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs.php
chmod -x newscoop/plugins/recaptcha/admin-files/lang/pl/plugin_recaptcha.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/auth_password-restore-after.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/article-author-info.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Entry.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-icons_222222_256x240.png
chmod -x newscoop/admin-files/lang/pl/pub.php
chmod -x newscoop/template_engine/metaclasses/MetaActionPreview_Comment.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Position.php
chmod -x newscoop/classes/Translation.php
chmod -x newscoop/admin-files/lang/uk/tiny_media_plugin.php
chmod -x newscoop/admin-files/lang/uk/issues.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcf.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancybox-y.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Writer/Json.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/_html-head.tpl
chmod -x newscoop/admin-files/lang/uk/languages.php
chmod -x newscoop/admin-files/lang/uk/extensions.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/extensions/recorder/test/sample.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x50.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Tests/Functional/Bundle/TestBundle/Controller/AutomaticallyInjectedController.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/LICENSE
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_nw.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/libs/bootstrap-transition.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCategory.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/less/main.less
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x20.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/CommentingEnabled.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/themethumbs/article.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x86.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaContent.php
chmod -x newscoop/admin-files/articles/context_box/popup.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xff.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_title_main.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/libs/bootstrap-collapse.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5b.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/reset.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_glass_100_f6f6f6_1x400.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa4.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/register_social.tpl
chmod -x newscoop/admin-files/lang/pl/logs.php
chmod -x newscoop/admin-files/lang/pl/users.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0d.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/article-cont.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer/ShMem.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Adapter/ZendQueue.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xce.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x94.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x1f.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/libs/modernizr-1.7.min.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x12.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaContent.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/user-content.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x73.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4f.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/colors.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_flat_10_000000_40x100.png
chmod -x newscoop/admin-files/lang/uk/comments.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xca.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon.png
chmod -x newscoop/vendor/behat/behat/bin/behat.bat
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xad.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_se.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x2e.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/register_confirm.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/relative_date.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Token.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6d.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_nav_right.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/404.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_nav_right.png
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Config/Tests/Definition/Builder/NumericNodeDefinitionTest.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Tests/Security/Authorization/Expression/Fixture/Issue22/SecuredObject.php
chmod -x newscoop/library/Newscoop/Entity/Repository/PlaylistRepository.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0b.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/script.js
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/nav-arrows.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x75.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-2.jpg
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_s.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/blank.gif
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/_html-foot.tpl
chmod -x newscoop/application.php
chmod -x newscoop/index.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3-2.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd2.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/libs/jquery.jcarousel.min.js
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/themethumbs/section.jpg
chmod -x newscoop/plugins/poll/smarty_camp_plugins/function.pollanswer_edit.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_ne.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x25.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/topic.tpl
chmod -x newscoop/admin-files/lang/pl/article_type_fields.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb0.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_title_over.png
chmod -x newscoop/admin-files/lang/uk/article_images.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x72.php
chmod -x newscoop/library/Newscoop/Entity/Issue.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_diagonals-thick_20_666666_40x40.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_title_right.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_highlight-soft_100_eeeeee_1x100.png
chmod -x newscoop/admin-files/lang/uk/library.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer.php
chmod -x newscoop/template_engine/metaclasses/MetaActionSubmit_Comment.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/register_confirm.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icon_nav-button.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_highlight-soft_100_eeeeee_1x100.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/page.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-icons_ffd27a_256x240.png
chmod -x newscoop/plugins/poll/smarty_camp_plugins/block.poll_form.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6-2.jpg
chmod -x newscoop/application/modules/admin/views/scripts/playlist/popup.phtml
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_w.png
chmod -x newscoop/admin-files/lang/pl/tiny_media_plugin.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/method_security_authorization.rst
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaText.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_nav_right.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbb.php
chmod -x newscoop/admin-files/lang/pl/themes.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/footer.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x10.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x16.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_nw.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Twitter.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd6.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/search-cont.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/rating/star_highlight.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_title_right.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/DocumentListEntry.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/plugins.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Twitter/Exception.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Distance.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/auth_password-restore.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc7.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/FStop.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/arrow-bullet.png
chmod -x newscoop/admin-files/lang/uk/user_subscription_sections.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Client.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/sidebar-loginbox.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/MediaEntry.php
chmod -x newscoop/admin-files/lang/pl/system_pref.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x90.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/_html-foot.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/sidebar-community-feed.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_nav_left.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-icons_ffffff_256x240.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/issue-cont.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileListEntry.php
chmod -x newscoop/admin-files/articles/add.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancybox-x.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_ne.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/topic-cont.tpl
chmod -x newscoop/application/layouts/scripts/admin_menu.phtml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/TagEntry.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/author-img.jpg
chmod -x newscoop/admin-files/lang/pl/country.php
chmod -x newscoop/admin-files/lang/uk/country.php
chmod -x newscoop/admin-files/lang/uk/logs.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/libs/dd_belatedpng.js
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icon_search_white.png
chmod -x newscoop/plugins/poll/classes/PollIssue.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/dashboard_index.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/datepicker.css
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_title_over.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x28.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x03.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaThumbnail.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/CountHint.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-icons_ffd27a_256x240.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/map-sample.png
chmod -x newscoop/admin-files/lang/pl/user_subscriptions.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5d.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/main.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x52.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/register_after.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_title_left.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/jquery.fancybox-1.3.4.css
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-icons_ffffff_256x240.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6-3.jpg
chmod -x newscoop/admin-files/lang/pl/article_types.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/LICENSE
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3/Exception.php
chmod -x newscoop/library/Newscoop/Entity/Topic.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/rss.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/user-content.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8a.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_s.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GeoRssWhere.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/CommentEntry.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Security/Util/String.php
chmod -x newscoop/admin-files/lang/uk/topics.php
chmod -x newscoop/admin-files/lang/pl/user_types.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Rotation.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc2.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc1.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-icons_228ef1_256x240.png
chmod -x newscoop/admin-files/lang/pl/authors.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x24.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x15.php
chmod -x newscoop/plugins/debate/smarty_camp_plugins/block.list_debateanswer_attachments.php
chmod -x newscoop/admin-files/lang/pl/sections.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/logo.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x82.php
chmod -x newscoop/js/newscoop_rest_api.js
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/video.js
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6-5.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x92.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icon_open-close.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/user_index.tpl
chmod -x newscoop/admin-files/lang/pl/topics.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Writer/Yaml.php
chmod -x newscoop/admin-files/lang/uk/themes.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/auth_index.tpl
chmod -x newscoop/include/smarty/campsite_plugins/function.uri.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x77.php
chmod -x newscoop/admin-files/lang/es/home.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_diagonals-thick_18_b81900_40x40.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/archive.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/themethumbs/section.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x21.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/dashboard_index.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Tags.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcb.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/annotations.rst
chmod -x newscoop/vendor/doctrine/orm/bin/doctrine.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/front-highlights.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Version.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Auth/Abstract.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x87.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6.jpg
chmod -x newscoop/classes/Article.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3-5.jpg
chmod -x newscoop/admin-files/lang/uk/geolocation.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Entry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/Query.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x65.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x64.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x57.php
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Security/Tests/Core/Util/StringUtilsTest.php
chmod -x newscoop/admin-files/lang/uk/plugins.php
chmod -x newscoop/library/Newscoop/Services/Ingest/PublisherService.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/libs/selectivizr-min.js
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/sidebar-loginbox.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/register_pending.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3-6.jpg
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/nav-arrows-disabled.png
chmod -x newscoop/UPGRADE.md
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_title_main.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_sw.png
chmod -x newscoop/admin-files/lang/pl/issues.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/front-topstory.tpl
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/source/en/changelog.xml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/AbstractFactory.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/skin.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x58.php
chmod -x newscoop/application/modules/admin/controllers/LegacyController.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0f.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/article.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icon_nav-button.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/rating/star_full.png
chmod -x newscoop/install/classes/CampInstallation.php
chmod -x newscoop/upgrade.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/front.tpl
chmod -x newscoop/admin-files/lang/pl/support.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbf.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/simpletest.org/js/jquery.heartbeat.js
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_title_right.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4d.php
chmod -x newscoop/admin-files/localizer/index.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/README.md
chmod -x newscoop/admin-files/lang/uk/user_types.php
chmod -x newscoop/classes/ArticleIndex.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaRating.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x05.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/thumb-3.jpg
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon-57x57-precomposed.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/front-topstory.tpl
chmod -x newscoop/admin-files/lang/uk/article_comments.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/img/img_big.tpl
chmod -x newscoop/admin-files/lang/pl/library.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/configuration.rst
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancybox-x.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x63.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x98.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x13.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/map-info.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/vendor/jquery-1.9.1.min.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaDescription.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/auth_index.tpl
chmod -x newscoop/plugins/debate/smarty_camp_plugins/block.list_debate_votes.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-2-2.jpg
chmod -x newscoop/admin-files/lang/uk/article_types.php
chmod -x newscoop/admin-files/lang/uk/article_type_fields.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x80.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/init.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x55.php
chmod -x newscoop/src/Newscoop/GimmeBundle/Serializer/Article/RenditionsHandler.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/front.tpl
chmod -x newscoop/admin-files/lang/pl/article_topics.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_n.png
chmod -x newscoop/install/scripts/SQLImporting.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/nav-arrows-disabled.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_title_over.png
chmod -x newscoop/admin-files/lang/pl/globals.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3.jpg
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserFeed.php
chmod -x newscoop/application/modules/admin/controllers/PlaylistController.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/user-content.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/user-image.tpl
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/simpletest.org/images/simpletest-contribute.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x83.php
chmod -x newscoop/admin-files/lang/uk/localizer.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Feed.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancybox.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x95.php
chmod -x newscoop/plugins/debate/smarty_camp_plugins/block.list_debates.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc3.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/App/Feed.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/plugins.js
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancybox.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x32.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Id.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icons/video.png
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/HttpKernel/ControllerInjectorsWarmer.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/simpletest.org/js/jquery.sparkline.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x76.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/reset.css
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/annotations.rst
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/article-cont.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/DocumentService/Adapter/WindowsAzure.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Security/Util/SecureRandomSchema.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileListFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9f.php
chmod -x newscoop/README.md
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/CommentCount.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa2.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserQuery.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/front-morestories.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/main.css
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/random_number_generator.rst
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x69.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Make.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCredit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Iso.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb8.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x1e.php
chmod -x newscoop/admin-files/lang/uk/bug_reporting.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_glass_65_ffffff_1x400.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-icons_ef8c08_256x240.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7a.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x51.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.org/integration.php
chmod -x newscoop/vendor/doctrine/orm/tests/Doctrine/Tests/ORM/Functional/Ticket/DDC2012Test.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/img/img_250x167.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Link.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x17.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/glyphicons-halflings.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Name.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Tests/Functional/AutomaticControllerInjectionsTest.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_e.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc9.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoQuery.php
chmod -x newscoop/admin-files/lang/pl/languages.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/doctrine.rst
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/icons-top.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/bootstrap.min.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/img/img_150x150.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/issue.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GmlPoint.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/register_pending.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb7.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/_edit-article.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaHash.php
chmod -x newscoop/library/Newscoop/Router/RouterFactory.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/front-highlights.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/rating/star_empty.png
chmod -x newscoop/plugins/poll/smarty_camp_plugins/block.list_poll_answers.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icons/audio.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Weight.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_nav_left.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x59.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Message.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Parse/Resource/MysqlResult.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/themethumbs/article.jpg
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.ini
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_sw.png
chmod -x newscoop/plugins/soundcloud/smarty_camp_plugins/block.list_soundcloud_tracks.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/front-dynamicmap.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/libs/dd_belatedpng.js
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/README.md
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfa.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/img/img_onehalf.tpl
chmod -x newscoop/admin-files/lang/uk/home.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icons/audio.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd4.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/user-image.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/article-aside.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/thumb-1.jpg
chmod -x newscoop/template_engine/metaclasses/MetaTopic.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Thumbnail.php
chmod -x newscoop/admin-files/lang/pl/bug_reporting.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Entry.php
chmod -x newscoop/install/classes/CampTemplate.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x93.php
chmod -x newscoop/admin-files/lang/uk/media_archive.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x61.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc8.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/all-sections.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x07.php
chmod -x newscoop/admin-files/lang/pl/article_comments.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo.php
chmod -x newscoop/library/Newscoop/Services/IngestService.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Tests/Security/Authorization/Expression/Fixture/Issue22/Project.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6-6.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x26.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/icon-search.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileEntry.php
chmod -x newscoop/admin-files/lang/pl/localizer.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xae.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_gloss-wave_35_f6a828_500x100.png
chmod -x newscoop/admin-files/lang/pl/user_subscription_sections.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/ImageUniqueId.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icon_search_white.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Captcha/Exception.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xba.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/front-morenews.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0c.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/arrow-bullet.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icons/locked.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/auth_password-restore-after.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaKeywords.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Flash.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/rating/star_empty.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/auth_password-restore-finish.tpl
chmod -x newscoop/plugins/debate/smarty_camp_plugins/block.list_debate_days.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/logo_red.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/bullet-3.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x79.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Books.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/img/img_square.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/body-bgr-test.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/jquery-ui.custom.css
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/slider-arrows.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/paginator_control.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-icons_ef8c08_256x240.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x99.php
chmod -x newscoop/admin-files/lang/uk/articles.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/body-bgr-test.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd7.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icons/video.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-1.jpg
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_title_main.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-icons_222222_256x240.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfd.php
chmod -x newscoop/plugins/debate/admin-files/lang/pl/plugin_debate.php
chmod -x newscoop/template_engine/classes/CampVersion.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/sidebar-most.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaGroup.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/style.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd5.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x68.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/simpletest.org/views/heartbeat.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Tests/Functional/config/automatic_controller_injections.yml
chmod -x newscoop/admin-files/lang/uk/preview.php
chmod -x newscoop/admin-files/lang/pl/extensions.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/front-playlist-articles.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x31.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/front-dynamicmap.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x02.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/Auth.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/header.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x11.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/LICENSE
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_close.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/img/img_150x150.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Http/Client/Adapter/Stream.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/main.css
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/footer.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Height.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icons/photo.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Location.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x54.php
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Security/Tests/Core/Util/SecureRandomTest.php
chmod -x newscoop/vendor/bombayworks/zendframework1/bin/zf.php
chmod -x newscoop/admin-files/lang/uk/system_pref.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Access.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Width.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8c.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/nav-arrows.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/bullet-2.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5a.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Parse/Resource/Stream.php
chmod -x newscoop/admin-files/lang/uk/support.php
chmod -x newscoop/library/Newscoop/Tools/Console/Command/UpdateIngestCommand.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/installation.rst
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd0.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa1.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_w.png
chmod -x newscoop/application/controllers/TopicController.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/configuration.rst
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/FocalLength.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_gloss-wave_35_f6a828_500x100.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_ne.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/sidebar-most.tpl
chmod -x newscoop/admin-files/lang/uk/globals.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icons/photo.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/theme.xml
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcc.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/source/en/heartbeat.xml
chmod -x newscoop/admin-files/camp_html.php
chmod -x newscoop/admin-files/lang/uk/user_subscriptions.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Tests/Security/Util/SecureRandomTest.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Model.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xaf.php
chmod -x newscoop/install/classes/CampInstallationBase.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/img/img_500x333.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Timestamp.php
chmod -x newscoop/application/modules/admin/views/scripts/comment/table.phtml
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_title_left.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/article-aside.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/section-two-blocks.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/libs/jquery.min.js
chmod -x newscoop/application/Bootstrap.php
chmod -x newscoop/admin-files/articles/get.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/img/img_600x400.tpl
chmod -x newscoop/plugins/poll/smarty_camp_plugins/block.list_pollanswer_attachments.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/handheld.css
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_se.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_e.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/feed-icons.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6e.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_glass_65_ffffff_1x400.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/script.js
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icon_open-close.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x22.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/front-dynamicmap.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/community_icons.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbd.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x74.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancybox-x.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/topic.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd3.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcd.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/img/img_onethird.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_diagonals-thick_20_666666_40x40.png
chmod -x newscoop/admin-files/media-archive/add_file.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xac.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6b.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_se.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x27.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfc.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0a.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/_html-head.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/jquery-ui.custom.css
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_diagonals-thick_18_b81900_40x40.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/register_after.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x62.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/reset.css
chmod -x newscoop/plugins/soundcloud/smarty_camp_plugins/function.assign_soundcloud_tracks.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_nw.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_loading.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/colors.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_glass_100_fdf5ce_1x400.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_glass_100_f6f6f6_1x400.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/jquery.fancybox-1.3.4.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/libs/jquery.min.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaPlayer.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/search-cont.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/bin/zf.bat
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/script.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/Query.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_loading.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6f.php
chmod -x newscoop/plugins/debate/smarty_camp_plugins/block.debate_form.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/vendor/bootstrap-datepicker.js
chmod -x newscoop/src/Newscoop/GimmeBundle/Resources/config/serializer/newscoop/Article.yml
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/libs/modernizr-1.7.min.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Private.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/DocumentService/Adapter/WindowsAzure/Query.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x89.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/Exception.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/issue.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x33.php
chmod -x newscoop/admin-files/libs/ContextList/ContextList.php
chmod -x newscoop/admin-files/lang/uk/sections.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/style.css
chmod -x newscoop/install/classes/CampInstallationView.php
chmod -x newscoop/library/Newscoop/Entity/Repository/ArticleRepository.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/usage.rst
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_highlight-soft_75_ffe45c_1x100.png
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/EventListener/SecureRandomSchemaListener.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7f.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/handheld.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb9.php
chmod -x newscoop/admin-files/lang/pl/preview.php
chmod -x newscoop/js/jquery/comment.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x56.php
chmod -x newscoop/admin-files/lang/pl/articles.php
chmod -x newscoop/plugins/poll/smarty_camp_plugins/block.list_polls.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/plugins.js
chmod -x newscoop/application/views/scripts/topic_articles.tpl
chmod -x newscoop/plugins/debate/smarty_camp_plugins/function.debatevotes.php
chmod -x newscoop/admin-files/lang/uk/authors.php
chmod -x newscoop/admin-files/lang/uk/api.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/config/security_secure_random.xml
chmod -x newscoop/admin-files/lang/pl/media_archive.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.org/test/package/one_section_changelogged.xml
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/small-slider-arrows.png
chmod -x newscoop/plugins/debate/classes/DebateAnswer.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/archive-cont.tpl
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Security/Util/SecureRandom.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3/Stream.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaRestriction.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaGroup.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x70.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_flat_10_000000_40x100.png
chmod -x newscoop/vendor/guzzle/guzzle/tests/Guzzle/Tests/TestData/FileBody.txt
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/paginator_control.tpl
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/HttpKernel/Tests/Config/FileLocatorTest.php
chmod -x newscoop/admin-files/lang/uk/article_files.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x2f.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_n.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/bullet-1.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaTitle.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Yaml.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa0.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/section-cont.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbc.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/search.tpl
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Command/InitSecureRandomCommand.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/blank.gif
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3-3.jpg
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/expressions.rst
chmod -x newscoop/library/Newscoop/Entity/Article.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/search.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/layout.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/NumPhotosRemaining.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/relative_date.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/libs/bootstrap-transition.js
chmod -x newscoop/admin-files/lang/pl/templates.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCopyright.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_title_left.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8b.php
chmod -x newscoop/admin-files/libs/ArticleList/do_action.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xf9.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/CHANGELOG.md
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Feed.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Exposure.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x00.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancybox-y.png
chmod -x newscoop/admin-files/lang/pl/api.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x84.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd1.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc0.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/_edit-article.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/img/img_150x100.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/logo.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Books/VolumeQuery.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/1140.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb2.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x23.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x67.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x18.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9e.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/newscoop.quetzal.js
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/1140.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0e.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/paginator_control.tpl
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Metadata/Driver/ConfiguredControllerInjectionsDriver.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/BytesUsed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/Transliterator.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/user_index.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/DublinCore.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x53.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/top-background.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Feed.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/themethumbs/front.jpg
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/img/img_150x100.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb6.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9d.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/register_index.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/vendor/bootstrap.min.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/PhotoId.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8e.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/article-comments.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x30.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/User.php
chmod -x newscoop/admin-files/lang/pl/geolocation.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/user_profile.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/section.tpl
chmod -x newscoop/plugins/debate/admin-files/lang/pl/plugin_poll.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/relative_date.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/img/img_250x167.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfb.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_close.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/AlbumId.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb1.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/DbInspector.php
chmod -x newscoop/src/Newscoop/GimmeBundle/Resources/config/serializer/newscoop/Comment.yml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Http/Response/Stream.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa3.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/img/img_600x400.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/front-morestories.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x88.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/glyphicons-halflings-white.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/DocumentListFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x91.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Json.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/libs/jquery.min.js
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_close.png
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Tests/Metadata/Driver/ConfiguredControllerInjectionsDriverTest.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/user_profile.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/section-cont.tpl
chmod -x newscoop/admin-files/lang/uk/pub.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x60.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/libs/bootstrap-collapse.js
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Security/Util/NullSeedProvider.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/thumb-2.jpg
chmod -x newscoop/plugins/debate/smarty_camp_plugins/function.debateanswer_edit.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.org/test/package/en/synchronisation.xml
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbe.php
chmod -x newscoop/admin-files/lang/pl/universal_list.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancybox-y.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancybox.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Adapter/WindowsAzure.php
chmod -x newscoop/application/controllers/ImageController.php
chmod -x newscoop/admin-files/articles/add_move.php
chmod -x newscoop/admin-files/lang/pl/article_images.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb3.php
chmod -x newscoop/admin-files/lang/pl/article_files.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/Introspector.php
chmod -x newscoop/admin-files/pub/edit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Size.php
chmod -x newscoop/admin-files/lang/pl/feedback.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/handheld.css
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/MaxPhotosPerAlbum.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/jquery.fancybox-1.3.4.css
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/topic-cont.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/img/img_500x333.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/NumPhotos.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x06.php
chmod -x newscoop/plugins/soundcloud/admin-files/lang/pl/plugin_soundcloud.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaRating.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc4.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x09.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserEntry.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/register_index.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/front-three-blocks.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x71.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x96.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/README.md
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/QuotaLimit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileFeed.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-icons_228ef1_256x240.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon-114x114-precomposed.png
chmod -x newscoop/plugins/poll/admin-files/lang/pl/plugin_poll.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_n.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x85.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/logo_red.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7b.php
chmod -x newscoop/admin-files/lang/pl/comments.php
chmod -x newscoop/admin-files/lang/uk/users.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.org/test/package/fr/synchronisation.xml
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x14.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfe.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6-4.jpg
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_glass_100_fdf5ce_1x400.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon-72x72-precomposed.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/header.tpl
chmod -x newscoop/classes/RequestObject.php
chmod -x newscoop/admin-files/pub/index.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/map-sample-small.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/community_icons.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc6.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/_banner-sidebar.tpl
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/installation.rst
chmod -x newscoop/admin-files/lang/pl/plugins.php
chmod -x newscoop/admin-files/localizer/Localizer.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/sidebar-community-feed.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/auth_password-restore-finish.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/blank.gif
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9b.php
chmod -x newscoop/plugins/debate/template_engine/classes/DebateIssue.php
chmod -x newscoop/application/console
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/rating/star_full.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7e.php
chmod -x newscoop/admin-files/media-archive/multiedit_file.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x97.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_highlight-soft_75_ffe45c_1x100.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumEntry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/App/FeedEntryParent.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3-4.jpg
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumQuery.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/article-comments.tpl
chmod -x newscoop/admin-files/lang/uk/article_topics.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/article-icons.tpl
chmod -x newscoop/admin-files/lang/pl/home.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/extensions/recorder/test/test.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Security/Util/SeedProviderInterface.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/archive.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/rating/star_highlight.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoFeed.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/front-morenews.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_sw.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9a.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/AlbumFeed.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GmlPos.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/article-icons.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/layout.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_nav_left.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon-precomposed.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb4.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/Extension/Ccr.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_e.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x01.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/comment-avatar.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x81.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6a.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Tests/Security/Util/StringTest.php
chmod -x newscoop/vendor/friendsofsymfony/rest-bundle/FOS/RestBundle/Controller/Annotations/Options.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/libs/modernizr-2.0.6.js
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/video.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc5.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icons/locked.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x66.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer/Disk.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x04.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_w.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb5.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/vendor/html5shiv.js
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_s.png
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.org/test/package/fr/no-synchronisation.xml
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/themethumbs/front.jpg
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Nickname.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Checksum.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon-144x144-precomposed.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Control.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/section.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Time.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/theme.xml
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/auth_password-restore.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/QuotaCurrent.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x78.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/video-js.css
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Value/Messaging/ArrayCollection.php
chmod -x newscoop/template_engine/classes/CampContext.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_loading.png
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Generator/RepositoryInjectionGenerator.php
chmod -x newscoop/plugins/poll/smarty_camp_plugins/block.pollanswer_ajax.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/article.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs.php
chmod -x newscoop/plugins/recaptcha/admin-files/lang/pl/plugin_recaptcha.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/auth_password-restore-after.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/article-author-info.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Entry.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-icons_222222_256x240.png
chmod -x newscoop/admin-files/lang/pl/pub.php
chmod -x newscoop/template_engine/metaclasses/MetaActionPreview_Comment.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Position.php
chmod -x newscoop/classes/Translation.php
chmod -x newscoop/admin-files/lang/uk/tiny_media_plugin.php
chmod -x newscoop/admin-files/lang/uk/issues.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcf.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancybox-y.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Writer/Json.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/_html-head.tpl
chmod -x newscoop/admin-files/lang/uk/languages.php
chmod -x newscoop/admin-files/lang/uk/extensions.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/extensions/recorder/test/sample.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x50.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Tests/Functional/Bundle/TestBundle/Controller/AutomaticallyInjectedController.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/LICENSE
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_nw.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/libs/bootstrap-transition.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCategory.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/less/main.less
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x20.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/CommentingEnabled.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/themethumbs/article.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x86.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaContent.php
chmod -x newscoop/admin-files/articles/context_box/popup.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xff.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_title_main.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/libs/bootstrap-collapse.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5b.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/reset.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_glass_100_f6f6f6_1x400.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa4.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/register_social.tpl
chmod -x newscoop/admin-files/lang/pl/logs.php
chmod -x newscoop/admin-files/lang/pl/users.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0d.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/article-cont.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer/ShMem.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Adapter/ZendQueue.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xce.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x94.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x1f.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/libs/modernizr-1.7.min.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x12.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaContent.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/user-content.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x73.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4f.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/colors.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_flat_10_000000_40x100.png
chmod -x newscoop/admin-files/lang/uk/comments.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xca.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon.png
chmod -x newscoop/vendor/behat/behat/bin/behat.bat
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xad.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_se.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x2e.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/register_confirm.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/relative_date.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Token.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6d.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_nav_right.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/404.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_nav_right.png
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Config/Tests/Definition/Builder/NumericNodeDefinitionTest.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Tests/Security/Authorization/Expression/Fixture/Issue22/SecuredObject.php
chmod -x newscoop/library/Newscoop/Entity/Repository/PlaylistRepository.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0b.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/script.js
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/nav-arrows.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x75.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-2.jpg
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_s.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/blank.gif
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/_html-foot.tpl
chmod -x newscoop/application.php
chmod -x newscoop/index.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3-2.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd2.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/libs/jquery.jcarousel.min.js
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/themethumbs/section.jpg
chmod -x newscoop/plugins/poll/smarty_camp_plugins/function.pollanswer_edit.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_ne.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x25.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/topic.tpl
chmod -x newscoop/admin-files/lang/pl/article_type_fields.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb0.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_title_over.png
chmod -x newscoop/admin-files/lang/uk/article_images.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x72.php
chmod -x newscoop/library/Newscoop/Entity/Issue.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_diagonals-thick_20_666666_40x40.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_title_right.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_highlight-soft_100_eeeeee_1x100.png
chmod -x newscoop/admin-files/lang/uk/library.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cache/Backend/ZendServer.php
chmod -x newscoop/template_engine/metaclasses/MetaActionSubmit_Comment.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/register_confirm.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icon_nav-button.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_highlight-soft_100_eeeeee_1x100.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/page.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-icons_ffd27a_256x240.png
chmod -x newscoop/plugins/poll/smarty_camp_plugins/block.poll_form.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6-2.jpg
chmod -x newscoop/application/modules/admin/views/scripts/playlist/popup.phtml
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_w.png
chmod -x newscoop/admin-files/lang/pl/tiny_media_plugin.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/method_security_authorization.rst
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaText.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_nav_right.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbb.php
chmod -x newscoop/admin-files/lang/pl/themes.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/footer.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x10.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x16.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_nw.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Twitter.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd6.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/search-cont.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/rating/star_highlight.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_title_right.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/DocumentListEntry.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/plugins.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Twitter/Exception.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Distance.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/auth_password-restore.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc7.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/FStop.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/arrow-bullet.png
chmod -x newscoop/admin-files/lang/uk/user_subscription_sections.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Client.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/sidebar-loginbox.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/MediaEntry.php
chmod -x newscoop/admin-files/lang/pl/system_pref.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x90.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/_html-foot.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/sidebar-community-feed.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_nav_left.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-icons_ffffff_256x240.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/issue-cont.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileListEntry.php
chmod -x newscoop/admin-files/articles/add.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancybox-x.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_ne.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/topic-cont.tpl
chmod -x newscoop/application/layouts/scripts/admin_menu.phtml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/TagEntry.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/author-img.jpg
chmod -x newscoop/admin-files/lang/pl/country.php
chmod -x newscoop/admin-files/lang/uk/country.php
chmod -x newscoop/admin-files/lang/uk/logs.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/libs/dd_belatedpng.js
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icon_search_white.png
chmod -x newscoop/plugins/poll/classes/PollIssue.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/dashboard_index.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/datepicker.css
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_title_over.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x28.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x03.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaThumbnail.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/CountHint.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-icons_ffd27a_256x240.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/map-sample.png
chmod -x newscoop/admin-files/lang/pl/user_subscriptions.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5d.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/main.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x52.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/register_after.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_title_left.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/jquery.fancybox-1.3.4.css
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-icons_ffffff_256x240.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6-3.jpg
chmod -x newscoop/admin-files/lang/pl/article_types.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/LICENSE
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3/Exception.php
chmod -x newscoop/library/Newscoop/Entity/Topic.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/rss.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/user-content.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8a.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_s.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GeoRssWhere.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/CommentEntry.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Security/Util/String.php
chmod -x newscoop/admin-files/lang/uk/topics.php
chmod -x newscoop/admin-files/lang/pl/user_types.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Rotation.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc2.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc1.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-icons_228ef1_256x240.png
chmod -x newscoop/admin-files/lang/pl/authors.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x24.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x15.php
chmod -x newscoop/plugins/debate/smarty_camp_plugins/block.list_debateanswer_attachments.php
chmod -x newscoop/admin-files/lang/pl/sections.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/logo.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x82.php
chmod -x newscoop/js/newscoop_rest_api.js
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/video.js
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6-5.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x92.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icon_open-close.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/user_index.tpl
chmod -x newscoop/admin-files/lang/pl/topics.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Writer/Yaml.php
chmod -x newscoop/admin-files/lang/uk/themes.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/auth_index.tpl
chmod -x newscoop/include/smarty/campsite_plugins/function.uri.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x77.php
chmod -x newscoop/admin-files/lang/es/home.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_diagonals-thick_18_b81900_40x40.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/archive.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/themethumbs/section.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x21.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/dashboard_index.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Tags.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcb.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/annotations.rst
chmod -x newscoop/vendor/doctrine/orm/bin/doctrine.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/front-highlights.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Version.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Auth/Abstract.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x87.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6.jpg
chmod -x newscoop/classes/Article.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3-5.jpg
chmod -x newscoop/admin-files/lang/uk/geolocation.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Entry.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/Query.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x65.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x64.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x57.php
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Security/Tests/Core/Util/StringUtilsTest.php
chmod -x newscoop/admin-files/lang/uk/plugins.php
chmod -x newscoop/library/Newscoop/Services/Ingest/PublisherService.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/libs/selectivizr-min.js
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/sidebar-loginbox.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/register_pending.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3-6.jpg
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/nav-arrows-disabled.png
chmod -x newscoop/UPGRADE.md
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_title_main.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_sw.png
chmod -x newscoop/admin-files/lang/pl/issues.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/front-topstory.tpl
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/source/en/changelog.xml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/AbstractFactory.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/skin.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x58.php
chmod -x newscoop/application/modules/admin/controllers/LegacyController.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoEntry.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0f.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/article.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icon_nav-button.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/rating/star_full.png
chmod -x newscoop/install/classes/CampInstallation.php
chmod -x newscoop/upgrade.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/front.tpl
chmod -x newscoop/admin-files/lang/pl/support.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbf.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/simpletest.org/js/jquery.heartbeat.js
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_title_right.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x4d.php
chmod -x newscoop/admin-files/localizer/index.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/README.md
chmod -x newscoop/admin-files/lang/uk/user_types.php
chmod -x newscoop/classes/ArticleIndex.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaRating.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x05.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/thumb-3.jpg
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon-57x57-precomposed.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/front-topstory.tpl
chmod -x newscoop/admin-files/lang/uk/article_comments.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/img/img_big.tpl
chmod -x newscoop/admin-files/lang/pl/library.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/configuration.rst
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancybox-x.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x63.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x98.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x13.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/map-info.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/vendor/jquery-1.9.1.min.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaDescription.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/auth_index.tpl
chmod -x newscoop/plugins/debate/smarty_camp_plugins/block.list_debate_votes.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-2-2.jpg
chmod -x newscoop/admin-files/lang/uk/article_types.php
chmod -x newscoop/admin-files/lang/uk/article_type_fields.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x80.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/init.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x55.php
chmod -x newscoop/src/Newscoop/GimmeBundle/Serializer/Article/RenditionsHandler.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/front.tpl
chmod -x newscoop/admin-files/lang/pl/article_topics.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_n.png
chmod -x newscoop/install/scripts/SQLImporting.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/nav-arrows-disabled.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_title_over.png
chmod -x newscoop/admin-files/lang/pl/globals.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3.jpg
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserFeed.php
chmod -x newscoop/application/modules/admin/controllers/PlaylistController.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/user-content.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/user-image.tpl
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/simpletest.org/images/simpletest-contribute.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x83.php
chmod -x newscoop/admin-files/lang/uk/localizer.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Feed.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancybox.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x95.php
chmod -x newscoop/plugins/debate/smarty_camp_plugins/block.list_debates.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc3.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/App/Feed.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/plugins.js
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancybox.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x32.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Id.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icons/video.png
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/HttpKernel/ControllerInjectorsWarmer.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/simpletest.org/js/jquery.sparkline.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x76.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/reset.css
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/annotations.rst
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/article-cont.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/DocumentService/Adapter/WindowsAzure.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Security/Util/SecureRandomSchema.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileListFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9f.php
chmod -x newscoop/README.md
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/CommentCount.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa2.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserQuery.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/front-morestories.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/main.css
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/random_number_generator.rst
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x69.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5e.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Make.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCredit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Iso.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb8.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x1e.php
chmod -x newscoop/admin-files/lang/uk/bug_reporting.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_glass_65_ffffff_1x400.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-icons_ef8c08_256x240.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7a.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x51.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.org/integration.php
chmod -x newscoop/vendor/doctrine/orm/tests/Doctrine/Tests/ORM/Functional/Ticket/DDC2012Test.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/img/img_250x167.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Link.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x17.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/glyphicons-halflings.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Name.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Tests/Functional/AutomaticControllerInjectionsTest.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_e.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc9.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/PhotoQuery.php
chmod -x newscoop/admin-files/lang/pl/languages.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/doctrine.rst
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/icons-top.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/bootstrap.min.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/img/img_150x150.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/issue.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Extension/GmlPoint.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/register_pending.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb7.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/_edit-article.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaHash.php
chmod -x newscoop/library/Newscoop/Router/RouterFactory.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/front-highlights.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/rating/star_empty.png
chmod -x newscoop/plugins/poll/smarty_camp_plugins/block.list_poll_answers.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icons/audio.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Weight.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_nav_left.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x59.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Message.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Parse/Resource/MysqlResult.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/themethumbs/article.jpg
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.ini
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_sw.png
chmod -x newscoop/plugins/soundcloud/smarty_camp_plugins/block.list_soundcloud_tracks.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/front-dynamicmap.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/libs/dd_belatedpng.js
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/README.md
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfa.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/img/img_onehalf.tpl
chmod -x newscoop/admin-files/lang/uk/home.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icons/audio.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd4.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/user-image.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/article-aside.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/thumb-1.jpg
chmod -x newscoop/template_engine/metaclasses/MetaTopic.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Thumbnail.php
chmod -x newscoop/admin-files/lang/pl/bug_reporting.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo/Entry.php
chmod -x newscoop/install/classes/CampTemplate.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x93.php
chmod -x newscoop/admin-files/lang/uk/media_archive.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x61.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc8.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/all-sections.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x07.php
chmod -x newscoop/admin-files/lang/pl/article_comments.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Geo.php
chmod -x newscoop/library/Newscoop/Services/IngestService.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Tests/Security/Authorization/Expression/Fixture/Issue22/Project.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6-6.jpg
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x26.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/icon-search.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5f.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileEntry.php
chmod -x newscoop/admin-files/lang/pl/localizer.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xae.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_gloss-wave_35_f6a828_500x100.png
chmod -x newscoop/admin-files/lang/pl/user_subscription_sections.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/ImageUniqueId.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icon_search_white.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Captcha/Exception.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xba.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/front-morenews.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0c.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/arrow-bullet.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icons/locked.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/auth_password-restore-after.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaKeywords.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Flash.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/rating/star_empty.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/auth_password-restore-finish.tpl
chmod -x newscoop/plugins/debate/smarty_camp_plugins/block.list_debate_days.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/logo_red.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/bullet-3.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x79.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Books.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/img/img_square.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/body-bgr-test.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/jquery-ui.custom.css
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/slider-arrows.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/paginator_control.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-icons_ef8c08_256x240.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x99.php
chmod -x newscoop/admin-files/lang/uk/articles.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/body-bgr-test.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd7.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icons/video.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-1.jpg
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_title_main.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-icons_222222_256x240.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfd.php
chmod -x newscoop/plugins/debate/admin-files/lang/pl/plugin_debate.php
chmod -x newscoop/template_engine/classes/CampVersion.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/sidebar-most.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaGroup.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/style.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd5.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x68.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/simpletest.org/views/heartbeat.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Tests/Functional/config/automatic_controller_injections.yml
chmod -x newscoop/admin-files/lang/uk/preview.php
chmod -x newscoop/admin-files/lang/pl/extensions.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/front-playlist-articles.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x31.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/front-dynamicmap.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x02.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/Auth.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/header.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x11.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/LICENSE
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_close.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/img/img_150x150.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Http/Client/Adapter/Stream.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/main.css
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/footer.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Height.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icons/photo.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Location.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x54.php
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/Security/Tests/Core/Util/SecureRandomTest.php
chmod -x newscoop/vendor/bombayworks/zendframework1/bin/zf.php
chmod -x newscoop/admin-files/lang/uk/system_pref.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Access.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Width.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8c.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/nav-arrows.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/bullet-2.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x5a.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Parse/Resource/Stream.php
chmod -x newscoop/admin-files/lang/uk/support.php
chmod -x newscoop/library/Newscoop/Tools/Console/Command/UpdateIngestCommand.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/installation.rst
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd0.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa1.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_w.png
chmod -x newscoop/application/controllers/TopicController.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/configuration.rst
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/FocalLength.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_gloss-wave_35_f6a828_500x100.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_ne.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/sidebar-most.tpl
chmod -x newscoop/admin-files/lang/uk/globals.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/icons/photo.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/theme.xml
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcc.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/docs/source/en/heartbeat.xml
chmod -x newscoop/admin-files/camp_html.php
chmod -x newscoop/admin-files/lang/uk/user_subscriptions.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Tests/Security/Util/SecureRandomTest.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Model.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xaf.php
chmod -x newscoop/install/classes/CampInstallationBase.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/img/img_500x333.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Timestamp.php
chmod -x newscoop/application/modules/admin/views/scripts/comment/table.phtml
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_title_left.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/article-aside.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/section-two-blocks.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/libs/jquery.min.js
chmod -x newscoop/application/Bootstrap.php
chmod -x newscoop/admin-files/articles/get.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/img/img_600x400.tpl
chmod -x newscoop/plugins/poll/smarty_camp_plugins/block.list_pollanswer_attachments.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/handheld.css
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_se.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_e.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/feed-icons.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6e.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_glass_65_ffffff_1x400.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/script.js
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/icon_open-close.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x22.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/front-dynamicmap.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/community_icons.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbd.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x74.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancybox-x.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/topic.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd3.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xcd.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/img/img_onethird.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_diagonals-thick_20_666666_40x40.png
chmod -x newscoop/admin-files/media-archive/add_file.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xac.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6b.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_shadow_se.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x27.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfc.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0a.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/_html-head.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/jquery-ui.custom.css
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_diagonals-thick_18_b81900_40x40.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/register_after.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x62.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/reset.css
chmod -x newscoop/plugins/soundcloud/smarty_camp_plugins/function.assign_soundcloud_tracks.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_nw.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_loading.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/colors.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-bg_glass_100_fdf5ce_1x400.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_glass_100_f6f6f6_1x400.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/jquery.fancybox-1.3.4.css
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/libs/jquery.min.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaPlayer.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/search-cont.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/bin/zf.bat
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/script.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/Query.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_loading.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6f.php
chmod -x newscoop/plugins/debate/smarty_camp_plugins/block.debate_form.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/vendor/bootstrap-datepicker.js
chmod -x newscoop/src/Newscoop/GimmeBundle/Resources/config/serializer/newscoop/Article.yml
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/libs/modernizr-1.7.min.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/Private.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/DocumentService/Adapter/WindowsAzure/Query.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x89.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/Exception.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/issue.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x33.php
chmod -x newscoop/admin-files/libs/ContextList/ContextList.php
chmod -x newscoop/admin-files/lang/uk/sections.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/style.css
chmod -x newscoop/install/classes/CampInstallationView.php
chmod -x newscoop/library/Newscoop/Entity/Repository/ArticleRepository.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Resources/doc/usage.rst
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_highlight-soft_75_ffe45c_1x100.png
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/EventListener/SecureRandomSchemaListener.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7f.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/handheld.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb9.php
chmod -x newscoop/admin-files/lang/pl/preview.php
chmod -x newscoop/js/jquery/comment.js
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x56.php
chmod -x newscoop/admin-files/lang/pl/articles.php
chmod -x newscoop/plugins/poll/smarty_camp_plugins/block.list_polls.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/plugins.js
chmod -x newscoop/application/views/scripts/topic_articles.tpl
chmod -x newscoop/plugins/debate/smarty_camp_plugins/function.debatevotes.php
chmod -x newscoop/admin-files/lang/uk/authors.php
chmod -x newscoop/admin-files/lang/uk/api.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/config/security_secure_random.xml
chmod -x newscoop/admin-files/lang/pl/media_archive.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.org/test/package/one_section_changelogged.xml
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/small-slider-arrows.png
chmod -x newscoop/plugins/debate/classes/DebateAnswer.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/archive-cont.tpl
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Security/Util/SecureRandom.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Service/Amazon/S3/Stream.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaRestriction.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaGroup.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x70.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_flat_10_000000_40x100.png
chmod -x newscoop/vendor/guzzle/guzzle/tests/Guzzle/Tests/TestData/FileBody.txt
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/paginator_control.tpl
chmod -x newscoop/vendor/symfony/symfony/src/Symfony/Component/HttpKernel/Tests/Config/FileLocatorTest.php
chmod -x newscoop/admin-files/lang/uk/article_files.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x2f.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancy_shadow_n.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/bullet-1.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaTitle.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Yaml.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa0.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/section-cont.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbc.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/search.tpl
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Command/InitSecureRandomCommand.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/blank.gif
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-3-3.jpg
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/expressions.rst
chmod -x newscoop/library/Newscoop/Entity/Article.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/search.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/layout.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/NumPhotosRemaining.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/relative_date.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_js/libs/bootstrap-transition.js
chmod -x newscoop/admin-files/lang/pl/templates.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Extension/MediaCopyright.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_title_left.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8b.php
chmod -x newscoop/admin-files/libs/ArticleList/do_action.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xf9.php
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/CHANGELOG.md
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Media/Feed.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Extension/Exposure.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x00.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/fancybox/fancybox-y.png
chmod -x newscoop/admin-files/lang/pl/api.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x84.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xd1.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc0.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/_edit-article.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/img/img_150x100.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/logo.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7d.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Books/VolumeQuery.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/1140.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb2.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x23.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x67.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x18.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9e.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/newscoop.quetzal.js
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/1140.css
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x0e.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/paginator_control.tpl
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Metadata/Driver/ConfiguredControllerInjectionsDriver.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/BytesUsed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x6c.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/Transliterator.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/user_index.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/DublinCore.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x53.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/img/top-background.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Exif/Feed.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/themethumbs/front.jpg
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/img/img_150x100.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb6.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9d.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/register_index.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/vendor/bootstrap.min.js
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/PhotoId.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x8e.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/article-comments.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x30.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/User.php
chmod -x newscoop/admin-files/lang/pl/geolocation.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/user_profile.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/section.tpl
chmod -x newscoop/plugins/debate/admin-files/lang/pl/plugin_poll.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/relative_date.tpl
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/img/img_250x167.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfb.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_close.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/AlbumId.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb1.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/DbInspector.php
chmod -x newscoop/src/Newscoop/GimmeBundle/Resources/config/serializer/newscoop/Comment.yml
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Http/Response/Stream.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xa3.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/img/img_600x400.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/front-morestories.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x88.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/glyphicons-halflings-white.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Docs/DocumentListFeed.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x91.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Config/Json.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/js/libs/jquery.min.js
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/fancy_close.png
chmod -x newscoop/vendor/jms/di-extra-bundle/JMS/DiExtraBundle/Tests/Metadata/Driver/ConfiguredControllerInjectionsDriverTest.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/user_profile.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/section-cont.tpl
chmod -x newscoop/admin-files/lang/uk/pub.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x60.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_js/libs/bootstrap-collapse.js
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Security/Util/NullSeedProvider.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/thumb-2.jpg
chmod -x newscoop/plugins/debate/smarty_camp_plugins/function.debateanswer_edit.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.org/test/package/en/synchronisation.xml
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xbe.php
chmod -x newscoop/admin-files/lang/pl/universal_list.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancybox-y.png
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancybox.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Cloud/QueueService/Adapter/WindowsAzure.php
chmod -x newscoop/application/controllers/ImageController.php
chmod -x newscoop/admin-files/articles/add_move.php
chmod -x newscoop/admin-files/lang/pl/article_images.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xb3.php
chmod -x newscoop/admin-files/lang/pl/article_files.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Amf/Adobe/Introspector.php
chmod -x newscoop/admin-files/pub/edit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/Size.php
chmod -x newscoop/admin-files/lang/pl/feedback.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/handheld.css
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/MaxPhotosPerAlbum.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/fancybox/jquery.fancybox-1.3.4.css
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/topic-cont.tpl
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/img/img_500x333.tpl
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/NumPhotos.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x06.php
chmod -x newscoop/plugins/soundcloud/admin-files/lang/pl/plugin_soundcloud.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/YouTube/Extension/MediaRating.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc4.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x09.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/UserEntry.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/register_index.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/_tpl/front-three-blocks.tpl
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x71.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x96.php
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/README.md
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Photos/Extension/QuotaLimit.php
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health/ProfileFeed.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_css/ui-lightness/images/ui-icons_228ef1_256x240.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon-114x114-precomposed.png
chmod -x newscoop/plugins/poll/admin-files/lang/pl/plugin_poll.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/fancy_shadow_n.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x85.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/logo_red.png
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x7b.php
chmod -x newscoop/admin-files/lang/pl/comments.php
chmod -x newscoop/admin-files/lang/uk/users.php
chmod -x newscoop/vendor/swiftmailer/swiftmailer/test-suite/lib/simpletest/packages/simpletest.org/test/package/fr/synchronisation.xml
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x14.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xfe.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/article-img-grid-6-4.jpg
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_css/ui-lightness/images/ui-bg_glass_100_fdf5ce_1x400.png
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_img/apple-touch-icon-72x72-precomposed.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/header.tpl
chmod -x newscoop/classes/RequestObject.php
chmod -x newscoop/admin-files/pub/index.php
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/pictures/map-sample-small.png
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_img/community_icons.png
chmod -x newscoop/vendor/bombayworks/zendframework1/library/Zend/Gdata/Health.php
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/xc6.php
chmod -x newscoop/install/sample_templates/the_new_custodian/templates/set_the_new_custodian/_tpl/_banner-sidebar.tpl
chmod -x newscoop/vendor/jms/security-extra-bundle/JMS/SecurityExtraBundle/Resources/doc/installation.rst
chmod -x newscoop/admin-files/lang/pl/plugins.php
chmod -x newscoop/admin-files/localizer/Localizer.php
chmod -x newscoop/install/sample_templates/quetzal/templates/set_quetzal/_tpl/sidebar-community-feed.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/auth_password-restore-finish.tpl
chmod -x newscoop/install/sample_templates/rockstar/templates/set_rockstar/assets/css/fancybox/blank.gif
chmod -x newscoop/vendor/behat/behat/src/Behat/Behat/Util/data/x9b.php
chmod -x newscoop/install/sql/upgrade/3.5.x/tables.sql
chmod -x newscoop/install/sql/upgrade/4.2.x/2014.04.24/data-required.sql

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
