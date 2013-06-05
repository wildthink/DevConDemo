//
//  Entity.m
//
//  Created by Jobe,Jason on 4/24/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Entity.h"
#import "Type.h"
#import "entity_i.h"
#import "Entity+DynamicAccessors.h"
#import "EXTRuntimeExtensions.h"
#import <objc/runtime.h>

@interface entity_i (EntityPrivate)
- (void)setValue:(id)value forKey:(NSString *)key policy:(objc_AssociationPolicy)policy;
@end


static BOOL _WTIsProtocol (id type) {
    NSString *name = NSStringFromProtocol(type);
    return (name != nil);
}

static BOOL WTIsClass (id type) {
    NSString *name = NSStringFromClass(type);
    return (name != nil);
}


//BOOL rt_isSubclassOf (Class child, Class parent)
//{
//    Class curClass = child;
//    
//    while (curClass != Nil && curClass != parent) {
//        curClass = class_getSuperclass(curClass);
//    }
//    return (child == parent);
//}

static Class WTAsClass (id type) {
    
    Class t_class;
    
    if ([type isKindOfClass:[NSString class]]) {
        t_class = NSClassFromString(type);
    } else if ([type isKindOfClass:[Type class]]) {
        t_class = ((Type*)type).implClass;
    } else if (WTIsClass(type)){
        t_class = (Class)type;
    } else {
        t_class = Nil;
    }
    return t_class;
}

static BOOL areGUIDSEqual (CFUUIDRef g1, CFUUIDRef g2) {
    CFUUIDBytes gb1 = CFUUIDGetUUIDBytes(g1);
    CFUUIDBytes gb2 = CFUUIDGetUUIDBytes(g2);
    size_t size = sizeof(gb1);
    int cmp = memcmp(&gb1, &gb2, size);
    return (cmp == 0);
}

//////////////////////////  ENTITY  /////////////////////////////////////////

@interface Entity()
@property (strong, nonatomic) entity_i *internal;
@property (readwrite, nonatomic) NSOrderedSet *types;

- (void)includeType:(Type*)aType;
- (void)removeIncludedType:(Type*)superType;

@end


@implementation Entity


+ entityWithEntity:(Entity*)anObject;
{
    if ([anObject isKindOfClass:[self class]])
        return anObject;
    // else
    id ent = [[self alloc] initWithEntity:anObject];
    return ent;
}

- init {
    _internal = [[entity_i alloc] init];
    [self includeType:[Type typeForClass:[self class]]];
    return self;
}

- initWithEntity:(Entity*)anObject;
{
    _internal= anObject->_internal;
    [self includeType:[Type typeForClass:[self class]]];
    return self;
}

- clone {
    Entity *ent = [Entity alloc];
    ent->_internal = [_internal clone];
    return ent;
}

- (CFUUIDRef)guid {
    return _internal->guid;
}

- (NSString*)sguid {
    return [_internal guidString];
}

- (Type*)preferredType {
    return (_internal->preferredType ? _internal->preferredType : [_internal->e_types firstObject]);
}

- (void)removeIncludedType:(Type*)superType;
{
    [(NSMutableSet*)self.types removeObject:superType];
}

- (void)includeType:(Type*)aType;
{
    if ([self.types containsObject:aType]) {
        return;
    }

    // remove redundant types
    NSMutableOrderedSet *toKeep = [NSMutableOrderedSet orderedSet];
    for (Type *t in self.types) {
        if (![aType doesIncludeType:t])
            [toKeep addObject:t];
    }
    [toKeep addObject:aType];
    self.types = toKeep;
}

//- (void)disassociateFrom:(Type*)superType;
//{
//    [_internal removeIncludedType:superType];
//}

/**
 A Set of Types
 */
- (NSOrderedSet*)types {
    return _internal->e_types;
}

- (void)setTypes:(NSOrderedSet *)types
{
    _internal->e_types = types;
}

- as_a:type
{
    Type *t = [Type typeFor:type];

    if (t == nil)
        return nil;

    if (rt_isSubclassOf ([self class], t.implClass)) {
        return self;
    }
    for (Type *myType in _internal->e_types) {
        if ([myType doesIncludeType:t])
            return [myType instantiateEntity:self];
    }
    return nil;
}

-(BOOL)isOneOf:(NSArray*)types
{
    for (id type in types) {
        Type *t_type = [Type typeFor:type];
        if ([self isKindOfType:t_type])
            return YES;
    }
    // else
    return NO;
}

