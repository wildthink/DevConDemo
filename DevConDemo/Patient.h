//
//  Patient.h
//  DevConDemo
//
//  Created by Jason Jobe on 6/1/13.
//  Copyright (c) 2013 Jason Jobe. All rights reserved.
//

#import "Entity.h"
#import "Person.h"


@interface Patient : Entity
@property (strong, nonatomic) Person *doctor;
@end
