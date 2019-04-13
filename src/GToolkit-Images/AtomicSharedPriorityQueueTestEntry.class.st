"
GtImageTestQueueEntry provides a dummy object that can be inserted in to GtImageLoadQueue for testing.



Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	priority:		<Object>


    Implementation Points
"
Class {
	#name : #AtomicSharedPriorityQueueTestEntry,
	#superclass : #Object,
	#instVars : [
		'priority'
	],
	#category : #'GToolkit-Images-Tests'
}

{ #category : #'instance creation' }
AtomicSharedPriorityQueueTestEntry class >> priority: aNumber [

	^self new
		priority: aNumber;
		yourself
]

{ #category : #printing }
AtomicSharedPriorityQueueTestEntry >> printOn: aStream [

	super printOn: aStream.
	aStream 
		<< '(';
		print: priority;
		<< ')'
]

{ #category : #accessing }
AtomicSharedPriorityQueueTestEntry >> priority [
	^ priority
]

{ #category : #accessing }
AtomicSharedPriorityQueueTestEntry >> priority: anObject [
	priority := anObject
]
