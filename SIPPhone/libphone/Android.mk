LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_CPP_EXTENSION := .cpp
LOCAL_MODULE := phone
LOCAL_CPP_FEATURES := rtti exceptions
LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/include \
    $(LOCAL_PATH)/../logger/include \
    $(BOOST_LIBS_PATH) \
    $(SOFIA_SIP_PATH)/include
LOCAL_CFLAGS := -Wno-psabi
LOCAL_SRC_FILES := \
    ./src/Session.cpp \
    ./src/SIPClient.cpp \
    ./src/SIPLogging.cpp \
    ./src/SIPTaskBase.cpp

include $(BUILD_STATIC_LIBRARY)