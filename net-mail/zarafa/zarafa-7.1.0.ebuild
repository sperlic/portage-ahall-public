# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

PHP_EXT_NAME="mapi"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"
USE_PHP="php5-3"

inherit versionator php-ext-source-r2 eutils

ZARAFA_MAJOR=$(get_version_component_range 1 ${PV})
ZARAFA_MINOR=$(get_version_component_range 2 ${PV})
ZARAFA_MICRO=$(get_version_component_range 3 ${PV})
ZARAFA_REV=36420

DESCRIPTION="Open Source Groupware Solution"
HOMEPAGE="http://zarafa.com/"
SRC_URI="http://download.zarafa.com/community/final/${ZARAFA_MAJOR}.${ZARAFA_MINOR}/${PV}-${ZARAFA_REV}/sourcecode/zcp-${PV}.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug ldap +logrotate static"

RDEPEND=">=dev-libs/libical-0.44
    =dev-cpp/libvmime-0.9.2_pre20120110
    >=dev-lang/php-5.3.0
    app-text/catdoc
    app-text/poppler
    dev-cpp/clucene
    virtual/mysql
    dev-libs/libxml2
    dev-libs/openssl
    net-misc/curl
    sys-libs/e2fsprogs-libs
    sys-libs/zlib
    dev-libs/boost
    ldap? ( net-nds/openldap )
    logrotate? ( app-admin/logrotate )"
DEPEND="${RDEPEND}
    sys-devel/gettext
    virtual/pkgconfig"

#src_unpack() {
#   unpack ${P}.tar.bz2
#}

src_prepare() {
#
    # Don't install php ini file, as installation doesn't
    # respect Gentoo way of handling SAPIs
    #   epatch "${FILESDIR}"/"${PN}"-6.40.1-no-php-conf.patch
    #   epatch "${FILESDIR}"/"${PN}"-7.0.6-gcc46_compile.patch
    touch test
}

src_configure() {
    econf \
        --enable-oss \
        --enable-release \
        --disable-perl \
        --disable-testtools \
        --enable-epoll --enable-unicode --enable-icu \
        --with-userscript-prefix=/etc/zarafa/userscripts \
        --with-quotatemplate-prefix=/etc/zarafa/quotamails \
        --with-indexerscripts-prefix=/etc/zarafa/indexerscripts \
        $(use_enable static) \
        $(use_enable debug)
}

src_compile() {
    emake || die "Compilation failed"
}

src_install() {

    emake DESTDIR="${D}" install || die "Installation failed"

    # Use only some parts of PHP eclass
    php-ext-source-r2_buildinilist php${slot}
    php-ext-source-r2_addextension "${PHP_EXT_NAME}.so"

    # Symlink the <ext>.ini files from ext/ to ext-active/
    for inifile in ${PHPINIFILELIST} ; do
        inidir="${inifile/${PHP_EXT_NAME}.ini/}"
        inidir="${inidir/ext/ext-active}"
        dodir "/${inidir}"
        dosym "/${inifile}" "/${inifile/ext/ext-active}"
    done

    # Install PHP module
    php-ext-source-r2_addtoinifiles ";mapi.cache_max_sessions" "128"
    php-ext-source-r2_addtoinifiles ";mapi.cache_lifetime" "300"

    if use logrotate; then
        insinto /etc/logrotate.d
        newins "${FILESDIR}"/zarafa.logrotate zarafa || die "Failed to install logrotate"
    fi

    insinto /etc/zarafa
    doins "${S}"/installer/linux/*.cfg || die "Failed to install config files"

    dodir /var/log/zarafa
    keepdir /var/log/zarafa

    newinitd "${FILESDIR}"/zarafa-gateway.rc6 zarafa-gateway
    newinitd "${FILESDIR}"/zarafa-ical.rc6 zarafa-ical
    newinitd "${FILESDIR}"/zarafa-indexer.rc6 zarafa-indexer
    newinitd "${FILESDIR}"/zarafa-monitor.rc6 zarafa-monitor
    newinitd "${FILESDIR}"/zarafa-server.rc6 zarafa-server
    newinitd "${FILESDIR}"/zarafa-spooler.rc6 zarafa-spooler

}

pkg_postinst() {
    ewarn "Zarafa 7 has full UTF-8 support. Currently en_US.UTF-8"
    ewarn "is hardcoded inside the sources. Please add en_US.UTF-8 UTF-8"
    ewarn "to your /etc/locale.gen and run"
    ewarn "'localedef -i en_US -f UTF-8 en_US.UTF-8' and 'locale-gen'"
    elog "If you are upgrading from zcp-6.x please use upgrade script"
    elog "located at /usr/share/doc/zarafa/zarafa7-upgrade. The script"
    elog "requires dev-python/mysql-python to be installed in order to work"
}
