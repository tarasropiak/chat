//
//  File.cpp
//  SIPPhone
//
//  Created by admin on 09.06.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//



#import "MessageHandler.h"
#import "SimpleSIPMessage.h"
#import "SystemSIPMessage.h"

MessageHandler::MessageHandler(SIPWrapper *owner)
{
    _owner = owner;
}

void MessageHandler:: messageReceived (
                                       const string &from_uri,
                                       const string &from_name,
                                       const string &message                          )
{
    string messageBuffer=message;
    string uriBuffer = from_uri;
    NSString *incomingSIP=@(uriBuffer.c_str());
    
    id unrecognizedMessage = [_owner fromJSON:messageBuffer
                                   andRealURL:@(from_uri.c_str())];
    
    if([unrecognizedMessage isMemberOfClass:[ SimpleSIPMessage class]])
    {
        
        // temporal fix: convert from SimpleSip to MesageWrapper messgae(((
        SimpleSIPMessage * ssipm = unrecognizedMessage;
        //ssipm =
        
        MessageWrapper * mw = [[MessageWrapper alloc] init];
        mw.urlField = @(from_uri.c_str());
        mw.messageField =ssipm.text;
        [_owner messageReceived:mw];
        //  [mw release];
        
    }else
        if([unrecognizedMessage isMemberOfClass:[SystemSIPMessage class]])
        {
        
            SystemSIPMessage * incomingSystemMessage = unrecognizedMessage;
            NSArray * recievers = [[NSArray alloc ]initWithObjects:incomingSIP, nil ];
            
            switch (incomingSystemMessage.subType)
            {
                
                    #pragma mark - network statuses
                case GET_NET_STATUS_VERBOSE:
                {
                    
                    SimpleSIPMessage * NSAV = [[SimpleSIPMessage alloc]
                                               initWithRecievers:recievers
                                               andText:_owner.networkStatus];
                    [_owner sendMessage:NSAV];
                    break;
                }
                case GET_NET_STATUS:
                {
                    SystemSIPMessage * NSA = [[SystemSIPMessage alloc]initAsStatusRequestTo:
                                              incomingSIP andType:SEND_NET_STATUS];
                    NSA.body =_owner.networkStatus;
                    NSA.destination = incomingSIP;
                    [_owner sendMessage:NSA];
                    
                    break;
                }
                case SEND_NET_STATUS:
                {
                    incomingSystemMessage.destination = incomingSIP;
                    [_owner statusReplayRecieved:incomingSystemMessage];
                    
                    break;
                }
              
                    
              #pragma mark - soul statuses
                    
                case GET_SOUL_STATUS_VERBOSE:
                {
                    SimpleSIPMessage *SSAV = [[SimpleSIPMessage alloc] initWithRecievers:
                                              recievers
                                                                                 andText:_owner.soulStatus];
                    [_owner sendMessage:SSAV];
                    
                    break;
                    
                }
                case GET_SOUL_STATUS:
                {
                    SystemSIPMessage * NSA = [[SystemSIPMessage alloc]initAsStatusRequestTo:
                                              incomingSIP andType:SEND_SOUL_STATUS];
                    [_owner sendMessage:NSA];
                    
                    break;
                }
                case SEND_SOUL_STATUS:
                {
                    incomingSystemMessage.destination=incomingSIP;
                    [_owner statusReplayRecieved:incomingSystemMessage];
                    
                    break;
                }
                    
                  #pragma mark - ping
                    
                case GET_PING_VERBOSE:
                {                    
                    NSDate *curentTime = [[NSDate alloc] init];
                    
                    double ping =  ([curentTime timeIntervalSince1970]-incomingSystemMessage.SSN)*1000;
                    
                    SimpleSIPMessage * NSAV = [[SimpleSIPMessage alloc]initWithRecievers:
                                               recievers andText:[[NSString stringWithFormat:@"%f",ping] stringByAppendingString:@"  ms"]];
                    NSAV.SSN =[curentTime timeIntervalSince1970];
                    [_owner sendMessage:NSAV];
                    
                    break;
                }
                case GET_PING:
                {
                    
                    NSDate *curentTime = [[NSDate alloc] init];
                    double ping =  ([curentTime timeIntervalSince1970]-incomingSystemMessage.SSN)*1000;
                    
                    
                    
                    SystemSIPMessage * NSA = [[SystemSIPMessage alloc]initAsStatusRequestTo:
                                              incomingSIP andType:SEND_NET_STATUS];
                    NSA.body = [NSString stringWithFormat:@"%f",ping];
                    [_owner sendMessage:NSA];
                    
                    break;
                }
                case SEND_PING:
                {
                    [_owner statusReplayRecieved:incomingSystemMessage];
                    
                    break;
                }
                    
                    
                default:
                    break;
            }
       
        }
};