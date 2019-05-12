"
BlFileImageLoadValuable is responsible for loading a single image from disk by passing the request on to ${method:name=BlLocalImageCache class>>#current}$.  

"
Class {
	#name : #BlFileImageLoadValuable,
	#superclass : #BlAsyncImageElementValuable,
	#instVars : [
		'file'
	],
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #'instance creation' }
BlFileImageLoadValuable class >> file: aFileReference element: aBlElement [

	^self new initializeFile: aFileReference element: aBlElement
]

{ #category : #private }
BlFileImageLoadValuable >> getNewEntry [
	"Retrieve the form from the file with an extent the same size or larger than the receiver"

	^BlLocalImageCache current fileAt: file size: self extent max

]

{ #category : #initialization }
BlFileImageLoadValuable >> initializeFile: aFileReference element: aBlElement [

	self initialize.
	file := aFileReference asFileReference.
	element := aBlElement
]
