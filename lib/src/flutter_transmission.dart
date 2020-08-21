import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_transmission/src/stores/transmission_store.dart';
import 'package:provider/provider.dart';
import 'package:transmission/transmission.dart';

/// A [TransmissionScope] that allow setting up ground work to talk to a transmission instance
class TransmissionScope extends StatelessWidget {
  final String baseUrl;
  final bool enableLog;
  final Widget child;

  /// [baseUrl] string URL of the transmission remote instance, default to http://localhost:9091/transmission/rpc
  const TransmissionScope({Key key, this.baseUrl, this.child, this.enableLog = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<TransmissionStore>(
      create: (_) => TransmissionStore(baseUrl: baseUrl, enableLog: enableLog),
      dispose: (_, store) => store.dispose(),
      child: child,
    );
  }
}

/// Ready to use full screen for Transmission remote management
class TransmissionScreen extends StatelessWidget {
  final String title;
  final bool enableTopBarButtons;
  final bool enableStatusBar;
  final bool enableRealTimeButton;
  final bool enableAddTorrentButton;
  final bool headless;
  final Color iconActiveColor;
  final List<Widget> actions;

  const TransmissionScreen({
    Key key,
    this.title = 'Transmission',
    this.iconActiveColor = Colors.blueAccent,
    this.enableRealTimeButton = true,
    this.enableAddTorrentButton = true,
    this.enableTopBarButtons = true,
    this.enableStatusBar = true,
    this.headless = false,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headless
          ? null
          : AppBar(
              title: Text(title),
              actions: <Widget>[if (enableRealTimeButton) RealTimeActionButton(), ...actions],
              bottom: enableTopBarButtons ? TransmissionGlobalActions() : null,
            ),
      body: TorrentList(),
      bottomNavigationBar: enableStatusBar
          ? Container(
              child: TransmissionStatusBar(iconActiveColor: iconActiveColor),
              color: Theme.of(context).primaryColor,
            )
          : null,
      floatingActionButton: enableAddTorrentButton
          ? AddTorrentActionButton(
              isFloatingButton: true,
            )
          : null,
    );
  }
}

/// List of torrents of the remote transmission instance
/// each item is a [TorrentListItem]
class TorrentList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<TransmissionStore>(context);
    final refreshKey = useMemoized(() => GlobalKey<RefreshIndicatorState>());

    useEffect(() {
      store.toggleRealTime();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        refreshKey.currentState.show();
      });
      return () {
        //when disposed let's pause the realtime pooling
        if (store.realTimePool) {
          store.toggleRealTime();
        }
      };
    }, const []);

    return Observer(
      builder: (context) {
        final total = store.torrents.value?.length ?? 0;
        return RefreshIndicator(
          key: refreshKey,
          child: Stack(
            children: [
              if (total == 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Currently no torrent in transmission'),
                ),
              ListView.separated(
                itemBuilder: (context, index) {
                  return TorrentListItem(
                    torrent: store.torrents.value[index],
                  );
                },
                itemCount: total,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              ),
            ],
          ),
          onRefresh: () {
            return store.loadTorrents();
          },
        );
      },
    );
  }
}

enum _TorrentAction {
  delete,
  deleteWithData,
  move,
  rename,
  updatePeers,
}

/// Widget that represent a [Torrent] and allow interaction with it
class TorrentListItem extends StatelessWidget {
  final Torrent torrent;

