Class {
	#name : #BaselineOfGToolkitIPC,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkitIPC
}

{ #category : #baselines }
BaselineOfGToolkitIPC >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec baseline: 'OSProcess' with: [ 
			spec
				repository: 'github://dtlewis290/OSProcess-Tonel/src' ].

		spec baseline: 'TelePharo' with: [
			spec
				repository: 'github://pharo-ide/TelePharo';
				loads: #(Client Server) ].		

		spec package: 'GToolkit-IPC'.
		
		spec group: 'default'
			with: #(OSProcess TelePharo 'GToolkit-IPC') ]

]
