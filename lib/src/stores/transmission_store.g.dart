// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transmission_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TransmissionStore on _TransmissionStore, Store {
  final _$torrentsAtom = Atom(name: '_TransmissionStore.torrents');

  @override
  ObservableFuture<ObservableList<Torrent>> get torrents {
    _$torrentsAtom.reportRead();
    return super.torrents;
  }

  @override
  set torrents(ObservableFuture<ObservableList<Torrent>> value) {
    _$torrentsAtom.reportWrite(value, super.torrents, () {
      super.torrents = value;
    });
  }

  final _$sessionAtom = Atom(name: '_TransmissionStore.session');

  @override
  ObservableMap<String, dynamic> get session {
    _$sessionAtom.reportRead();
    return super.session;
  }

  @override
  set session(ObservableMap<String, dynamic> value) {
    _$sessionAtom.reportWrite(value, super.session, () {
      super.session = value;
    });
  }

  final _$realTimePoolAtom = Atom(name: '_TransmissionStore.realTimePool');

  @override
  bool get realTimePool {
    _$realTimePoolAtom.reportRead();
    return super.realTimePool;
  }

  @override
  set realTimePool(bool value) {
    _$realTimePoolAtom.reportWrite(value, super.realTimePool, () {
      super.realTimePool = value;
    });
  }

  final _$altSpeedEnabledAtom =
      Atom(name: '_TransmissionStore.altSpeedEnabled');

  @override
  bool get altSpeedEnabled {
    _$altSpeedEnabledAtom.reportRead();
    return super.altSpeedEnabled;
  }

  @override
  set altSpeedEnabled(bool value) {
    _$altSpeedEnabledAtom.reportWrite(value, super.altSpeedEnabled, () {
      super.altSpeedEnabled = value;
    });
  }

  final _$toggleRealTimeAsyncAction =
      AsyncAction('_TransmissionStore.toggleRealTime');

  @override
  Future<void> toggleRealTime() {
    return _$toggleRealTimeAsyncAction.run(() => super.toggleRealTime());
  }

  final _$_refreshTorrentsAsyncAction =
      AsyncAction('_TransmissionStore._refreshTorrents');

  @override
  Future<void> _refreshTorrents() {
    return _$_refreshTorrentsAsyncAction.run(() => super._refreshTorrents());
  }

  final _$loadTorrentsAsyncAction =
      AsyncAction('_TransmissionStore.loadTorrents');

  @override
  Future<void> loadTorrents() {
    return _$loadTorrentsAsyncAction.run(() => super.loadTorrents());
  }

  final _$startAllTorrentAsyncAction =
      AsyncAction('_TransmissionStore.startAllTorrent');

  @override
  Future<void> startAllTorrent() {
    return _$startAllTorrentAsyncAction.run(() => super.startAllTorrent());
  }

  final _$getSessionAsyncAction = AsyncAction('_TransmissionStore.getSession');

  @override
  Future<void> getSession() {
    return _$getSessionAsyncAction.run(() => super.getSession());
  }

  final _$setSessionAsyncAction = AsyncAction('_TransmissionStore.setSession');

  @override
  Future<void> setSession(Map<String, dynamic> data) {
    return _$setSessionAsyncAction.run(() => super.setSession(data));
  }

  final _$askForMorePeersAsyncAction =
      AsyncAction('_TransmissionStore.askForMorePeers');

  @override
  Future<void> askForMorePeers(Torrent torrent) {
    return _$askForMorePeersAsyncAction
        .run(() => super.askForMorePeers(torrent));
  }

  final _$stopAllTorrentAsyncAction =
      AsyncAction('_TransmissionStore.stopAllTorrent');

  @override
  Future<void> stopAllTorrent() {
    return _$stopAllTorrentAsyncAction.run(() => super.stopAllTorrent());
  }

  final _$startTorrentAsyncAction =
      AsyncAction('_TransmissionStore.startTorrent');

  @override
  Future<void> startTorrent(Torrent torrent) {
    return _$startTorrentAsyncAction.run(() => super.startTorrent(torrent));
  }

  final _$addTorrentAsyncAction = AsyncAction('_TransmissionStore.addTorrent');

  @override
  Future<void> addTorrent(String magnet) {
    return _$addTorrentAsyncAction.run(() => super.addTorrent(magnet));
  }

  final _$deleteTorrentAsyncAction =
      AsyncAction('_TransmissionStore.deleteTorrent');

  @override
  Future<void> deleteTorrent(Torrent torrent, bool deleteData) {
    return _$deleteTorrentAsyncAction
        .run(() => super.deleteTorrent(torrent, deleteData));
  }

  final _$moveTorrentAsyncAction =
      AsyncAction('_TransmissionStore.moveTorrent');

  @override
  Future<void> moveTorrent(Torrent torrent, String location, bool move) {
    return _$moveTorrentAsyncAction
        .run(() => super.moveTorrent(torrent, location, move));
  }

  final _$renameTorrentAsyncAction =
      AsyncAction('_TransmissionStore.renameTorrent');

  @override
  Future<void> renameTorrent(Torrent torrent, String name) {
    return _$renameTorrentAsyncAction
        .run(() => super.renameTorrent(torrent, name));
  }

  final _$stopTorrentAsyncAction =
      AsyncAction('_TransmissionStore.stopTorrent');

  @override
  Future<void> stopTorrent(Torrent torrent) {
    return _$stopTorrentAsyncAction.run(() => super.stopTorrent(torrent));
  }

  @override
  String toString() {
    return '''
torrents: ${torrents},
session: ${session},
realTimePool: ${realTimePool},
altSpeedEnabled: ${altSpeedEnabled}
    ''';
  }
}
