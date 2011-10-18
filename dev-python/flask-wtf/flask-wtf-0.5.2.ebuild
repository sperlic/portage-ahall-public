# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/flask-script/flask-script-0.3.1.ebuild,v 1.2 2010/12/14 23:25:13 rafaelmartins Exp $

EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="Flask-WTF"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Simple integration of Flask and WTForms"
HOMEPAGE="http://packages.python.org/Flask-WTF/"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

RDEPEND="dev-python/flask
	dev-python/wtforms
	dev-python/argparse"
DEPEND="${RDEPEND}
	dev-python/setuptools
	doc? ( dev-python/sphinx )
	test? ( dev-python/nose )"

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="flaskext/wtf"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		PYTHONPATH="${S}" emake -C docs html \
			|| die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/* || die "Installation of documentation failed"
	fi
}