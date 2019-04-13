Extension { #name : #ImageReadWriter }

{ #category : #'*GToolkit-Images' }
ImageReadWriter class >> gtFormFromBuffer: aByteArray [
	<return: #Form>

	| stream readerClass form |

	stream := aByteArray readStream.
	form := [
		readerClass := self readerClassFromStream: stream.
		readerClass gtFromBuffer: aByteArray ]
			ensure: [ stream close ].
	^ form

]

{ #category : #'*GToolkit-Images' }
ImageReadWriter class >> gtFromBuffer: aByteArray [

	^(self new on: aByteArray readStream) nextImage
]
