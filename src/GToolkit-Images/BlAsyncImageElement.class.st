Class {
	#name : #BlAsyncImageElement,
	#superclass : #BlAsyncElement,
	#instVars : [
		'form',
		'bitmap'
	],
	#category : #'GToolkit-Images-Elements'
}

{ #category : #initialization }
BlAsyncImageElement >> clearForm [

	form := bitmap := nil.
]

{ #category : #drawing }
BlAsyncImageElement >> drawOnSpartaCanvas: aCanvas [

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
BlAsyncImageElement >> form [
	^ form
]

{ #category : #accessing }
BlAsyncImageElement >> form: anObject [

	form := anObject.
	bitmap := nil.
	form ifNotNil: [ self invalidate ]
]

{ #category : #accessing }
BlAsyncImageElement >> needsUpdate [
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

{ #category : #'async processing' }
BlAsyncImageElement >> queueEntry [
	"Answer a TaskIt valuable that will update the receiver."

	^self subclassResponsibility

]
