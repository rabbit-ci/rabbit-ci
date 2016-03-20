import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  project: DS.belongsTo('project'),
  builds: DS.hasMany('build'),

  buildsSorting: ['buildNumber:desc'],
  sortedBuilds: Ember.computed.sort('builds', 'buildsSorting'),

  connectToChan() {
    if (this.get('channel')) return;

    let socket = this.get('phoenix');
    let chan = socket.channel("branches:" + this.get('id'), {});

    chan.join().receive("ignore", () => console.log("auth error"));
    chan.onError(e => console.log("something went wrong", e));

    chan.on("new:build", payload => {
      this.store.pushPayload(payload);
    });

    this.set('channel', chan);
  }
});
