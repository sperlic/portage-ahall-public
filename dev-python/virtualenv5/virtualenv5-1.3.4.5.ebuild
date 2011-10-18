EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="virtualenv5"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Virtual Python 3 Environment builder"
HOMEPAGE="http://packages.python.org/virtualenv5/"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

RDEPEND="dev-python/virtualenv"
DEPEND="${RDEPEND}
    dev-python/setuptools
    doc? ( dev-python/sphinx )
    test? ( dev-python/nose )"

S="${WORKDIR}/${MY_P}"

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

