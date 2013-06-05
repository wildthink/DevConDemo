//
//  entity_i.h
//  mDx
//
//  Created by Jobe,Jason on 5/27/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class Type;

@interface entity_i : NSObject
{
    @package
    CFUUIDRef guid;
    Type *preferredType;
    NSOrderedSet *e_types;
    NSMapTable *strongProperties;
    NSMapTable *weakProperties;
}

- clone;

- (NSString *)guidString;
//- (BOOL)conformsToProtocolType:(Protocol*)protocol;

//- (void)includeType:ctype;
//- (void)removeIncludedType:(Type*)superType;

- (void)setValue:(id)value forKey:(NSString *)key policy:(objc_AssociationPolicy)policy;

- (BOOL)hasAnyValueOfType:(Type*)type;

-(NSEnumerator*)enumeratorForValuesOfType:(Type*)type;

@end