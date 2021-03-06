STEPS=		base kernel ports core iso memstick nano \
		regress clean release skim checkout
.PHONY:		${STEPS}

PAGER?=		less

all:
	@cat ${.CURDIR}/README.md | ${PAGER}

# Load the custom options from a file:

.if defined(CONFIG)
.include "${CONFIG}"
.endif

# Bootstrap the build options if not set:

NAME?=		OPNsense
FLAVOUR?=	OpenSSL
SETTINGS?=	latest
_VERSION!=	date '+%Y%m%d%H%M'
VERSION?=	${_VERSION}
PORTSREFDIR?=	/usr/freebsd-ports
TOOLSDIR?=	/usr/tools
PORTSDIR?=	/usr/ports
COREDIR?=	/usr/core
SRCDIR?=	/usr/src

# A couple of meta-targets for easy use:

source: base kernel
packages: ports core
sets: source packages
images: iso memstick nano
everything: sets images

# Expand target arguments for the script append:

.for TARGET in ${.TARGETS}
_TARGET=	${TARGET:C/\-.*//}
.if ${_TARGET} != ${TARGET}
${_TARGET}_ARGS+=	${TARGET:C/^[^\-]*(\-|\$)//:S/,/ /g}
${TARGET}: ${_TARGET}
.endif
.endfor

# Expand build steps to launch into the selected
# script with the proper build options set:

.for STEP in ${STEPS}
${STEP}:
	@cd build && sh ./${.TARGET}.sh \
	    -f ${FLAVOUR} -n ${NAME} -v ${VERSION} -s ${SETTINGS} \
	    -S ${SRCDIR} -P ${PORTSDIR} -T ${TOOLSDIR} \
	    -C ${COREDIR} -R ${PORTSREFDIR} ${${STEP}_ARGS}
.endfor
