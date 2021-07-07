import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:transmission/transmission.dart';

part 'transmission_store.g.dart';

class TransmissionStore = _TransmissionStore with _$TransmissionStore;

const altSpeedKey = 'alt-speed-enabled';
const altSpeedDownKey = 'alt-speed-down';
const altSpeedUpKey = 'alt-speed-up';

const speedLimitDownKey = 'speed-limit-down';
const speedLimitDownEnableKey = 'speed-limit-down-enabled';
const speedLimitUpEnableKey = 'speed-limit-up-enabled';
const speedLimitUpKey = 'speed-limit-up';

abstract class _TransmissionStore with Store {
  final Transmission _transmission;

  static ObservableFuture<ObservableList<Torrent>> emptyResponse =
      ObservableFuture.value(ObservableList.of([]));

  _TransmissionStore(
      {String? baseUrl, String? proxyUrl, bool enableLog = false})
      : _transmission = Transmission(
            baseUrl: baseUrl, proxyUrl: proxyUrl, enableLog: enableLog);

  @observable
  ObservableFuture<ObservableList<Torrent>> torrents = emptyResponse;

  @observable
  ObservableMap<String, dynamic> session = ObservableMap.of({});

  @observable
  DioError? refreshTorrentError;

  @observable
  bool realTimePool = false;

  @observable
  bool altSpeedEnabled = false;

  Timer _realTimeTimer = Timer(Duration(), () {});

  @action
  Future<void> toggleRealTime() async {
    realTimePool = !realTimePool;
    if (realTimePool) {
      _refreshTorrents();
    } else {
      _realTimeTimer.cancel();
    }
  }

  @action
  Future<void> _refreshTorrents() async {
    try {
      final activeTorrents = await _transmission.getRecentlyActive();
      await getSession();
      if (activeTorrents.removed!.isNotEmpty) {
        torrents.value!.removeWhere(
            (element) => activeTorrents.removed!.contains(element.id));
      }

      if (activeTorrents.torrents!.isEmpty) {
        _realTimeTimer.cancel();
        if (realTimePool) {
          _realTimeTimer = Timer(
              Duration(
                seconds: 5,
              ), () {
            _refreshTorrents();
          });
        }
      } else {
        activeTorrents.torrents!.forEach((element) {
          var found = false;
          for (var i = 0; i < torrents.value!.length; i++) {
            final torrent = torrents.value![i];
            if (torrent.id == element.id) {
              torrents.value![i] = element;
              found = true;
            }
          }
          if (!found) {
            torrents.value!.add(element);
          }
        });
        if (realTimePool) {
          _realTimeTimer = Timer(
              Duration(
                seconds: 1,
              ), () {
            _refreshTorrents();
          });
        }
      }
    } on DioError catch (err) {
      refreshTorrentError = err;
    } catch (err) {
      print(err);
      refreshTorrentError = DioError(requestOptions: RequestOptions(path: ''));
    }
  }

  @action
  Future<void> loadTorrents() async {
    final future = _loadTorrents();
    await getSession();
    torrents = ObservableFuture(future);
    await future;
  }

  @action
  Future<void> startAllTorrent() async {
    await _transmission.startTorrents(torrents.value!
        .map((element) => element.id)
        .toList(growable: false) as List<int>);
  }

  @action
  Future<void> getSession() async {
    session = ObservableMap.of(
        await _transmission.getSession());
    altSpeedEnabled = session[altSpeedKey] ?? false;
  }

  @action
  Future<void> setSession(Map<String, dynamic> data) async {
    await _transmission.setSession(data);
    session..addAll(data);
    altSpeedEnabled = session[altSpeedKey] ?? false;
  }

  @action
  Future<void> askForMorePeers(Torrent torrent) async {
    await _transmission.askForMorePeers([torrent.id!]);
  }

  @action
  Future<void> stopAllTorrent() async {
    await _transmission.stopTorrents(torrents.value!
        .map((element) => element.id)
        .toList(growable: false) as List<int>);
  }

  @action
  Future<void> startTorrent(Torrent torrent) async {
    await _transmission.startTorrents([torrent.id!]);
  }

  @action
  Future<void> addTorrent(String magnet) async {
    await _transmission.addTorrent(filename: magnet);
  }

  @action
  Future<void> deleteTorrent(Torrent torrent, bool deleteData) async {
    try {
      await _transmission
          .removeTorrents([torrent.id!], deleteLocalData: deleteData);
      torrents.value!.removeWhere((element) => element.id == torrent.id);
    } on TransmissionException catch (ex) {
      print('delete failed, $ex');
    }
  }

  @action
  Future<void> moveTorrent(Torrent torrent, String location, bool move) async {
    await _transmission.moveTorrents([torrent.id!], location, move: move);
  }

  @action
  Future<void> renameTorrent(Torrent torrent, String name) async {
    await _transmission.renameTorrent(torrent.id!,
        name: name, path: torrent.name);
  }

  @action
  Future<void> stopTorrent(Torrent torrent) async {
    await _transmission.stopTorrents([torrent.id!]);
  }

  Future<ObservableList<Torrent>> _loadTorrents() async {
    return ObservableList.of(await _transmission.getTorrents());
  }

  void dispose() {
    _transmission.dispose();
  }
}
