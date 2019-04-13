Class {
	#name : #GtTKTBackgroundProcessProvider,
	#superclass : #TKTTaskItProcessProvider,
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #'instance-creation' }
GtTKTBackgroundProcessProvider >> createProcessDoing: aValuable named: aName [
	^ (TKTProcess send: #value to: aValuable)
		annotate: #task with: aValuable;
		name: aName;
		priority: Processor userBackgroundPriority;
		run
]
