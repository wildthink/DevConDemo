//
//  Entity.h
//  mDx
//
//  Created by Jobe,Jason on 4/24/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Type;

@interface NSObject (TypeChecking)
- (BOOL)isKindOfType:(Type*)type;
@end


@interface Entity : NSProxy

@property (readonly) CFUUIDRef guid;
@property (readonly) NSString* sguid;
@property (readonly, nonatomic) NSOrderedSet *types;


- initWithEntity:(Entity*)aObject;

- clone;

- (Type*)preferredType;

/**
 Returns self cast into type if it is one.
 If type is NOT a member of types then nil is returned;
*/
- as_a:type;

/**
 Type can be designated by an actual Type, Class, or Type or Class name.
 If an array of types is passed as the type parameter, we AND the checks.
*/
- (BOOL)is_a:type;

/** Using an explicit Array of types
 */
- (BOOL)isOneOf:(NSArray*)types;
- (BOOL)isKindOfType:(Type*)type;


/** nil if no conforming type Class is found
 */
- (Class)classSupportingProtocol:(Protocol *)aProtocol;
- becomeTypeConformingToProtocol:(Protocol*)proto;

/**
 Returns self as a potentially new Class for the type, adopting type if required. 
 NOTE: This is likely to be a new instance pointer.
 */
- becomeClassForType:type;

- (void)adoptType:type;
- (void)adoptTypes:(NSArray*)types;

/*
 This does NOT compare properties. It only confirms that self and otherEntity
 are semantically the same.
 */
- (BOOL)is:(Entity*)otherEntity;

/** 
 This methods ONLY compares the properties.
 */
- (BOOL)isIsomorphicTo:(Entity*)otherEntity;


- (NSString*)longDescription;

/** Same rules as "is_a" but checks
    the types of the instance variables.
 */
- (BOOL)hasAnyValueOfType:type;

@end

