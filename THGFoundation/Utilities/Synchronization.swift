//
//  Synchronization.swift
//  THGFoundation
//
//  Created by Brandon Sneed on 2/19/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation

/**
Mimics @synchronized(x) in Objective-C.  Synchronizes around the given object
and executes the supplied closure.

:param: lock Object to lock around.
:param: closure Closure to execute inside of the lock.

Example: synchronized(self) { doSomething() }
*/
public func synchronized(lock: AnyObject, closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

/**
Mimics @synchronized(x) in Objective-C.  Synchronizes around the given object
and executes the supplied closure, returning the type T.

:param: lock Object to lock around.
:param: closure Closure to execute inside of the lock.
:returns: The result of the closure.

Example: let running = synchronized(self) { return true }
*/
public func synchronized<T>(lock: AnyObject, closure: () -> T) -> T {
    objc_sync_enter(lock)
    let result: T = closure()
    objc_sync_exit(lock)
    return result
}


/**
OS Level Spin Lock class.  Wraps the OSSpinLock* functions to allow for
synchronization around a specified closure.  This is very useful for properties
where get/set need to be thread-safe.
*/
final public class Spinlock {
    
    public init() {
        
    }
    
    /**
    Runs the specified closure within the spin lock.
    
    :param: closure Closure to execute inside of the lock.
    */
    public func around(closure: () -> Void) {
        OSSpinLockLock(&lock)
        closure()
        OSSpinLockUnlock(&lock)
    }
    
    /**
    Runs the specified closure within the spin lock, returning the type T.
    
    :param: closure Closure to execute inside of the lock.
    :returns: The result of the closure.
    */
    public func around<T>(closure: () -> T) -> T {
        OSSpinLockLock(&lock)
        let result: T = closure()
        OSSpinLockUnlock(&lock)
        return result
    }
    
    private var lock: OSSpinLock = OS_SPINLOCK_INIT
}
