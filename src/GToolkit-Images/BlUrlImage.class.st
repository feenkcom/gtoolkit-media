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

{ #category : #accessing }
BlUrlImage >> file: aFileReference [
	"Load the supplied file in the background processor (which will update the receiver when done"

	file := aFileReference asFileReference.
	GtImageQueueWorkerPool current schedule:
		(BlImageLoadValuable file: file element: self).



]

{ #category : #initialization }
BlUrlImage >> initialize [ 

	super initialize.
	self background: Color gray.
]
