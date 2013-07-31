//
//  SIPWrapper.m
//  SIPPhone
//
//  Created by GGC on 6/7/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "json.h"
#import "SIPWrapper.h"
#include "ErrorHandler.h"
#include "JSonConverter.h"
#include "MessageStatusHandler.h"
#import "SimpleSIPMessage.h"
#import "SystemSIPMessage.h"
#import "SIPMessage.h"

@interface SIPWrapper()
@property (nonatomic) SIPClient *SIPBrain;
@property (nonatomic) boost::shared_ptr<MessageHandler> MH;
@property (nonatomic) boost::shared_ptr<ErrorHandler> EH;
@property (nonatomic) boost::shared_ptr<MessageStatusHandler> MSH;
@end

@implementation SIPWrapper

//ffff
#pragma mark - init & dealoc
// Destignation init
- (id) init {
    self = [super init];
    if(self) {
        _SIPBrain = new SIPClient();
        _MH.reset(new MessageHandler(self));
        _EH.reset(new ErrorHandler(self));
        _MSH.reset(new MessageStatusHandler(self));
        _soulStatus = @"ALL YOUR BASE ARE BELONG TO ME!";
        _networkStatus = @"ONLINE";
        self.SIPBrain->on_message_status_changed.connect(
                                                   on_message_status_changed_slot(
                                                                            &MessageStatusHandler::messageStatusChanged,
                                                                            _MSH.get( ),
                                                                            _1,
                                                                            _2,
                                                                            _3
                                                                            ).track( _MSH ));
    }
    return self;
}

-(void ) dealloc{
    delete _SIPBrain;
    [super dealloc];
    
}

#pragma mark - core functions
-(void) waitClient{
    self.SIPBrain->wait();
}

-(void) unregister{
    self.SIPBrain->unregister();
}

-(void) stopClient{
    self.SIPBrain->stop();
    
}
-(void) startSIPWithLogin:(NSString*)loginField
              andWithPass:(NSString *)passField{
    self.SIPBrain->start([loginField UTF8String],
                         [passField UTF8String]);
    
}

-(void) registerWithDomen:(NSString*)domenField{
    self.SIPBrain->registerMe([domenField UTF8String]);
}

#pragma mark - Messages

-(void) enableMessageReceiver
{
    // Set log/verbosity level
    ::su_log_set_level( NULL, 5 );
    
    self.SIPBrain->on_message_received.connect(
                                               on_message_received_slot(
                                                                        &MessageHandler::messageReceived,
                                                                        _MH.get( ),
                                                                        _1,
                                                                        _2,
                                                                        _3
                                                                        ).track( _MH )
                                               );
}
-(void) sendMessage:(id)message{
    
    
    if([message isMemberOfClass:[ SimpleSIPMessage class]])
    {
        SimpleSIPMessage * ssipm = message;
        self.SIPBrain->sendMessage([[ssipm.recievers objectAtIndex:0] UTF8String],
                                   [self toJSON:ssipm]);
        
        
    } else
        if([message isMemberOfClass:[ MessageWrapper class]])
        {
            
            
            MessageWrapper * mw = message;
            
            NSArray *recievers=[[NSArray alloc] initWithObjects:mw.urlField ,nil];
            SimpleSIPMessage * ssipm=[[SimpleSIPMessage alloc] initWithRecievers:recievers andText:mw.messageField];
            
            self.SIPBrain->sendMessage([mw.urlField UTF8String],
                                       [self toJSON:ssipm]);
            
        //  [ssipm release];
        [recievers release];
            
        }
        else
            if([message isMemberOfClass:[ SystemSIPMessage class]])
            {
                SystemSIPMessage * syssipm = message;
                

                self.SIPBrain->sendMessage([syssipm.destination UTF8String] ,
                                           [self toJSON:syssipm]);
                //[syssipm release];
            }
    
    
    
    
    
}

- (void)messageReceived:(MessageWrapper *)message{
    [self.delegate messageReceived:message];
}

- (void) statusReplayRecieved:(SystemSIPMessage*)message{
    [self.delegate statusReplayRecieved:message];
}

- (void)errorRecieved:(int)code{
    [self.errorDelegat errorRecieved:code];
}

