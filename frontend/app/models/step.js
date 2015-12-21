import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  status: DS.attr('string'),
  log: DS.attr('string'),
  build: DS.belongsTo('build')
});
