import DS from 'ember-data';

export default DS.Model.extend({
  status: DS.attr('string'),
  log: DS.attr('string'),
  box: DS.attr('string'),
  step: DS.belongsTo('step'),
  startTime: DS.attr('date'),
  finishTime: DS.attr('date'),
  duration: Ember.computed('startTime', 'finishTime', function() {
    let time = this.get('finishTime') || new Date();
    return time - this.get('startTime');
  }),

  statusColor: Ember.computed("status", function() {
    switch(this.get('status')) {
    case "failed": return "red";
    case "errored": return "red";
    case "queued": return "yellow";
    case "running": return "yellow";
    case "finished": return "green";
    default: return "";
    }
  }),

  connectToChan() {
    if (this.get('channel')) return;

    let socket = this.get('phoenix');
    let chan = socket.channel("jobs:" + this.get('id'), {});

    chan.join().receive("ignore", () => console.log("auth error"));

    chan.onError(e => console.log("something went wrong", e));

    chan.on("set_log:job", payload => {
      this.set('log', payload["log"]);
    });

    chan.on("append_log:job", payload => {
      this.set('log', this.get('log') + payload["log_append"]);
    });

    this.set('channel', chan);
  },

  disconnectFromChan() {
    let chan = this.get('channel');
    if (chan) chan.leave();
    this.set('channel', null);
  }
});
