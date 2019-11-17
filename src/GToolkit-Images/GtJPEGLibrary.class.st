Class {
	#name : #GtJPEGLibrary,
	#superclass : #FFILibrary,
	#category : #'GToolkit-Images-JPEG'
}

{ #category : #'accessing platform' }
GtJPEGLibrary >> detectLibrary: aFileName [
	^ ({ Smalltalk imageDirectory . Smalltalk vmDirectory . FileSystem workingDirectory }
		collect: [ :aPath | aPath asFileReference / aFileName ])
			detect: #exists
			ifFound: #fullName
			ifNone: [ aFileName ]
]

{ #category : #'accessing platform' }
GtJPEGLibrary >> macLibraryName [

	^self detectLibrary: 'libGtJPEG.dylib'
]

{ #category : #'accessing platform' }
GtJPEGLibrary >> unix64LibraryName [

	^self detectLibrary: 'libGtJPEG.so'
]

{ #category : #'accessing platform' }
GtJPEGLibrary >> win32LibraryName [

	^self detectLibrary: 'libGtJPEG.dll'
]
