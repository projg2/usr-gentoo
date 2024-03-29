# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/debianutils/debianutils-4.3.2.ebuild,v 1.7 2012/08/26 17:30:20 armin76 Exp $

EAPI=4

inherit eutils flag-o-matic usr-gentoo

DESCRIPTION="A selection of tools from Debian"
HOMEPAGE="http://packages.qa.debian.org/d/debianutils.html"
SRC_URI="mirror://debian/pool/main/d/${PN}/${PN}_${PV}.tar.gz"

LICENSE="BSD GPL-2 SMAIL"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="kernel_linux static"

PDEPEND="|| ( >=sys-apps/coreutils-6.10-r1 sys-freebsd/freebsd-ubin )"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-3.4.2-no-bs-namespace.patch
}

src_configure() {
	use static && append-ldflags -static
	default
}

src_install() {
	dobin tempfile run-parts
	usr_wrap_bin tempfile run-parts
	if use kernel_linux ; then
		dosbin installkernel
		usr_wrap_sbin installkernel
	fi

	dosbin savelog

	doman tempfile.1 run-parts.8 savelog.8
	use kernel_linux && doman installkernel.8
	cd debian
	dodoc changelog control
	keepdir /etc/kernel/postinst.d
}
