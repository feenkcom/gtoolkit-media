"
BlLazyElement is intended to perform lazy rendering of an element, deferring the rendering until the element actually becomes visible in the window.  E.g. if the window can be scrolled and the element is not visible, no action is taken.

The initial version only partially implements this goal, it currently renders the element in a background priority queue so that elements that are visible are rendered first, followed by their distance from the visible portion of the window.

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	element:		<Object>
	elementBuilder:		<Object>


    Implementation Points
"
Class {
	#name : #BlLazyElement,
	#superclass : #BlAsyncElement,
	#instVars : [
		'elementBuilder',
		'element'
	],
	#category : #'GToolkit-Images-Elements'
}

{ #category : #ui }
BlLazyElement >> buildElement [
	"Build the element and display it"

	self assert: elementBuilder isNotNil
			description: 'No element builder has been set'.
	self element: elementBuilder value.

]

{ #category : #accessing }
BlLazyElement >> element [
	^ element
]

{ #category : #accessing }
BlLazyElement >> element: aBlElement [
	"Set the receiver's element.
	If not nil, add it as a child"

	element := aBlElement.
	element ifNotNil:[ 
		self enqueueTask: (BlTaskAction new action: [ 
			self 
				removeChildren;
				addChild: element;
				invalidate ]) ]

]

{ #category : #accessing }
BlLazyElement >> elementBuilder [
	^ elementBuilder
]

{ #category : #accessing }
BlLazyElement >> elementBuilder: anObject [
	elementBuilder := anObject
]

{ #category : #testing }
BlLazyElement >> needsUpdate [
	"Answer a boolean indicating whether the receiver needs to be udpated"

	super needsUpdate ifFalse: [ ^false ].
	^element isNil and: [ asyncException isNil ].

]

{ #category : #'async processing' }
BlLazyElement >> queueEntry [
	"Answer a TaskIt valuable that will update the receiver."

	^(BlTktUnresponsiveCommand new 
		valuable: (BlLazyElementValuable element: self);
		name: 'BlLazyElement(', elementBuilder printString, ')';
		yourself) asBlTktLoggingCommand

]

{ #category : #'async processing' }
BlLazyElement >> taskPool [
	^ BlTktWorkerProvider highUICPUBoundPool 
]
