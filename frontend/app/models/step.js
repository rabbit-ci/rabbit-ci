import DS from 'ember-data';
import ansi_up from 'ansi-up';
import Phoenix from "rabbit-ci/phoenix";

export default DS.Model.extend({
  name: DS.attr('string'),
  status: DS.attr('string'),
  log: DS.attr('string'),
  build: DS.belongsTo('build'),
  htmlLog: Ember.computed(function() {
    return ansi_up.ansi_to_html(this.get('log'), {use_classes: true});
  }).property('log'),

  phoenixLoad: Ember.on('didLoad', function() {
    let socket = this.get('phoenix');
    let chan = socket.channel("steps:" + this.get('id'), {});

    chan.join().receive("ignore", () => console.log("auth error"));

    chan.onError(e => console.log("something went wrong", e));
    chan.onClose(e => console.log("channel closed", e));

    chan.on("append_log:step", payload => {
      this.set('log', this.get('log') + payload["log_append"]);
    });

    this.set('channel', chan);
  })
});