  const TorrentListItem({Key key, this.torrent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var progressColor = torrent.isMetadataDownloaded ? Theme.of(context).backgroundColor : Colors.redAccent;
    var valueColor = torrent.isMetadataDownloaded ? Theme.of(context).accentColor : Colors.red;
    if (torrent.isFinished) {
      progressColor = Colors.green;
      valueColor = Colors.transparent;
    }
    if (torrent.error != 0) {
      progressColor = Colors.grey;
      valueColor = Colors.transparent;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            torrent.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            torrent.isMetadataDownloaded
                ? torrent.prettyCurrentSize + ' on ' + torrent.prettyTotalSize + ' (${torrent.percentDone.toStringAsFixed(1) + '%'})'
                : 'Need metadata',
            style: Theme.of(context).textTheme.caption,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 15,
                    child: LinearProgressIndicator(
                      value: (torrent.isMetadataDownloaded ? torrent.percentDone : torrent.metadataPercentComplete) / 100,
                      backgroundColor: progressColor,
                      valueColor: AlwaysStoppedAnimation<Color>(valueColor),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(torrent.status == 0 ? Icons.refresh : Icons.pause),
                  onPressed: () async {
                    final store = Provider.of<TransmissionStore>(context, listen: false);
                    if (torrent.status == 0) {
                      await store.startTorrent(torrent);
                    } else {
                      await store.stopTorrent(torrent);
                    }
                  },
                ),
                PopupMenuButton<_TorrentAction>(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('Move'),
                        value: _TorrentAction.move,
                      ),
                      PopupMenuItem(
                        child: Text('Rename'),
                        value: _TorrentAction.rename,
                      ),
                      PopupMenuItem(
                        child: Text('Delete'),
                        value: _TorrentAction.delete,
                      ),
                      PopupMenuItem(
                        child: Text('Delete with data'),
                        value: _TorrentAction.delete,
                      ),
                      PopupMenuItem(
                        child: Text('Ask tracker for more peers'),
                        value: _TorrentAction.updatePeers,
                      ),
                    ];
                  },
                  tooltip: 'More actions on torrent',
                  onSelected: (selected) async {
                    final store = Provider.of<TransmissionStore>(context, listen: false);
                    switch (selected) {
                      case _TorrentAction.delete:
                        if (await _showConfirm(context, 'Delete torrent?', 'Are you sure you want to delete this torrent?')) {
                          store.deleteTorrent(torrent, false).catchError((ex) {
                            _showErrors(context);
                          });
                        }
                        break;
                      case _TorrentAction.deleteWithData:
                        if (await _showConfirm(
                            context, 'Delete torrent with local data?', 'Are you sure you want to delete this torrent and all related data?')) {
                          store.deleteTorrent(torrent, false).catchError((ex) {
                            _showErrors(context);
                          });
                        }
                        break;
                      case _TorrentAction.move:
                        _showPrompt(context, 'Move torrent', 'Path', (text) async {
                          try {
                            store.moveTorrent(torrent, text, false);
                            Navigator.of(context).pop();
                          } on TransmissionException catch (ex) {
                            print(ex);
                            _showErrors(context, description: ex.cause.result);
                          } catch (ex) {
                            _showErrors(context);
                          }
                        });
                        break;
                      case _TorrentAction.rename:
                        _showPrompt(context, 'Rename torrent', 'Name', (text) async {
                          try {
                            store.renameTorrent(torrent, text);
                            Navigator.of(context).pop();
                          } on TransmissionException catch (ex) {
                            print(ex);
                            _showErrors(context, description: ex.cause.result);
                          } catch (ex) {
                            _showErrors(context);
                          }
                        });
                        break;
                      case _TorrentAction.updatePeers:
                        try {
                          store.askForMorePeers(torrent);
                        } on TransmissionException catch (ex) {
                          print(ex);
                          _showErrors(context, description: ex.cause.result);
                        } catch (ex) {
                          _showErrors(context);
                        }
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
          _TorrentStatus(
            torrent: torrent,
          ),
        ],
      ),
    );
  }
}

/// [TransmissionSettings] but inside a dialog
class TransmissionSettingsDialog extends StatelessWidget {
  final String title;

  const TransmissionSettingsDialog({Key key, this.title = 'Settings'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500, minWidth: 310),
        child: TransmissionSettings(),
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('CLOSE'),
        ),
      ],
    );
  }
}

