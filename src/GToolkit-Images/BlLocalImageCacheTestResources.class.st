Class {
	#name : #BlLocalImageCacheTestResources,
	#superclass : #TestResource,
	#instVars : [
		'cacheRoot',
		'fileRoot',
		'cache'
	],
	#category : #'GToolkit-Images-Tests'
}

{ #category : #accessing }
BlLocalImageCacheTestResources >> cache [
	^ cache
]

{ #category : #accessing }
BlLocalImageCacheTestResources >> cacheRoot [
	^ cacheRoot
]

{ #category : #running }
BlLocalImageCacheTestResources >> setUp [ 

	| root |

	super setUp.
	cacheRoot := FileReference newTempFilePrefix: 'Gtoolkit-Images-' suffix: '-tests'.
	cache := BlLocalImageCache new.
	cache imageSizes: #(200 400 800).
	cache cacheRoot: cacheRoot.
]

{ #category : #running }
BlLocalImageCacheTestResources >> tearDown [ 

	cacheRoot ensureDeleteAll.
	super tearDown
]

{ #category : #accessing }
BlLocalImageCacheTestResources >> testForm [
	"Create a form that can be used to test the cache"

	| form canvas |

	form := Form extent: 400@300.
	canvas := FormCanvas on: form.
	canvas
		drawString: Date today printString, ' ', Time now print24
		at: 10@150
		font: (LogicalFont familyName: 'Bitmap DejaVu Sans' pointSize: 100)
		color: Color black.
	^form
]

{ #category : #accessing }
BlLocalImageCacheTestResources >> testForm2000 [
	"Create a form 2000x1500 that can be used to test the cache"

	| form canvas |

	form := Form extent: 400@300.
	canvas := FormCanvas on: form.
	canvas
		drawString: Date today printString, ' ', Time now print24
		at: 10@150
		font: (LogicalFont familyName: 'Bitmap DejaVu Sans' pointSize: 100)
		color: Color black.
	^form scaledToSize: 2000@1500
]
