Class {
	#name : #BlVariableSizeWorkerPool,
	#superclass : #TKTCommonQueueWorkerPool,
	#classInstVars : [
		'workerPools'
	],
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #'class initialization' }
BlVariableSizeWorkerPool class >> initialize [ 
	<script>

	self stopAll.
	workerPools := Dictionary new.

]

{ #category : #scheduling }
BlVariableSizeWorkerPool class >> schedule: aValuable maxPoolSize: maxPoolSize [
	"Schedule the supplied valuable with maxPoolSize worker pools"

	^self subclassResponsibility 

]

{ #category : #managing }
BlVariableSizeWorkerPool class >> stopAll [
	<script>
	"Stop the all worker pools and remove the reference to it"

	| keys |

	workerPools ifNil: [ ^self ].
	keys := workerPools keys.
	keys do: [ :key |
		(workerPools at: key) stop.
		workerPools removeKey: key ].

]

{ #category : #accessing }
BlVariableSizeWorkerPool class >> withPoolSize: maxPoolSize [
	"Answer an instance of the receiver with the supplied maximum pool size"

	^workerPools at: maxPoolSize ifAbsentPut: [ 
		self new
			poolMaxSize: maxPoolSize;
			start;
			yourself ]
]

{ #category : #accessing }
BlVariableSizeWorkerPool class >> workerPools [

	^workerPools
]
