Class {
	#name : #BlAsyncImageElementValuable,
	#superclass : #BlAsyncElementValuable,
	#instVars : [
		'form',
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
