Extension { #name : #AtomicQueueItem }

{ #category : #'*GToolkit-Images' }
AtomicQueueItem >> isZombie [
	"Answer a boolean indicating that the receiver doesn't have a real object"

	^object class = self class
]

{ #category : #'*GToolkit-Images' }
AtomicQueueItem >> printOn: aStream [

	aStream << 'an Item('.
	self isZombie ifTrue: 
		[ aStream << 'Zombie' ]
	ifFalse:
		[ object printOn: aStream ].
	"aStream 
		<< ', '."
	self isCircular ifTrue: 
		[ aStream << ', Circular' ].
	aStream
		"print: self identityHash;"
		<< ')'
]
