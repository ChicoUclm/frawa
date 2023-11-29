enum HLS {
  starting('HLS_STARTING'),
  started('HLS_STARTED'),
  stopped('HLS_STOPPED'),
  stopping('HLS_STOPPING'),
  playable('HLS_PLAYABLE');

  const HLS(this.type);
  final String type;

  factory HLS.fromString(String state) {
    switch (state) {
      case 'HLS_STARTING':
        return HLS.starting;
      case 'HLS_STARTED':
        return HLS.started;
      case 'HLS_STOPPED':
        return HLS.stopped;
      case 'HLS_STOPPING':
        return HLS.stopping;
      case 'HLS_PLAYABLE':
        return HLS.playable;
      default:
        return HLS.stopped;
    }
  }
}
