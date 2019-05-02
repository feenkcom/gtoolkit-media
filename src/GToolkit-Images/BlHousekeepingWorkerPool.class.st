"
BlHousekeepingWorkerPool is a TKTCommonQueueWorkerPool that runs the workers at userBackgroundPriority and limits the number of concurrent tasks so that the UI thread is still responsive.


Public API and Key Messages

The public API and key messages are the same as for TKTCommonWorkerPool.

"
Class {
	#name : #BlHousekeepingWorkerPool,
	#superclass : #TKTCommonQueueWorkerPool,
	#classVars : [
		'Current'
	],
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #accessing }
BlHousekeepingWorkerPool class >> current [

	^Current ifNil: [ 
		Current := self new
			poolMaxSize: 1;
			start;
			yourself ]
]

{ #category : #scheduling }
BlHousekeepingWorkerPool class >> schedule: aValuable [
	"Schedule the supplied valuable in the current worker pool"

	TKTConfiguration processProvider: BlTKTHousekeepingProcessProvider new during: [ 
		self current schedule: aValuable ].

]

{ #category : #managing }
BlHousekeepingWorkerPool class >> stopCurrent [
	<script>
	"Stop the default worker pool and remove the reference to it"

	Current ifNil: [ ^self ].
	Current stop.
	Current := nil.
]

{ #category : #initialization }
BlHousekeepingWorkerPool >> initialize [ 

	super initialize.
	self name: 'BlHousekeepingWorker-', self identityHash asString.
]

{ #category : #printing }
BlHousekeepingWorkerPool >> printOn: aStream [
	| freeWorkers | 
	freeWorkers := workers select: #isFree.
	aStream
		nextPutAll: self class name;
		nextPutAll: '(';
		nextPutAll: 'name:';
		nextPutAll: name;
		nextPutAll: 'poolMaxSize: ';
		print: poolMaxSize;
		nextPutAll: '; busyWorkers: ';
		print: workers size - freeWorkers size;
		nextPutAll: '; freeWorkers: ';
		print: freeWorkers size;
		nextPutAll: ')'
]
