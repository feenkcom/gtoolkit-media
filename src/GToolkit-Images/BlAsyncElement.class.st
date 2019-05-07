"
BlAsyncElement is an abstract class that provides a simple framework for Bloc Elements that need to perform asynchronous processing of the display, typically because it is CPU intensive, has lots of I/O or depends on other asynchronous elements such as network access.

Using BlAsyncElement consists of creating two classes: 

- A subclass of BlAsyncElement, which is responsible for drawing the results on the canvas.
- A subclass of BlAsyncElementValuable, which is responsible for performing the asynchronous operations.

TaskIt is used to queue and execute operations.  Multiple items may be queued for an element before the first is executed, so the normal approach is to determine the work to be performed at the time the valuable is evaluated.  Subsequent tasks will realise that no additional work is required and finish quickly.

By default, an update is scheduled:

- When the receiver is added to a scene graph.
- When the receiver's layout is changed.

Subclasses can schedule additional updates by sending #queueAsyncUpdate to themselves.

Because adding tasks and their execution order is indeterminate, no attempt is made to remove duplicates, rather the task should confirm that an update is required by calling #needsUpdate.

Subclasses are responsible for implementing #drawOnSpartaCanvas:.

There are two ""priorities"" involved with BlAsyncElement:

- All background processing is done by BlAsyncUIWorkerPool at the Process priority specified in BlTKTBackgroundProcessProvider>>createProcessDoing:named:.
- Items are retrieved from the task queue in priority order.  Priority 0 is the highest priority, with positive numbers being progressively lower priority.  Normally priorities are calculated dynamically, with elements that are currently visible receiving the highest priority, and then lower priority the further away from the visible area they are.

By default the dynamic priority will be based on whether the receiver is within the space's bounds.  However it is possible (or likely) that the receiver will be a child of another element that only occupies a small portion of the space.  Specifying the parent which has the actual visible area improves the priority order.


Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	priority:		<Integer>  An optional manually set priority at relative to other BlAsyncElements. 0 is highest priority.
	visibleElement: <BlElement> The dynamic priority will be based on whether the receiver is visible within the visibleElement.
	taskitRunner: <Object> The object that is used to schedule tasks.  The default is BlAsyncUIWorkerPool, but this can be replaced with TKTLocalProcessTaskRunner to facilitate testing.

    Implementation Points
"
Class {
	#name : #BlAsyncElement,
	#superclass : #BlElement,
	#instVars : [
		'priority',
		'visibleElement',
		'taskitRunner'
	],
	#category : #'GToolkit-Images-Elements'
}

{ #category : #layout }
BlAsyncElement >> applyLayoutIn: aBlBounds [

	
	super applyLayoutIn: aBlBounds.
	self queueAsyncUpdate
]

{ #category : #accessing }
BlAsyncElement >> maxPoolSize [
	"Answer the maximum number of tasks that can be executed concurrently"

	^1
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

	BlAsyncUIWorkerPool schedule: self queueEntry maxPoolSize: self maxPoolSize.

]

{ #category : #'async processing' }
BlAsyncElement >> queueEntry [
	"Answer a valuable that will update the receiver when processed"

	^self subclassResponsibility
]

{ #category : #accessing }
BlAsyncElement >> taskitRunner [

	^ taskitRunner ifNil: [ taskitRunner := BlAsyncUIWorkerPool ]
]

{ #category : #accessing }
BlAsyncElement >> taskitRunner: anObject [
	taskitRunner := anObject
]

{ #category : #accessing }
BlAsyncElement >> visibleElement [
	"Answer the element which will be used to calculate the receivers evaluation priority.
	Default = the space's root element"

	^ visibleElement ifNil: [ self space root ]
]

{ #category : #accessing }
BlAsyncElement >> visibleElement: aBlElement [
	"Answer the element which will be used to calculate the receivers evaluation priority.
	Default (nil) = the space's root element"

	visibleElement := aBlElement
]
