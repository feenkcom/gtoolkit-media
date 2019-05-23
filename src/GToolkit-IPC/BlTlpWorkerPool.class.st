"
BlTlpWorkerPool provides OS multi-threaded computation by forking a number of pharo images and communicating with them using TelePharo.

Tasks assigned to the workers in a simple round-robin fashion.

!!Public API and Key Messages

- current	Access the default instance
- maxPoolSize:	The maximum number of workers to spawn.
- workerEvaluate:	Pass a ${class:name=BlockClosure}$ to be evaluated by a worker

[[[
BlTlpWorkerPool current workerEvaluate: [ 4 + 3 ].
]]]

!!Internal Representation and Key Implementation Points.

!!!Instance Variables
	lastAllocated:		<SmallInteger>
	monitor:		<Monitor>
	workers:		<Array of: ${class:BlTlpWorker}$ >


Implementation Points
"
Class {
	#name : #BlTlpWorkerPool,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'workers',
		'lastAllocated'
	],
	#classVars : [
		'Current'
	],
	#category : #'GToolkit-IPC'
}

{ #category : #accessing }
BlTlpWorkerPool class >> current [ 

	^Current ifNil: [ Current := self maxPoolSize: 2 ]
]

{ #category : #'class initialization' }
BlTlpWorkerPool class >> initialize [ 

	SessionManager default 
		registerUserClassNamed: self name
]

{ #category : #accessing }
BlTlpWorkerPool class >> maxPoolSize: anInteger [
	"Answer a new pool with anInteger maximum server processes"

	^self new 
		maxPoolSize: anInteger;
		yourself
]

{ #category : #'system startup' }
BlTlpWorkerPool class >> shutDown: quitting [

	self shutdown
]

{ #category : #managing }
BlTlpWorkerPool class >> shutdown [
	<script>

	| old |
	Current ifNil: [ ^self ].
	old := Current.
	Current := nil.
	old shutdown.

]

{ #category : #initialization }
BlTlpWorkerPool >> initialize [ 

	super initialize.
	monitor := Monitor new.
	workers := Array new: 1.
	lastAllocated := 0.
]

{ #category : #accessing }
BlTlpWorkerPool >> maxPoolSize: anInteger [

	self shutdown.
	workers := Array new: anInteger
]

{ #category : #default }
BlTlpWorkerPool >> shutdown [
	"Shutdown everything.  Any in progress operations will fail."
	
	monitor critical: [ 
		workers
			select: [ :each | each isNotNil ]
			thenDo: [ :each | each stop ].
		workers := Array new: workers size ]

]

{ #category : #accessing }
BlTlpWorkerPool >> worker [
	"Answer an available instance"

	| worker |

	monitor critical: 
		[ lastAllocated := lastAllocated + 1.
		lastAllocated > workers size ifTrue: [ lastAllocated := 1 ].
		worker := workers at: lastAllocated.
		worker ifNil: [ 
			worker := workers at: lastAllocated put: BlTlpWorker new.
			worker start ] ].
	^worker
]

{ #category : #scheduling }
BlTlpWorkerPool >> workerEvaluate: aBlock [

	^self worker evaluate: aBlock
]
