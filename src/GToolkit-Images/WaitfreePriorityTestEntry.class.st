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
	#name : #WaitfreePriorityTestEntry,
	#superclass : #Object,
	#instVars : [
		'priority'
	],
	#category : #'GToolkit-Images-Tests'
}

{ #category : #'instance creation' }
WaitfreePriorityTestEntry class >> priority: aNumber [

	^self new
		priority: aNumber;
		yourself
]

{ #category : #printing }
WaitfreePriorityTestEntry >> printOn: aStream [

	super printOn: aStream.
	aStream 
		<< '(';
		print: priority;
		<< ')'
]

{ #category : #accessing }
WaitfreePriorityTestEntry >> priority [
	^ priority
]

{ #category : #accessing }
WaitfreePriorityTestEntry >> priority: anObject [
	priority := anObject
]
