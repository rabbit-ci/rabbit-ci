import DS from 'ember-data';

export default DS.Model.extend({
  buildNumber: DS.attr('number'),
  branch: DS.belongsTo('branch'),
  status: DS.attr('string'),
  commit: DS.attr('string'),
  insertedAt: DS.attr('date'),
  configExtracted: DS.attr('string'),
  steps: DS.hasMany('steps'),

  connectToChan() {
    if (this.get('leaving')) {
      this.set('queuedConnect', true);
      return;
    }
    if (this.get('channel')) return;

    let socket = this.get('phoenix');
    let chan = socket.channel("builds:" + this.get('id'), {});

    chan.join().receive("ignore", () => console.log("auth error"));
    chan.onError(e => console.log("something went wrong", e));

    chan.on("update:build", payload => {
      this.store.pushPayload(payload);
    });

    this.set('channel', chan);
  },

  connectQueued: Ember.observer('leaving', function() {
    if (!this.get('leaving') && this.get('queuedConnect')) {
      this.connectToChan();
      this.set('queuedConnect', false);
    }
  }),

  disconnectFromChan() {
    let chan = this.get('channel');
    if (chan) {
      this.set('leaving', true);
      chan.onClose(() => {this.set('leaving', false);});
      chan.leave();
    }
    this.set('channel', null);
  }
});
