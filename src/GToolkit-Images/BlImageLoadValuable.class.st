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
	"Retrieve the image from the file and scale if necessary"

	| newForm |

	"newForm := ImageReadWriter gtFormFromFileReference: file."
	newForm := ImageReadWriter gtFormFromBuffer: self getBuffer.
	self extent ifNotNil: [ newForm := newForm scaledToSize: self extent ].
	^newForm
]

{ #category : #initialization }
BlImageLoadValuable >> initializeFile: aFileReference element: aBlElement [

	self initialize.
	file := aFileReference asFileReference.
	element := aBlElement
]

{ #category : #acccessing }
BlImageLoadValuable >> taskPriority [

	^0
]

{ #category : #evaluating }
BlImageLoadValuable >> value [
	"Evaluate the receiver and answer the BlElement"

	^form ifNil: [ 
		"(Delay forSeconds: 1) wait."
		element background: self form.
		form ]
]