-(void) enableErrorReceiver{
    self.SIPBrain->on_error.connect(on_error_slot(&ErrorHandler::on_error,
                                                  _EH.get(),
                                                  _1).track( _EH )
                                    );
}

#pragma mark - disable callbacks

-(void) disableErrorReceiver{
    self.SIPBrain->on_error.disconnect_all_slots();
}

- (void) disableMessageReceiver{
    self.SIPBrain->on_message_received.disconnect_all_slots();
}


#pragma mark - Json converting functions
-(std::string) toJSON :(id) message{
    
    // Define Local variables
    Json::Value root;
    //Write "targets" to message
    
    //if message is Simple then
    if([message isMemberOfClass:[ SimpleSIPMessage class]]){
        
        SimpleSIPMessage * ssipm = message;
        //write recievers
        
        for (int i =0; i< ssipm.recievers.count; i++)
            root["recievers"].append([[ssipm.recievers objectAtIndex:i ] UTF8String]);
        
        //Write  other data
        root["SSN"]         = ssipm.SSN;
        root["T"]           = ssipm.type;
        root["text"]        = [ssipm.text UTF8String];
        
    }else
        if([message isMemberOfClass:[ SystemSIPMessage class]]){
            
            SystemSIPMessage * syssipm = message;
        
            root["ST"]    = syssipm.subType;
            root["SSN"] = syssipm.SSN;
            root["T"]= syssipm.type;
            root["body"]= [syssipm.body UTF8String];
        
        }
        else
        {
            
            return  nil;
        }
    
    
    //Convert to result string;
    Json::FastWriter writer;
   // [message release];
    
    return writer.write(root);
}

-(id) fromJSON :(std::string& ) messageInJSon andRealURL:(NSString *) url
{
    
    Json::Value root;
    Json::Reader reader;
    Json::Value jarray;
    
    
    //try to parse data
    if(reader.parse(messageInJSon,root,false))
    {
		// if ok, Get class message class
        
        int messageType=root["T"].asInt();
        
        switch (messageType)
        {
            case SIMPLE_MESSAGE:
            {
                // if simple SIMPLE_MESSAGE SSIPM instance
                SimpleSIPMessage *ssipm=[[SimpleSIPMessage alloc ] init];
                // write subclass
                ssipm.type=root["T"].asInt();
                
                //read recievers
                jarray=root["recievers"];
                NSMutableArray * recievers = [[NSMutableArray alloc] init];
                
                //and write them to SSIPM instance
                for (unsigned i=0;i<jarray.size();i++){
                    [recievers addObject:@(jarray[i].asString().c_str())];
                }
                
                ssipm.recievers=recievers;
                [recievers release];
                //read SSN
                ssipm.SSN=root["SSN"].asDouble();
                
                //read text
                ssipm.text=@(root["text"].asString().c_str());
                return ssipm;
                break;
            }
            case SYSTEM_MESSAGE:
            {
                // if SYSTEM_MESSAGE create SYSSIPM instance
                SystemSIPMessage *syssipm=[[SystemSIPMessage alloc ] init];
                // write subclass
                syssipm.subType=root["ST"].asInt();
                syssipm.SSN=root["SSN"].asDouble();
                syssipm.body=@(root["body"].asString().c_str());
                syssipm.type=root["T"].asInt();
                return syssipm;
                break;
            }
            default:
                
                break;
        }
        
    }
    else
    {
        //if we can't parse message create new instatnce
        SimpleSIPMessage *ssipm=[[SimpleSIPMessage alloc ] init];
        NSArray *recievers = [[NSArray alloc] initWithObjects:
                              @"sip:test25@sip2sip.linphone.org",
                              @"sip:test26@sip2sip.linphone.org", nil];
        
        ssipm.recievers = recievers;
        [recievers release];
        ssipm.text = @"SYSTEM ERROR :JSON PARSING ERROR";
        
        NSDate * currentTime = [[NSDate alloc] init];
        ssipm.SSN=[currentTime timeIntervalSince1970];
        [currentTime release];
        
        // and send it like SSIPM
        
        return ssipm;
        
        
        
    }
    
    
    return nil;
}


@end
