# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils autotools db-use

SRC_URI="http://flotsam.ahall.org/files/distfiles/${P}.tar.gz"
DESCRIPTION="Debian repository creator and maintainer application"
HOMEPAGE="http://packages.debian.org/reprepro"
DEPEND="app-arch/bzip2
	app-arch/gzip
	app-arch/libarchive
	app-crypt/gpgme
	dev-libs/libgpg-error
	>=sys-libs/db-4.3"
RDEPEND=$DEPEND
RESTRICT="mirror"

KEYWORDS="~amd64 ~x86"
IUSE="bzip2"
LICENSE="GPL-2"
SLOT="0"

src_prepare() {
	eautoreconf
}

src_configure() {
	local myconf="--with-libarchive=yes --without-libgpgme"
	use bzip2 && myconf="${myconf} --with-libbz2=yes" || myconf="${myconf} --with-libbz2=no"
	econf ${myconf} || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install
}
