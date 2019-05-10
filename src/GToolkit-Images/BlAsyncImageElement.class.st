"
BlAsyncImageElement is an abstract class that provides a framework for Bloc elements that display an image that should be loaded in a background processes (to leave the UI responsive).

Each subclass BlAsyncImageElement requires a matching ${class:name=BlAsyncImageElementValuable}$ that is responsible for doing the work of retrieving the ${class:name=Form}$ and updating the receiver.

BlAsyncImageElement minimises memory and CPU usage by ensuring that the ${class:name=Form}$ held in memory is approximately the same size as the on-screen display size.  This ensures that memory is not wasted in the case where the form is much larger than the on-screen area, and that image quality is not compromised in the case where the form is much smaller than the on-screen display size.  See ${method:name=BlAsyncImageElement>>#needsUpdate}$.

Subclasses of BlAsyncImageElement are responsible for holding the details of how to retrieve the image and answering their valuable, see ${method:name=BlAsyncImageElement>>#queueEntry}$ and  ${method:name=BlAsyncImageElementValuable>>#getNewForm}$.

!!Public API and Key Messages

BlAsyncImageElement has the same public API as BlElement.  As an abstract class, it shouldn't be instantiated.

 
!!Internal Representation and Key Implementation Points

!!!Instance Variables
	bitmap:		<MozSurface>  Moz2D representation of the form.
	form:			<Form>  The image being displayed.


!!Implementation Points
"
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
BlAsyncImageElement >> form: aForm [
	"Set the receiver's form.
	This can be called from a background process, thus ensure the invalidation is done in the UI process"

	form := aForm.
	bitmap := nil.
	form ifNotNil: [ self enqueueTask: (BlTaskAction new action: [ self invalidate ]) ]

]

{ #category : #accessing }
BlAsyncImageElement >> needsUpdate [
	"Answer a boolean indicating whether the current form is too small or too large"

	| currentExtent formSize currentSize |

	super needsUpdate ifFalse: [ ^false ].
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
	"Answer a kind of BlAsyncImageElementValuable that will update the receiver."

	^self subclassResponsibility

]
