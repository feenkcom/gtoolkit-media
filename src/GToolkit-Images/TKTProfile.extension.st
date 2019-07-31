Extension { #name : #TKTProfile }

{ #category : #'*GToolkit-Images' }
TKTProfile class >> gtDevelopment [
	<profile: #gtDevelopment>
	^ TKTProfile
		on:
			{(#debugging -> true).
			(#runner -> BlTktWorkerProvider highUICPUBoundPool).
			(#poolWorkerProcess -> TKTDebuggWorkerProcess).
			(#process -> TKTRawProcess).
			(#errorHandler -> TKTDebuggerExceptionHandler).
			(#processProvider -> BlTKTBackgroundProcessProvider new).
			(#serviceManager -> TKTServiceManager new)} asDictionary
]