- (BOOL)isKindOfType:(Type*)type;
{    
    if (type == nil)
        return NO;
    
    if ([[self class] isSubclassOfClass:type.implClass])
        return YES;
    
    for (Type *myType in _internal->e_types) {
        if ([myType doesIncludeType:type])
            return YES;
    }
    return NO;    
}

- (BOOL)is_a:type
{
    if ([type isKindOfClass:[NSArray class]]) {
        return [self isOneOf:type];
    }
    // else
    Type *t_type = [Type typeFor:type];
    return [self isKindOfType:t_type];
}

-(BOOL)hasAnyValueOfType:(id)type
{
    Type *t_type = [Type typeFor:type];
    return [_internal hasAnyValueOfType:t_type];
}

- (Class)classSupportingProtocol:(Protocol *)aProtocol
{
    Class classToBe = Nil;
    
    for (Type *myType in _internal->e_types) {
        if ([myType conformsToTypeProtocol:aProtocol]) {
            classToBe = myType.implClass;
            break;
        }
    }
    return classToBe;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    Class classToBe = [self classSupportingProtocol:aProtocol];
    return (classToBe != Nil);
}

- becomeTypeConformingToProtocol:(Protocol*)aProtocol;
{
    Class classToBe = [self classSupportingProtocol:aProtocol];
    return (classToBe ? [[classToBe class] entityWithEntity:self] : nil);
}


#pragma mark Forwarding support

/**
 This is much less expensive alternative to forwardInvocation
 */

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    for (Type *myType in _internal->e_types) {
        if ([myType typeInstancesRespondToSelector:aSelector]) {
            return [self as_a:myType];
        }
    }
    // else
    return nil;
//    return [super forwardingTargetForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    id entity = [self forwardingTargetForSelector:[anInvocation selector]];
    if (entity) {
        [anInvocation setTarget:entity];
        [anInvocation invoke];
    }
    else {
    
    [[NSException exceptionWithName:@"Unrecognized Selector"
                             reason:NSStringFromSelector([anInvocation selector])
                           userInfo:nil] raise];
//    [super forwardInvocation:anInvocation];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    Method m = class_getInstanceMethod([self class], aSelector);
    if (m) {
        return YES;
    }
    for (Type *myType in _internal->e_types) {
        if ([myType typeInstancesRespondToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    // find the first target that responds to the specified selector
        return ext_globalMethodSignatureForSelector(aSelector);    
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    // find the first target that responds to the specified selector
    return ext_globalMethodSignatureForSelector(aSelector);
}

/**
 Returns self as type, adopting type if required.
 */

- becomeClassForType:type
{
    Type *t = [Type typeFor:type];
    
    if (! t) {
        [NSException raise:@"Illegal type designator" format:@"%@ is NOT a Type, Class or String", type];
    }
    if ([[self class] isSubclassOfClass:t.implClass])
        return self;
    // else
    return [t instantiateEntity:self];
}

- (void)adoptType:type
{
    if ([type isKindOfClass:[NSArray class]]) {
        [self adoptTypes:type];
    }
    else {
        [self includeType:type];
    }
}

- (void)adoptTypes:(NSArray*)types;
{
    for (id type in types) {
        [self includeType:type];
    }
}

- (BOOL)is:(Entity *)otherEntity
{
    return areGUIDSEqual(_internal->guid, otherEntity->_internal->guid);
}

- (BOOL)isIsomorphicTo:(Entity*)otherEntity
{
    return
    ([_internal->strongProperties isEqual:otherEntity->_internal->strongProperties]
     && [_internal->weakProperties isEqual:otherEntity->_internal->weakProperties]);
}


- (NSString*)longDescription
{
    NSMutableString *mstr = [NSMutableString stringWithCapacity:([_internal->strongProperties count] * 4)];
    [mstr appendFormat:@"<%@:%@", self.class, self.sguid];
    
    for (NSString *key in _internal->strongProperties) {
        id val = [self valueForKey:key];
        [mstr appendFormat:@"\n\t%@: %@", key, val];
    }
    [mstr appendString:@">"];
    return mstr;
}

#pragma mark NSKeyValueCoding overrides

- (id)valueForUndefinedKey:(NSString *)key
{
    return [_internal valueForKey:key];
}

- (id)valueForKey:(NSString *)key
{
    return [_internal valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [_internal setValue:value forKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [_internal setValue:value forKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key policy:(objc_AssociationPolicy)policy
{
    [_internal setValue:value forKey:key policy:policy];
}

@end


@implementation NSObject (TypeChecking)

- (BOOL)isKindOfType:(Type*)type;
{
    if (type == nil)
        return NO;
    
    return ([[self class] isSubclassOfClass:type.implClass]);
}

@end
