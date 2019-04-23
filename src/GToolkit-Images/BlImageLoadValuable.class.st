"
BlImageLoadValuable is responsible for loading a single image from disk or the network.

Currently a fixed strategy of always loading the original image and scaling as required is used, but various thumbnail strategies are expected to be implemented in future.  Whether to use the original image or a thumbnail will be determined by the requested Form size.  How the thumbnails are stored will be configurable.


Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.


    Implementation Points

- Only loading images from disk is currently being implemented.

Future performance plans:

- Support one or more thumbnail stores to speed up display of thumbnails.
- Use AsyncFilePlugin to allow other processing while loading a full image.

"
Class {
	#name : #BlImageLoadValuable,
	#superclass : #Object,
	#instVars : [
		'file',
		'form',
		'element'
	],
	#category : #'GToolkit-Images-Model'
}

{ #category : #'instance creation' }
BlImageLoadValuable class >> file: aFileReference element: aBlElement [

	^self new initializeFile: aFileReference element: aBlElement
]

{ #category : #converting }
BlImageLoadValuable >> asTask [ 

	^TKTTask valuable: self
]

{ #category : #acccessing }
BlImageLoadValuable >> extent [ 

	| extent |

	extent := element extent.
	^(extent x = 0 or: [ extent y = 0 ]) 
		ifTrue: [ nil ]
		ifFalse: [ extent ]
]

{ #category : #acccessing }
BlImageLoadValuable >> form [ 
	"Answer the form from the receiver's file scaled to displayWidth and displayHeight (if specified)"

	^form ifNil: [ form := self getForm ]
]

{ #category : #private }
BlImageLoadValuable >> getBuffer [
	"Answer the contents of the file in a ByteArray.
	While this method is synchronous, file access is async"

	| asyncFile fileSemaphore buffer |

	asyncFile := AsyncFile new.
	fileSemaphore := Semaphore new.
	asyncFile open: file pathString forWrite: false.
	[ asyncFile readByteCount: file size fromFilePosition: 0 onCompletionDo: 
		[ :buf | buffer := buf.  fileSemaphore signal ].
        fileSemaphore wait. ] ensure: [ asyncFile close ].
	"Hack to work around AsyncFile returning a string instead of a ByteArray"
	ByteArray adoptInstance: buffer.
	^buffer
]

{ #category : #private }
BlImageLoadValuable >> getForm [
	"Answer the scaled form for the receiver's element.
	For now always re-read the form from disk, possible futures include:
	If the receiver doesn't have a form, or it has increased in size, load from disk and scale.
	If the form is being reduced in size, just scale the existing form"

	| newForm |

	element needsNewForm ifFalse: [ ^nil ].

	newForm := self getNewForm.
	newForm extent = self extent ifFalse:
		[ newForm := newForm scaledToSize: self extent ].
	^newForm
]

{ #category : #private }
BlImageLoadValuable >> getNewForm [
	"Retrieve the image from the file"

	^ImageReadWriter gtFormFromBuffer: self getBuffer.

]

{ #category : #initialization }
BlImageLoadValuable >> initializeFile: aFileReference element: aBlElement [

	self initialize.
	file := aFileReference asFileReference.
	element := aBlElement
]

{ #category : #acccessing }
BlImageLoadValuable >> taskPriority [
	"Answer the task priority of the receiver.
	If the element is visible, answer 0 (highest priority), otherwise answer the distance from the center of the display"

	| rootBounds elementBounds |

	element isAttachedToSceneGraph ifFalse: 
		"The element is probably being inspected, assume that's what the user wants to see"
		[ ^0 ].

	"Determine the of the element and its space (in the parent's coordinate system).
	It may be that the element only takes up part of the space, so this is an approximation.
	ToDo: Be able to set the parent element which should be used to calculate the distance"
	rootBounds := element space root bounds asRectangle.
	elementBounds := element boundsInSpace.

	"If the element is visible, load ASAP"
	(rootBounds containsRect: elementBounds) ifTrue: [ ^0 ].
	"Otherwise, priority is proportional to distance from viewable area"
	^rootBounds center distanceTo: elementBounds center
]

{ #category : #evaluating }
BlImageLoadValuable >> value [
	"Evaluate the receiver and answer the BlElement"

	"If the element's window has been closed, log and do nothing"
	"At the moment, an element doesn't have a space when it is inspected,
	wait until we have a better test"
	"(element space isNil or: [ element space hasHostSpace not ]) ifTrue: [ | signal |
		signal := StringSignal new.
		signal message: 'BlImageLoadValuable value aborted'.
		signal properties at: #fileName put: element file.
		signal emit.
		^nil ]."

	^form ifNil: [
		"1.5 seconds wait."
		self form ifNotNil: [ element form: form ].
		form ]
]
