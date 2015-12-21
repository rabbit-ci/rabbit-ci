import DS from 'ember-data';

export default DS.Model.extend({
  buildNumber: DS.attr('number'),
  branch: DS.belongsTo('branch'),
  status: DS.attr('string'),
  commit: DS.attr('string'),
  insertedAt: DS.attr('date'),
  configExtracted: DS.attr('string'),
  steps: DS.hasMany('steps')
});
