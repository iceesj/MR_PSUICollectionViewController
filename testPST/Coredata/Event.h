//
//  Event.h
//  testPST
//
//  Created by mifandev on 13-8-13.
//  Copyright (c) 2013年 曹盛杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Test;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * event_title;
@property (nonatomic, retain) NSString * event_subtitle;
@property (nonatomic, retain) NSString * event_fangfa;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * event_fangfaIMG;
@property (nonatomic, retain) Test *whoDo;

@end
