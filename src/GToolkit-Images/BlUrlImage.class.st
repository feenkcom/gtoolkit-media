Class {
	#name : #BlUrlImage,
	#superclass : #BlElement,
	#instVars : [
		'url',
		'file',
		'form'
	],
	#category : #'GToolkit-Images-Model'
}

{ #category : #accessing }
BlUrlImage class >> file: aFileReference [

	^self new file: aFileReference
]

{ #category : #layout }
BlUrlImage >> applyLayoutIn: aBlBounds [

	
	super applyLayoutIn: aBlBounds.
	self queueImageLoad
]

{ #category : #accessing }
BlUrlImage >> file [ 

	^file
]

{ #category : #accessing }
BlUrlImage >> file: aFileReference [
	"Load the supplied file in the background processor (which will update the receiver when done"

	file := aFileReference asFileReference.
	self queueImageLoad

]

{ #category : #accessing }
BlUrlImage >> form [
	^ form
]

{ #category : #accessing }
BlUrlImage >> form: anObject [
	form := anObject
]

{ #category : #initialization }
BlUrlImage >> initialize [ 

	super initialize.
	self background: Color gray.
]

{ #category : #accessing }
BlUrlImage >> queueImageLoad [
	"Queue the receivers file to be loaded and the receiver updated."

	TKTConfiguration processProvider: GtTKTBackgroundProcessProvider new during: [ 
		GtImageQueueWorkerPool current schedule:
			(BlImageLoadValuable file: file element: self) ].

]
