"
BlAsyncImageElementValuable is an abstract class that adds general functionality for loading images asynchronously and updating the element.

${method:name=BlAsyncImageElementValuable>>#getNewEntry}$ should be overridden by subclases to do the actual work of loading the image.

Subclasses are also responsible for creating instance creation methods with the appropriate information.

!!Internal Representation and Key Implementation Points.
!!!Instance Variables
	entry:		<BlImageCacheEntry> The cache 

!!Implementation Points
"
Class {
	#name : #BlAsyncImageElementValuable,
	#superclass : #BlAsyncElementValuable,
	#instVars : [
		'entry'
	],
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #acccessing }
BlAsyncImageElementValuable >> entry [ 
	"Answer the entry from the cache"

	^entry ifNil: [ entry := self getNewEntry ]
]

{ #category : #acccessing }
BlAsyncImageElementValuable >> form [ 
	"Answer the form from the cache"

	^self entry form
]

{ #category : #private }
BlAsyncImageElementValuable >> getNewEntry [
	"Retrieve the entry with an extent the same size or larger than the receiver"

	^self subclassResponsibility 
]

{ #category : #private }
BlAsyncImageElementValuable >> updateElement [
	"Update the receiver's element's form"

	"1.5 seconds wait."
	element entry: self entry.
	^entry
]
