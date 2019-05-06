Class {
	#name : #BlAsyncImageElementValuable,
	#superclass : #BlAsyncElementValuable,
	#instVars : [
		'form'
	],
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #acccessing }
BlAsyncImageElementValuable >> form [ 
	"Answer the form from the cache"

	^form ifNil: [ form := self getNewForm ]
]

{ #category : #private }
BlAsyncImageElementValuable >> getNewForm [
	"Retrieve the form with an extent the same size or larger than the receiver"

	^self subclassResponsibility 
]

{ #category : #private }
BlAsyncImageElementValuable >> updateElement [
	"Update the receiver's element's form"

	"1.5 seconds wait."
	element form: self form.
	^form
]
