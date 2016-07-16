import Ember from 'ember';
import PhoenixSocket from 'phoenix/services/phoenix-socket';
import ENV from "../config/environment";

export default PhoenixSocket.extend({
  store: Ember.inject.service(),
  channel: null,
  subscribedRecords: new Map(),

  init: function() {
    this.on('error', () => {
      Ember.Logger.debug('Socket error');
      this.set('needResubscribe', true);
    });

    this.on('close', () => {
      Ember.Logger.debug('Socket close');
      this.set('needResubscribe', true);
    });

    this.on('open', () => {
      Ember.Logger.debug('Socket open');
      if (!this.get('needResubscribe')) return;

      let subbed = this.get('subscribedRecords');
      this.set('subscribedRecords', new Map());
      let subTo = {};

      for(let [_key, {key, id, count}] of subbed) {
        if (count > 0) {
          subTo[key] = (subTo[key] || []).concat(id);
        }
      }

      this.set('needResubscribe', false);
      this.subscribe(subTo);
    });

    // const uri = ENV.SocketURI;
    const uri = 'ws://' + document.location.hostname + ':4000/socket';

    if (uri === undefined || uri === null) {
      console.error("You must specify a `SocketURI` in your config/environment.js file");
    } else {
      this.connect(uri, {});
      const channel = this.joinChannel("record_pubsub", {});
      channel.on("json_api_payload", (payload) => this._onPayload(payload));
      channel.on("fast_log_payload", (payload) => this._onLogPayload(payload));
      this.set('channel', channel);
    }
  },

  _onLogPayload(payload) {
    var t2 = performance.now();
    let data = payload.data;

    if (!Array.isArray(data)) {
      data = [data];
    }

    data.forEach((oneLog) => {
      let job = this.get('store').peekRecord('job', oneLog.job_id);
      let logs = job.get('logs');
      logs.arrayContentWillChange(oneLog.order, 1, 1);
      logs[oneLog.order] = oneLog;
      logs.arrayContentDidChange(oneLog.order, 1, 1);
    });

    var t3 = performance.now();
    console.log("Log update took " + (t3 - t2) + " milliseconds.");
  },

  _onPayload(payload) {
    Ember.run(() => {
      this.get('store').pushPayload(payload);
    });
  },

  // E.g. subscribe({builds: 123})
  subscribe(map) {
    let actualSub = this._processPubSubMap(map,
                                           (old) => {return (old || 0) === 0;},
                                           (old) => {return (old || 0) + 1;});
    if (Object.keys(actualSub).length === 0) return;
    this.get('channel').push("subscribe", actualSub)
      .receive("ok", (resp) => {
        Ember.Logger.debug("[OK] Subscribed to:", actualSub, "Response:", resp);
      });
  },

  // E.g. unsubscribe({builds: 123})
  unsubscribe(map) {
    let actualUnsub = this._processPubSubMap(map,
                                             (old) => {return (old || 0) === 1;},
                                             (old) => {return (old || 1) - 1;});
    if (Object.keys(actualUnsub).length === 0) return;
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

    return actualChange;
  }
});
