# flutter_transmission

Flutter package to talk to a Transmission torrent instance, for a pure dart package please check [transmission](https://github.com/jaumard/transmission)

## Setup

To have this package working you need to setup a TransmissionScope like this:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TransmissionScope(
      baseUrl: 'http://192.168.1.35:9091/transmission/rpc',
      child: MaterialApp(
        ...
      ),
    );
  }
}
```

Here you just pass the base url of the remote transmission instance, after that you can start adding UI to manage Transmission.

### Easy usage

The most easy usage is to launch a full screen, to do so use `TransmissionScreen` like this:

```dart
Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransmissionScreen()));
```  

### Custom usage

If the easy usage doesn't fit your need you can use dedicated widgets to build your own interface, here is a list of widget available:

| Widget | Usage |
| --- | --- |
| TransmissionScreen | full screen to see and interact with transmission data |
| TorrentList | List of the transmission's torrents |
| TorrentListItem | Torrent representation |
| TransmissionSettings | Widget to manage transmission's settings |
| TransmissionSettingsDialog | TransmissionSettings but in a dialog |
| TransmissionGlobalActions | Toolbar to stop/start all torrents at once |
| TransmissionStatusBar | Status bar to toggle alternative speed and access transmission's settings |
| RealTimeActionButton | Button to toggle real time pooling data from transmission |
| AddTorrentActionButton | Button to add a torrent to transmission instance |