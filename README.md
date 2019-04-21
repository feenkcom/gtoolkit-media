# GToolkit Media
This is a project for offering advanced support for handling media artifacts, such as images, within [Glamorous Toolkit](https://github.com/feenkcom/gtoolkit).

## How to load

```
EpMonitor current disable.
[ 
  Metacello new
    baseline: 'GToolkitMedia';
    repository: 'github://feenkcom/gtoolkit-media/src';
    load
] ensure: [ EpMonitor current enable ].
```
