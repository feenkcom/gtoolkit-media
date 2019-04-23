Class {
	#name : #BlTKTBackgroundProcessProvider,
	#superclass : #TKTTaskItProcessProvider,
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #'instance-creation' }
BlTKTBackgroundProcessProvider >> createProcessDoing: aValuable named: aName [
	^ (TKTProcess send: #value to: aValuable)
		annotate: #task with: aValuable;
		name: aName;
		priority: Processor userBackgroundPriority;
		run
]
