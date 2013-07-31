LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_CPP_EXTENSION := .cpp
LOCAL_MODULE := logging
LOCAL_CPP_FEATURES := rtti exceptions
LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/include \
    $(BOOST_LIBS_PATH)
LOCAL_SRC_FILES := \
    ./src/Logger.cpp \
    ./src/LoggerImplAndroid.cpp

include $(BUILD_STATIC_LIBRARY)