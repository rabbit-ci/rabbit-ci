import Ember from 'ember';
import PhoenixSocket from 'phoenix/services/phoenix-socket';
import ENV from "../config/environment";

export default PhoenixSocket.extend({
  store: Ember.inject.service(),
  channel: null,
  subscribedRecords: new Map(),

  init: function() {
    this.on('error', () => {
      this.set('needResubscribe', true);
    });

    this.on('close', () => {
      this.set('needResubscribe', true);
    });

    this.on('open', () => {
      if (!this.get('needResubscribe')) return;

      let subbed = this.get('subscribedRecords');
      this.set('subscribedRecords', new Map());
      let subTo = {};

      for(let [_key, {key, id}] of subbed) {
        subTo[key] = (subTo[key] || []).concat(id);
      }

      this.set('needResubscribe', false);
      this.subscribe(subTo);
    });

    const uri = ENV.SocketURI;

    if (uri === undefined || uri === null) {
      console.error("You must specify a `SocketURI` in your config/environment.js file");
    } else {
      this.connect(uri, {});
      const channel = this.joinChannel("record_pubsub", {});
      channel.on("json_api_payload", (payload) => this._onPayload(payload));
      this.set('channel', channel);
    }
  },

  _onPayload(payload) {
    Ember.Logger.debug('Received payload:', payload);
    this.get('store').pushPayload(payload);
  },

  // E.g. subscribe({builds: 123})
  subscribe(map) {
    Ember.Logger.debug("Subscribing to:", map);
    let actualSub = this._processPubSubMap(map,
                                           (old) => {return (old || 0) === 0;},
                                           (old) => {return (old || 0) + 1;});

    this.get('channel').push("subscribe", actualSub)
      .receive("ok", (resp) => {
        Ember.Logger.debug("[OK] Subscribed to:", actualSub, "Response:", resp);
      });
  },

  // E.g. unsubscribe({builds: 123})
  unsubscribe(map) {
    Ember.Logger.debug("Unsubscribing from:", map);
    let actualUnsub = this._processPubSubMap(map,
                                             (old) => {return (old || 0) === 1;},
                                             (old) => {return (old || 1) - 1;});

    this.get('channel').push("unsubscribe", actualUnsub)
      .receive("ok", (resp) => {
        Ember.Logger.debug("[OK] Unsubscribed from:", actualUnsub, "Response:", resp);
      });
  },

  _processPubSubMap(map, compare, change) {
    let actualChange = {};

    Object.keys(map).forEach((key) => {
      [].concat(map[key]).forEach((id) => {
        let subbed = this.get('subscribedRecords');
        let {count} = subbed.get(key + id) || {};

        if (compare(count))
          actualChange[key] = [].concat(actualChange[key] || [], id);

        this.get('subscribedRecords').set(key + id, {
          count: change(count),
          key: key,
          id: id
        });
      });
    });

    Ember.Logger.debug("PubSub count:", this.get('subscribedRecords'));
    return actualChange;
  }
});
