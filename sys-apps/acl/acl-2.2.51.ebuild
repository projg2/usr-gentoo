# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/acl/acl-2.2.51.ebuild,v 1.10 2013/02/19 05:08:46 zmedico Exp $

EAPI="4"

inherit eutils toolchain-funcs usr-gentoo

DESCRIPTION="access control list utilities, libraries and headers"
HOMEPAGE="http://savannah.nongnu.org/projects/acl"
SRC_URI="http://download.savannah.gnu.org/releases/${PN}/${P}.src.tar.gz
	nfs? ( http://www.citi.umich.edu/projects/nfsv4/linux/acl-patches/2.2.42-2/acl-2.2.42-CITI_NFS4_ALL-2.dif )"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux"
IUSE="nfs nls static-libs"

RDEPEND=">=sys-apps/attr-2.4
	nfs? ( net-libs/libnfsidmap )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_prepare() {
	if use nfs ; then
		cp "${DISTDIR}"/acl-2.2.42-CITI_NFS4_ALL-2.dif . || die
		sed -i \
			-e '/^diff --git a.debian.changelog b.debian.changelog/,/^diff --git/d' \
			acl-2.2.42-CITI_NFS4_ALL-2.dif || die
		epatch acl-2.2.42-CITI_NFS4_ALL-2.dif
	fi
	epatch "${FILESDIR}"/${PN}-2.2.49-quote-strchr.patch
	epatch "${FILESDIR}"/${PN}-2.2.51-config-shell.patch #365397
	sed -i \
		-e '/^as_dummy=/s:=":="$PATH$PATH_SEPARATOR:' \
		configure # hack PATH with AC_PATH_PROG
	sed -i \
		-e "/^PKG_DOC_DIR/s:@pkg_name@:${PF}:" \
		-e '/HAVE_ZIPPED_MANPAGES/s:=.*:=false:' \
		include/builddefs.in \
		|| die "failed to update builddefs"
	strip-linguas po
}

src_configure() {
	unset PLATFORM #184564
	export OPTIMIZER=${CFLAGS}
	export DEBUG=-DNDEBUG

	econf \
		$(use_enable nls gettext) \
		--enable-shared $(use_enable static-libs static) \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)
}

src_install() {
	emake DIST_ROOT="${D}" install install-dev install-lib || die
	use static-libs || find "${D}" -name '*.la' -delete

	usr_wrap_all
}
