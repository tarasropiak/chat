/* libsofia-sip-ua/su/sofia-sip/su_configure.h.  Generated from su_configure.h.in by configure.  */
/*
 * This file is part of the Sofia-SIP package
 *
 * Copyright (C) 2005,2006,2007 Nokia Corporation.
 *
 * Contact: Pekka Pessi <pekka.pessi@nokia.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 *
 */

#ifndef SU_CONFIGURE_H
/** Defined when <sofia-sip/su_configure.h> has been included. */
#define SU_CONFIGURE_H

/**@file sofia-sip/su_configure.h
 *
 * Autoconf configuration for SU library.
 *
 * The file <su_configure.h> is automatically generated by autoconf.
 *
 * The file <su_configure.h> contains configuration information for
 * programs using @b su library.  The configuration for su library itself is
 * in "config.h".
 *
 * @author Pekka Pessi <Pekka.Pessi@nokia.com>
 *
 * @date Created: Mon Aug 21 20:32:25 2000 ppessi
 */

/** Define as 1 if you have <stdint.h> */
#define SU_HAVE_STDINT 1
/** Define as 1 if you have <inttypes.h> */
#define SU_HAVE_INTTYPES 1
/** Define as 1 if you have <sys/types.h> */
#define SU_HAVE_SYS_TYPES 1

/** Define as 1 if you have BSD socket interface */
#define SU_HAVE_BSDSOCK 1
/** Define as 1 if you have pthreads library */
#define SU_HAVE_PTHREADS 1
/** Define as 1 if you have poll() */
#define SU_HAVE_POLL 1
/** Define as 1 if you have IPv6 structures, macros and constants */
#define SU_HAVE_IN6 1

/** Define as 1 if you have sa_len field in struct sockaddr */
#define SU_HAVE_SOCKADDR_SA_LEN 1

/** Define as 1 if you have struct sockaddr_storage */
#define SU_HAVE_SOCKADDR_STORAGE 1

/** Define as 1 if you have struct addrinfo. */
#define SU_HAVE_ADDRINFO 1

/** Define as 1 if you have Winsock interface */
/* #undef SU_HAVE_WINSOCK */

/** Define as 1 if you have Winsock2 interface */
/* #undef SU_HAVE_WINSOCK2 */

/** Define as 1 if you have OSX CoreFoundation interface */
/* #undef SU_HAVE_OSX_CF_API */

/** Define as 1 if you want to enable experimental features.
 *
 * Use --enable-experimental with ./configure
 */
/* #undef SU_HAVE_EXPERIMENTAL */

/** Define as 1 if you have inline functions */
#define SU_HAVE_INLINE 1
/** Define as suitable declarator inline functions */
#define SU_INLINE inline
/** Define as suitable declarator static inline functions */
#define su_inline static inline

/** Define as 1 the tag value casts use inlined functions */
#define SU_INLINE_TAG_CAST 1

/** Define this as 1 if we can use tags directly from stack. */
#define SU_HAVE_TAGSTACK 1

/* These are valid only for GCC */

#define SU_S64_C(i) (SU_S64_T)(i ## LL)
#define SU_U64_C(i) (SU_U64_T)(i ## ULL)
#define SU_S32_C(i) (SU_S32_T)(i ## L)
#define SU_U32_C(i) (SU_U32_T)(i ## UL)
#define SU_S16_C(i) (SU_S16_T)(i)
#define SU_U16_C(i) (SU_U16_T)(i ## U)
#define SU_S8_C(i)  (SU_S8_T)(i)
#define SU_U8_C(i)  (SU_U8_T)(i ## U)

/** Define this as ssize_t. */
/* #undef SOFIA_SSIZE_T */

/** Define this as size_t
    (int when compatible with sofia-sip-ua 1.12.0 binaries). */
#define SOFIA_ISIZE_T int

/** Maximum value of isize_t */
#define ISIZE_MAX INT_MAX

/** Define this as ssize_t
    (int when compatible with sofia-sip-ua 1.12.0 binaries). */
#define SOFIA_ISSIZE_T int

/** Maximum value of issize_t */
#define ISSIZE_MAX INT_MAX

/** Define this as size_t
    (unsigned int when compatible with sofia-sip-ua 1.12.0 binaries). */
#define SOFIA_USIZE_T unsigned

/** Maximum value of usize_t */
#define USIZE_MAX UINT_MAX

/**On Solaris define this in order to get POSIX extensions. */
/* #undef __EXTENSIONS__ */

/** Define this in order to get GNU extensions. */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif

#endif /* SU_CONFIGURE_H */
