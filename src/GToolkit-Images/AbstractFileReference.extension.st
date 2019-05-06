Extension { #name : #AbstractFileReference }

{ #category : #'*GToolkit-Images' }
AbstractFileReference >> gtBinaryContents [
	self binaryReadStreamDo: [ :stream |
		^ stream contents ]
]