/// Widget that represent settings of the remote Transmission instance,
/// you'll be able to change speed limits
class TransmissionSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<TransmissionStore>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Speed limits'),
        Observer(
          builder: (context) {
            final value = store.session[speedLimitUpKey].toString();
            final speedLimitUpEnable = store.session[speedLimitUpEnableKey];
            return Row(
              children: [
                Checkbox(
                    value: speedLimitUpEnable,
                    onChanged: (value) {
                      store.setSession({speedLimitUpEnableKey: value});
                    }),
                Expanded(
                  child: HookBuilder(
                    builder: (context) {
                      final controller = useTextEditingController(text: value, keys: [value]);
                      return TextField(
                        keyboardType: TextInputType.number,
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Upload (Kb/s)',
                        ),
                        enabled: speedLimitUpEnable,
                        onChanged: (changedValue) {
                          final newValue = int.tryParse(changedValue);
                          if (newValue != null && value != changedValue) {
                            store.setSession({speedLimitUpKey: newValue});
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        Observer(
          builder: (context) {
            final value = store.session[speedLimitDownKey].toString();
            final speedLimitDownEnable = store.session[speedLimitDownEnableKey];
            return Row(
              children: [
                Checkbox(
                    value: speedLimitDownEnable,
                    onChanged: (value) {
                      store.setSession({speedLimitDownEnableKey: value});
                    }),
                Expanded(
                  child: HookBuilder(
                    builder: (context) {
                      final controller = useTextEditingController(text: value, keys: [value]);
                      return TextField(
                        controller: controller,
                        enabled: speedLimitDownEnable,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Download (Kb/s)',
                        ),
                        onChanged: (changedValue) {
                          final newValue = int.tryParse(changedValue);
                          if (newValue != null && value != changedValue) {
                            store.setSession({speedLimitDownKey: newValue});
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/turtle.svg',
                package: 'flutter_transmission',
                width: 25,
                height: 25,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text('Alternative speed limits'),
                ),
              ),
            ],
          ),
        ),
        HookBuilder(
          builder: (context) {
            final value = store.session[altSpeedUpKey].toString();
            final controller = useTextEditingController(text: value, keys: [value]);
            return TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Upload (Kb/s)',
              ),
              onChanged: (changedValue) {
                final newValue = int.tryParse(changedValue);
                if (newValue != null && value != changedValue) {
                  store.setSession({altSpeedUpKey: newValue});
                }
              },
              keyboardType: TextInputType.number,
            );
          },
        ),
        HookBuilder(
          builder: (context) {
            final value = store.session[altSpeedDownKey].toString();
            final controller = useTextEditingController(text: value, keys: [value]);

            return TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Download (Kb/s)',
              ),
              onChanged: (changedValue) {
                final newValue = int.tryParse(changedValue);
                if (newValue != null && value != changedValue) {
                  store.setSession({altSpeedDownKey: newValue});
                }
              },
              keyboardType: TextInputType.number,
            );
          },
        ),
      ],
    );
  }
}

/// Action bar that allow to stop or start all torrents at once
class TransmissionGlobalActions extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.play_circle_outline),
          onPressed: () {
            final store = Provider.of<TransmissionStore>(context, listen: false);
            store.startAllTorrent();
          },
          tooltip: 'Start all torrents',
        ),
        IconButton(
          icon: Icon(Icons.pause_circle_outline),
          onPressed: () {
            final store = Provider.of<TransmissionStore>(context, listen: false);
            store.stopAllTorrent();
          },
          tooltip: 'Pause all torrents',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kMinInteractiveDimension);
}

/// Status bar that allow to enable alternate speed or access transmission settings
class TransmissionStatusBar extends StatelessWidget {
  final Color iconActiveColor;

  const TransmissionStatusBar({Key key, this.iconActiveColor = Colors.blueAccent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<TransmissionStore>(context);
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () async {
                  var reEnableRealTime = false;
                  if (store.realTimePool) {
                    reEnableRealTime = true;
                    store.toggleRealTime();
                  }
                  await showDialog(context: context, builder: (context) => TransmissionSettingsDialog());
                  if (reEnableRealTime) {
                    store.toggleRealTime();
                  }
                }),
            IconButton(
              icon: Observer(
                builder: (context) => SvgPicture.asset(
                  'assets/images/turtle.svg',
                  package: 'flutter_transmission',
                  color: store.altSpeedEnabled ? iconActiveColor : Theme.of(context).iconTheme.color,
                ),
              ),
              onPressed: () {
                store.setSession({altSpeedKey: !store.altSpeedEnabled});
              },
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Observer(builder: (context) => Text('${store.torrents.value?.length ?? 0} transfers')),
            ),
          ],
        ),
      ),
    );
  }
}

