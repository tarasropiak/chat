#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Environment
MKDIR=mkdir
CP=cp
GREP=grep
NM=nm
CCADMIN=CCadmin
RANLIB=ranlib
CC=gcc
CCC=g++
CXX=g++
FC=gfortran
AS=as

# Macros
CND_PLATFORM=GNU-Linux-x86
CND_CONF=Release
CND_DISTDIR=dist
CND_BUILDDIR=build

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=${CND_BUILDDIR}/${CND_CONF}/${CND_PLATFORM}

# Object Files
OBJECTFILES= \
	${OBJECTDIR}/_ext/1360937237/Session.o \
	${OBJECTDIR}/_ext/1360937237/SIPClient.o \
	${OBJECTDIR}/_ext/1360937237/SIPLogging.o \
	${OBJECTDIR}/_ext/1360937237/SIPTaskBase.o


# C Compiler Flags
CFLAGS=

# CC Compiler Flags
CCFLAGS=`pkg-config sofia-sip-ua --cflags` 
CXXFLAGS=`pkg-config sofia-sip-ua --cflags` 

# Fortran Compiler Flags
FFLAGS=

# Assembler Flags
ASFLAGS=

# Link Libraries and Options
LDLIBSOPTIONS=

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-${CND_CONF}.mk ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/libphone.a

${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/libphone.a: ${OBJECTFILES}
	${MKDIR} -p ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}
	${RM} ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/libphone.a
	${AR} -rv ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/libphone.a ${OBJECTFILES} 
	$(RANLIB) ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/libphone.a

${OBJECTDIR}/_ext/1360937237/Session.o: ../src/Session.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1360937237
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../logger/include -I../include -I/usr/include/sofia-sip-1.12 -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1360937237/Session.o ../src/Session.cpp

${OBJECTDIR}/_ext/1360937237/SIPClient.o: ../src/SIPClient.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1360937237
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../logger/include -I../include -I/usr/include/sofia-sip-1.12 -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1360937237/SIPClient.o ../src/SIPClient.cpp

${OBJECTDIR}/_ext/1360937237/SIPLogging.o: ../src/SIPLogging.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1360937237
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../logger/include -I../include -I/usr/include/sofia-sip-1.12 -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1360937237/SIPLogging.o ../src/SIPLogging.cpp

${OBJECTDIR}/_ext/1360937237/SIPTaskBase.o: ../src/SIPTaskBase.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1360937237
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../logger/include -I../include -I/usr/include/sofia-sip-1.12 -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1360937237/SIPTaskBase.o ../src/SIPTaskBase.cpp

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r ${CND_BUILDDIR}/${CND_CONF}
	${RM} ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/libphone.a

# Subprojects
.clean-subprojects:

# Enable dependency checking
.dep.inc: .depcheck-impl

include .dep.inc
