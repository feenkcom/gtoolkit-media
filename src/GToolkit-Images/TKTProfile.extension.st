Extension { #name : #TKTProfile }

{ #category : #'*GToolkit-Images' }
TKTProfile class >> gtDevelopment [
	<profile: #gtDevelopment>
	^ TKTProfile
		on:
			{(#debugging -> true).
			(#runner -> GtImageQueueWorkerPool createDefault).
			(#poolWorkerProcess -> TKTDebuggWorkerProcess).
			(#process -> TKTRawProcess).
			(#errorHandler -> TKTDebuggerExceptionHandler).
			(#processProvider -> GtTKTBackgroundProcessProvider new).
			(#serviceManager -> TKTServiceManager new)} asDictionary
]
