Class {
	#name : #BaselineOfGToolkitIPC,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkitIPC
}

{ #category : #baselines }
BaselineOfGToolkitIPC >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec configuration: 'OSProcess' with: [ 
			spec
				repository: 'http://www.squeaksource.com/MetacelloRepository' ].

		spec baseline: 'TelePharo' with: [
			spec
				repository: 'github://pharo-ide/TelePharo';
				loads: #(Client Server) ].		

		spec package: 'GToolkit-IPC'.
		
		spec group: 'default'
			with: #(OSProcess TelePharo 'GToolkit-IPC') ]

]
