//
//  DevConDemoTests.m
//  DevConDemoTests
//
//  Created by Jason Jobe on 6/1/13.
//  Copyright (c) 2013 Jason Jobe. All rights reserved.
//

#import "DevConDemoTests.h"
#import "EXTScope.h"
#import "Person.h"
#import "logs.h"



@interface Spouse : Entity
@property Person *spouse;
- (BOOL)isMarried;
@end

@implementation Spouse
@dynamic spouse;
- (BOOL)isMarried {
    return YES;
}
@end



@implementation DevConDemoTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- makeGeorge
{
    Person *george = [Person entityNamed:@"George Jetson"];
    
    Spouse *sp = [george becomeClassForType:[Spouse class]];
    sp.spouse = [Person entityNamed:@"Jane Jetson"];
    
    plog (@"George is married to %@", [(id)george spouse]);
    return george;
}

- (void)testExample_1
{
    Person *george = [self makeGeorge];
    plog (@"%@", [george longDescription]);
    
    plog (@"George %s married", ([(id)george isMarried] ? "is" : "is NOT"));
//    plog (@"Jane %s married", ([(id)[(id)george spouse] isMarried] ? "is" : "is NOT"));

    plog (@"It is %@", ([george is_a:@"Spouse"] ?@"true" : @"false"));
}


@end
