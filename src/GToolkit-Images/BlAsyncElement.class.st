"
BlAsyncElement is an abstract class that provides a simple framework for Bloc Elements that need to perform asynchronous processing of the display, typically because it is CPU intensive, has lots of I/O or depends on other asynchronous elements such as network access.

Using BlAsyncElement consists of creating two classes: 

- A subclass of BlAsyncElement, which is responsible for drawing the results on the canvas.
- A subclass of BlAsyncElementValuable, which is responsible for performing the asynchronous operations.

TaskIt is used to queue and execute operations.  Multiple items may be queued for an element before the first is executed, so the normal approach is to determine the work to be performed at the time the valuable is evaluated.  Subsequent tasks will realise that no additional work is required and finish quickly.

By default, an update is scheduled:

- When the receiver is added to a scene graph.
- When the receiver's layout is changed.

Subclasses can schedule updates by sending #queueAsyncUpdate to themselves.

Because adding tasks and their execution order is indeterminate, no attempt is made to remove duplicates, rather the task should confirm that an update is required by calling #needsUpdate.

Subclasses are responsible for implementing #drawOnSpartaCanvas:.

There are two ""priorities"" involved with BlAsyncElement:

- All background processing is done by BlAsyncUIWorkerPool at the Process priority specified in BlTKTBackgroundProcessProvider>>createProcessDoing:named:.
- Items are retrieved from the task queue in priority order.  Priority 0 is the highest priority, with positive numbers being progressively lower priority.

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	priority:		<Integer>  The priority at relative to other BlAsyncElements. 0 is highest priority.


    Implementation Points
"
Class {
	#name : #BlAsyncElement,
	#superclass : #BlElement,
	#instVars : [
		'priority'
	],
	#category : #'GToolkit-Images-Model'
}

{ #category : #layout }
BlAsyncElement >> applyLayoutIn: aBlBounds [

	
	super applyLayoutIn: aBlBounds.
	self queueAsyncUpdate
]

{ #category : #'async processing' }
BlAsyncElement >> needsUpdate [
	"Answer a boolean indicating whether the receiver needs to be updated (via an asynchronous task).
	Typically this will be overridden by concrete subclasses to avoid unnecessary updates."

	^self isAttachedToSceneGraph

]

{ #category : #'async processing' }
BlAsyncElement >> onAddedToSceneGraph [

	super onAddedToSceneGraph.
	self queueAsyncUpdate.
]

{ #category : #accessing }
BlAsyncElement >> priority [
	^ priority
]

{ #category : #accessing }
BlAsyncElement >> priority: anInteger [

	priority := anInteger
]

{ #category : #'async processing' }
BlAsyncElement >> queueAsyncUpdate [
	"Queue a task to update the receiver's state."

	self needsUpdate ifFalse: [ ^self ].

	BlAsyncUIWorkerPool schedule: self queueEntry.

]

{ #category : #'async processing' }
BlAsyncElement >> queueEntry [
	"Answer a valuable that will update the receiver when processed"

	^self subclassResponsibility
]
