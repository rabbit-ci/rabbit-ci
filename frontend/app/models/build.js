import DS from 'ember-data';

export default DS.Model.extend({
  buildNumber: DS.attr('number'),
  branch: DS.belongsTo('branch'),
  status: DS.attr('string'),
  commit: DS.attr('string'),
  insertedAt: DS.attr('date'),
  configExtracted: DS.attr('string'),
  steps: DS.hasMany('steps'),

  statusClass: Ember.computed("status", function() {
    switch(this.get('status')) {
    case "failed": return "error";
    case "error": return "error";
    case "queued": return "warning";
    case "running": return "warning";
    case "finished": return "positive";
    default: return "";
    }
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
