Extension { #name : #TKTLocalProcessTaskRunner }

{ #category : #'*GToolkit-Images' }
TKTLocalProcessTaskRunner >> schedule: aTask maxPoolSize: aNumber [
	"Schedule the supplied task.
	Since tasks are executed in the active process ignore maxPoolSize"

	^self schedule: aTask
]
