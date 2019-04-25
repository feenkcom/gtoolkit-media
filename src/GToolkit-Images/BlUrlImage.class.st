"
BlUrlImage is a Bloc element for displaying images:

- Images are loaded and resized on a low (Process) priority queue so that UI responsiveness is maintained.
- Images are loaded in priority based on: 
-- A manually specified priority 
-- Whether they are visible or,
-- How far they are from the visible area.

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	bitmap:		<Object>
	file:		<FileReference>
	form:		<Form>
	url:		<String>
	priority: <Integer>  The queue priority to use. nil for default.  0 is highest priority.


    Implementation Points

- The are multiple tradeoffs between memory consumption, memory management (impact on the memory management system, particularly garbage collection) and CPU usage.   Currently the decision when to reload the Form is hard coded in ${method:name=BlUrlImage>>#needsNewForm}$.
"
Class {
	#name : #BlUrlImage,
	#superclass : #BlAsyncElement,
	#instVars : [
		'file',
		'form',
		'bitmap'
	],
	#category : #'GToolkit-Images-Model'
}

{ #category : #accessing }
BlUrlImage class >> file: aFileReference [

	^self new file: aFileReference
]

{ #category : #initialization }
BlUrlImage >> clearForm [

	form := bitmap := nil.
]

{ #category : #drawing }
BlUrlImage >> drawOnSpartaCanvas: aCanvas [

	| ratio imageExtent translation |

	super drawOnSpartaCanvas: aCanvas.
	form ifNil: [ ^self ].

	bitmap ifNil: [ bitmap := aCanvas bitmap fromForm: form ].
	
	ratio := (self extent x / form width min: self extent y / form height) asFloat.
	imageExtent := form extent * ratio.
	translation := (((self extent x - imageExtent x ) / 2.0) @
		((self extent y - imageExtent y) / 2.0)) asIntegerPoint.

	aCanvas transform
		by: [ :t | 
			t 
				translateBy: translation;
				scaleBy: ratio
				 ]
		during: [
			aCanvas fill
				path: (0@0 extent: form extent);
				paint: bitmap;
				draw ].

]

{ #category : #accessing }
BlUrlImage >> file [ 

	^file
]

{ #category : #accessing }
BlUrlImage >> file: aFileReference [
	"Load the supplied file in the background processor (which will update the receiver when done"

	file := aFileReference asFileReference.
	self queueAsyncUpdate
]

{ #category : #accessing }
BlUrlImage >> form [
	^ form
]

{ #category : #accessing }
BlUrlImage >> form: anObject [

	form := anObject.
	bitmap := nil.
	form ifNotNil: [ self invalidate ]
]

{ #category : #accessing }
BlUrlImage >> needsUpdate [
	"Answer a boolean indicating whether the current form is too small or too large"

	| currentExtent formSize currentSize |

	self isAttachedToSceneGraph ifFalse: [ ^false ].
	currentExtent := self extent.
	currentExtent = (0@0) ifTrue: [ ^false ].
	formSize := form
		ifNil: [ 1 ]
		ifNotNil: [ form width * form height ].
	currentSize := currentExtent x * currentExtent y.
	^((currentSize / formSize) between: 0.5 and: 2) not

]

{ #category : #accessing }
BlUrlImage >> queueEntry [
	"Answer a TaskIt valuable that will update the receiver."

	^BlImageLoadValuable file: file element: self

]
