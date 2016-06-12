import DS from 'ember-data';

export default DS.Model.extend({
  status: DS.attr('string'),
  logs: DS.hasMany('logs'),
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
  })
});
