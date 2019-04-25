"
BlAsyncElementValuable is an abstract class that collaborates with BlAsyncElement to asynchronously update the state of BlAsyncElements with minimal impact on UI responsiveness.


Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	element:		<Object>


    Implementation Points
"
Class {
	#name : #BlAsyncElementValuable,
	#superclass : #Object,
	#instVars : [
		'element'
	],
	#category : #'GToolkit-Images-Model'
}

{ #category : #converting }
BlAsyncElementValuable >> asTask [ 

	^TKTTask valuable: self
]

{ #category : #accessing }
BlAsyncElementValuable >> taskPriority [
	"Answer the task priority of the receiver.
	If the element is visible, answer 0 (highest priority), otherwise answer the distance from the center of the display"

	| rootBounds elementBounds |

	element isAttachedToSceneGraph ifFalse: 
		"The element is probably being inspected, assume that's what the user wants to see"
		[ ^0 ].

	"If a priority has been specified, use that"
	element priority ifNotNil: [ ^element priority ].

	"Determine the of the element and its space (in the parent's coordinate system).
	It may be that the element only takes up part of the space, so this is an approximation.
	ToDo: Be able to set the parent element which should be used to calculate the distance"
	rootBounds := element visibleElement boundsInSpace.
	elementBounds := element boundsInSpace.

	"If the element is visible, load at high priority"
	(rootBounds containsRect: elementBounds) ifTrue: [ ^1 ].
	"Otherwise, priority is proportional to distance from viewable area"
	^rootBounds center distanceTo: elementBounds center
]

{ #category : #private }
BlAsyncElementValuable >> updateElement [
	"Update the receiver's element"

	self subclassResponsibility
]

{ #category : #evaluating }
BlAsyncElementValuable >> value [

	element needsUpdate ifFalse: [ ^nil ].
	^self updateElement
]
