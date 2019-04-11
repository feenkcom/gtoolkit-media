"
GtImageLoadValuable is responsible for loading a single image from disk or the network.

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
	#name : #GtImageLoadValuable,
	#superclass : #Object,
	#instVars : [
		'file',
		'form',
		'width',
		'height',
		'displayWidth',
		'displayHeight'
	],
	#category : #'GToolkit-Images-Model'
}

{ #category : #'instance creation' }
GtImageLoadValuable class >> file: aFileReference displayWidth: widthInteger height: heightInteger [

	^self new initializeFile: aFileReference displayWidth: widthInteger height: heightInteger
]

{ #category : #converting }
GtImageLoadValuable >> asTask [ 

	^TKTTask valuable: self
]

{ #category : #accessing }
GtImageLoadValuable >> form [ 
	"Answer the form from the receiver's file scaled to displayWidth and displayHeight (if specified)"

	^form ifNil: [ form := self getForm ]
]

{ #category : #private }
GtImageLoadValuable >> getForm [
	"Retrieve the image from the file and scale if necessary"

	| newForm |

	newForm := ImageReadWriter gtFormFromFileReference: file.
	(displayWidth notNil and: [displayHeight notNil])
		ifTrue: [ newForm := newForm scaledToSize: displayWidth @ displayHeight ].
	^newForm
]

{ #category : #initialization }
GtImageLoadValuable >> initializeFile: aFileReference displayWidth: widthInteger height: heightInteger [

	self initialize.
	file := aFileReference asFileReference.
	displayWidth := widthInteger.
	displayHeight := heightInteger
]

{ #category : #evaluating }
GtImageLoadValuable >> value [

	^self form
]
