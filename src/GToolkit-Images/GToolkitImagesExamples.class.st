Class {
	#name : #GToolkitImagesExamples,
	#superclass : #Object,
	#category : #'GToolkit-Images-Examples'
}

{ #category : #examples }
GToolkitImagesExamples >> gridElementForDirectory: aFileReference [
	"Answer an element that displays the images in aFileReference in a grid"

	| gridElement scrollPane jpgs previewSize children |

	gridElement := BlElement new.
	gridElement layout: (BlGridLayout new columnCount: 2; cellSpacing: 2).
	gridElement constraintsDo: [ :c | 
		c horizontal fitContent.
		c vertical fitContent ].

	jpgs := aFileReference asFileReference children sorted
		select: [ :each | each extension asLowercase = 'jpg' ].
	previewSize := 200@200.
	children :=  jpgs collect: [ :file |
			BlUrlImage new 
				size: previewSize;
				file: file;
				yourself ].

	gridElement addChildren: children.
	scrollPane := BlScrollableElement new.
	scrollPane constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent ].
	scrollPane addChild: gridElement.

	^scrollPane
]

{ #category : #examples }
GToolkitImagesExamples >> gridSpaceForDirectory: aFileReference [
	"Open a BlSpace that displays the images in aFileReference in a grid"

	| scrollPane space |

	scrollPane := self gridElementForDirectory: aFileReference.

	space := BlSpace new.
	space root addChild: scrollPane.
	space title: 'Gallery on: ', aFileReference asFileReference pathString.
	space show.
	^space
]

{ #category : #examples }
GToolkitImagesExamples >> gtBlUrlImageElement [
	<gtExample>

	| file element |

	file := GtIcebergUtility documentAtPath: 'feenkcom/gtoolkit-inspector/doc/gt.png' asFileReference path.
	element := BlUrlImage file: file.
	^element
]

{ #category : #examples }
GToolkitImagesExamples >> gtBlUrlImageSpace [
	<gtExample>

	| space |

	space := BlSpace new.
	space root addChild: self gtBlUrlImageElement.
	space title: 'GT Logo' translated.
	space show.
	^space
]

{ #category : #examples }
GToolkitImagesExamples >> imageInSpace: aFileReference [

	| element space |

	element := BlUrlImage new.
	element file: aFileReference asFileReference.
	element constraintsDo: [ :c | 
		c horizontal matchParent.
		c vertical matchParent ].

	space := BlSpace new.
	space root addChild: element.
	space title: aFileReference asFileReference basename.
	space show.
	^space
]
