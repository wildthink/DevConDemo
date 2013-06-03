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

#define mac(...) try{} @finally {} sprintf(stdout, "hi")

- (void)testExample_1
{
    Person *george = [Person entityNamed:@"George Jetson"];
    
    plog (@"%@", [george longDescription]);
    
    NSOrderedSet *set = [NSOrderedSet orderedSet];
    plog (@"first: %@", [set firstObject]);
}

@end
