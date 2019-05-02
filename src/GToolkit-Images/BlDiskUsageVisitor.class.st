Class {
	#name : #BlDiskUsageVisitor,
	#superclass : #FileSystemVisitor,
	#instVars : [
		'total',
		'entryCount'
	],
	#category : #'GToolkit-Images-Cache'
}

{ #category : #'instance creation' }
BlDiskUsageVisitor class >> on: aFileReference [

	^self new 
		on: aFileReference;
		yourself
]

{ #category : #accessing }
BlDiskUsageVisitor >> entryCount [
	^ entryCount
]

{ #category : #initialization }
BlDiskUsageVisitor >> initialize [ 

	super initialize.
	total := 0.
	entryCount := 0.
]

{ #category : #'instance creation' }
BlDiskUsageVisitor >> on: aFileReference [

	(PreorderGuide for: self) show: aFileReference
]

{ #category : #accessing }
BlDiskUsageVisitor >> total [
	^ total
]

{ #category : #visiting }
BlDiskUsageVisitor >> visitFile: anEntry [

	total := total + anEntry size.
	entryCount := entryCount + 1.
]
