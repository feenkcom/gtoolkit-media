Class {
	#name : #BaselineOfGToolkitMedia,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkitMedia
}

{ #category : #baseline }
BaselineOfGToolkitMedia >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec configuration: 'OSProcess' with: [ 
			spec
				repository: 'http://www.squeaksource.com/MetacelloRepository' ].

		spec baseline: 'TelePharo' with: [
			spec
				repository: 'github://pharo-ide/TelePharo';
				loads: #(Client Server) ].		

		spec package: 'GToolkit-Images'.
		
		spec group: 'default'
			with: #(OSProcess TelePharo 'GToolkit-Images') ]

]