class _TorrentStatus extends StatelessWidget {
  final Torrent torrent;

  const _TorrentStatus({Key key, this.torrent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (torrent.error != 0) {
      return Text(
        torrent.errorString.toString(),
        style: TextStyle(color: Theme.of(context).errorColor),
      );
    }
    switch (torrent.status) {
      case 4:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Text('${torrent.statusDescription} ↓ ' +
                    torrent.prettyRateDownload +
                    ' | ↑ ' +
                    torrent.prettyRateUpload +
                    ' from ${torrent.peersSendingToUs}/${torrent.peersConnected} peers')),
          ],
        );
    }
    return Text(torrent.statusDescription);
  }
}

/// Button to enable/disable real time pooling of torrent's data
class RealTimeActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<TransmissionStore>(context);
    return Observer(
      builder: (context) => IconButton(
        tooltip: 'Toggle real time information',
        icon: Icon(store.realTimePool ? Icons.pause_circle_outline : Icons.play_circle_outline),
        onPressed: () {
          store.toggleRealTime();
        },
      ),
    );
  }
}

/// Button to give possibility to add a torrent by giving the URL of it
/// It will open a dialog asking for the URL of the torrent
/// set [isFloatingButton] to true if you want to have floating button look like, default to false
class AddTorrentActionButton extends StatelessWidget {
  final bool isFloatingButton;

  /// Button to give possibility to add a torrent by giving the URL of it
  /// It will open a dialog asking for the URL of the torrent
  /// set [isFloatingButton] to true if you want to have floating button look like, default to false
  const AddTorrentActionButton({Key key, this.isFloatingButton = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isFloatingButton) {
      return FloatingActionButton(
        onPressed: () => _addTorrent(context),
        child: Icon(Icons.add),
      );
    }
    return IconButton(
      tooltip: 'Add new torrent',
      icon: Icon(Icons.add),
      onPressed: () => _addTorrent(context),
    );
  }

  void _addTorrent(BuildContext context) async {
    final store = Provider.of<TransmissionStore>(context, listen: false);
    _showPrompt(context, 'Add new torrent', 'URL', (text) async {
      try {
        await store.addTorrent(text);
        Navigator.of(context).pop();
      } on AddTorrentException catch (ex) {
        _showErrors(context, description: ex.cause.result);
      } catch (ex) {
        _showErrors(context);
      }
    });
  }
}

Future<bool> _showConfirm(BuildContext context, String title, String description) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: <Widget>[
            FlatButton(onPressed: () => Navigator.of(context).pop(true), child: Text(MaterialLocalizations.of(context).okButtonLabel)),
            FlatButton(onPressed: () => Navigator.of(context).pop(false), child: Text(MaterialLocalizations.of(context).cancelButtonLabel)),
          ],
        ),
      ) ??
      false;
}

Future<bool> _showPrompt(BuildContext context, String title, String label, void Function(String text) onOk) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return HookBuilder(
        builder: (context) {
          final controller = useTextEditingController();
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: label,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  onOk(controller.text);
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showErrors(
  BuildContext context, {
  String title = 'Ooops',
  String description = 'Sorry an error as occurred',
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        FlatButton(onPressed: () => Navigator.of(context).pop(), child: Text(MaterialLocalizations.of(context).okButtonLabel)),
      ],
    ),
  );
}
