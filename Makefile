# $OpenBSD$

COMMENT =		server automation framework and application

DISTNAME =		puppetserver-5.1.3
CATEGORIES =		sysutils

HOMEPAGE =		https://github.com/puppetlabs/puppetserver

MAINTAINER =		Jasper Lievisse Adriaanse <jasper@openbsd.org>

# Apache
PERMIT_PACKAGE_CDROM =	Yes

MASTER_SITES =		https://downloads.puppetlabs.com/puppet/

MODULES =		java \
			lang/ruby
MODJAVA_VER =		1.8+

BUILD_DEPENDS +=	archivers/unzip \
			archivers/zip
RUN_DEPENDS =		java/javaPathHelper \
			shells/bash \
			databases/puppetdb5

NO_TEST =		Yes

SHAREDIR =		${PREFIX}/share/puppetserver/
EXDIR =			${PREFIX}/share/examples/puppetserver/

BOOTSRAP_CONFIG =	${SYSCONFDIR}/puppetlabs/puppetserver/bootstrap.cfg

SUBST_VARS +=		BOOTSTRAP_CONFIG

do-configure:
	${SUBST_CMD} ${WRKSRC}/ext/config/conf.d/puppetserver.conf \
		${WRKSRC}/ext/bin/puppetserver \
		${WRKSRC}/ext/cli/foreground \
		${WRKSRC}/ext/cli/start \
		${WRKSRC}/ext/cli/reload \
		${WRKSRC}/ext/ezbake-functions.sh
#	${SUBST_CMD} -c ${FILESDIR}/os-settings.conf ${WRKDIR}/os-settings.conf

do-build:
	mkdir -p ${WRKSRC}/jruby17 ${WRKSRC}/jruby9k ${WRKSRC}/tmp
	cd ${WRKSRC}/tmp && tar -xvzf ${DISTDIR}/jffi-1.2.16.tar.gz
	cd ${WRKSRC}/jruby9k && unzip ../jruby-9k.jar
	cd ${WRKSRC}/jruby17 && unzip ../jruby-1_7.jar && \
		mkdir jni/x86_64-OpenBSD && \
		cp ../jruby9k/jni/x86_64-OpenBSD/libjffi-1.2.so jni/x86_64-OpenBSD
	cd ${WRKSRC}/jruby17 &&  zip -r ./* ../jruby-1_7.jar

do-install:
	${INSTALL_DATA_DIR} ${SHAREDIR}/cli/apps/
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/puppetserver/conf.d/
	${INSTALL_DATA} ${WRKSRC}/puppet-server-release.jar ${SHAREDIR}
	${INSTALL_DATA} ${WRKSRC}/ext/config/conf.d/*.conf ${EXDIR}/conf.d/
#	${INSTALL_DATA} ${WRKDIR}/os-settings.conf  ${EXDIR}/conf.d/
	${INSTALL_DATA} ${WRKSRC}/ext/system-config/services.d/bootstrap.cfg ${EXDIR}
	${INSTALL_DATA} ${WRKSRC}/ext/config/logback.xml ${EXDIR}
	${INSTALL_DATA} ${WRKSRC}/ext/ezbake-functions.sh ${SHAREDIR}
#	${INSTALL_DATA} ${WRKSRC}/ext/cli/puppetserver-env ${SHAREDIR}/cli/
	${INSTALL_SCRIPT} ${WRKSRC}/ext/bin/puppetserver ${PREFIX}/bin/
	${INSTALL_SCRIPT} ${WRKSRC}/ext/cli/* ${SHAREDIR}/cli/apps/

post-install:
	find ${PREFIX} -type f \( -name '*.beforesubst' -or -name '*.orig' \) -exec rm {} \;

.include <bsd.port.mk>
