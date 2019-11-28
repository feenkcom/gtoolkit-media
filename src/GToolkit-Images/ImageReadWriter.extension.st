Extension { #name : #ImageReadWriter }

{ #category : #'*GToolkit-Images' }
ImageReadWriter class >> formFromFileNamed: fileName sizeFor: targetSize [
	"Answer a Form of the image stored in fileName scaled to targetSize or a bit larger"

	| fileReference form |

	fileReference := fileName asFileReference.
	(GtJPEGReader typicalFileExtensions includes: fileReference extension asLowercase) ifTrue: [ 
		[ ^GtJPEGReader formFromFileNamed: fileName sizeFor: targetSize ]
			on: Error 
			do: [ :ex | nil ] ].

	form := self gtFormFromFileReference: fileReference.
	(targetSize isNotNil and: [ targetSize max < form extent max ]) ifTrue:
		[ form := form scaledToSize: targetSize ].
	^form
		
]
