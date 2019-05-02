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
	#superclass : #BlAsyncElementValuable,
	#instVars : [
		'file',
		'form'
	],
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #'instance creation' }
BlImageLoadValuable class >> file: aFileReference element: aBlElement [

	^self new initializeFile: aFileReference element: aBlElement
]

{ #category : #acccessing }
BlImageLoadValuable >> extent [ 
	"Answer the receiver's element extent if open, or nil"

	| extent |

	extent := element extent.
	^(extent x = 0 or: [ extent y = 0 ]) 
		ifTrue: [ nil ]
		ifFalse: [ extent ]
]

{ #category : #acccessing }
BlImageLoadValuable >> form [ 
	"Answer the form from the cache"

	^form ifNil: [ form := self getNewForm ]
]

{ #category : #private }
BlImageLoadValuable >> getNewForm [
	"Retrieve the form from the file with an extent the same size or larger than the receiver"

	^BlLocalImageCache current fileAt: file size: self extent max

]

{ #category : #initialization }
BlImageLoadValuable >> initializeFile: aFileReference element: aBlElement [

	self initialize.
	file := aFileReference asFileReference.
	element := aBlElement
]

{ #category : #private }
BlImageLoadValuable >> updateElement [
	"Update the receiver's element's form"

	"1.5 seconds wait."
	element form: self form.
	^form
]
