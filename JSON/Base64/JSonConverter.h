//
//  JSonConverter.h
//  SIPPhone
//
//  Created by admin on 19.07.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//


#ifndef SIPPhone_JSonConverter_h
#define SIPPhone_JSonConverter_h


#include "json.h"
#include <iostream>
#include <string>
#include "Base64.h"

namespace JSonConverter{
    using namespace std;
    void serialize(
                   NSArray* recievers,
                   string& data_str,
                   int curentTime,
                   int type,
                   string& json_str
                   );
    
    void deserialize(
                     NSArray * a,
                     string& json_str,
                     vector<string>& recievers,
                     string& data_srt,
                     int& type
                     );
    
    
}
#endif
