import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  build: DS.belongsTo('build'),
  jobs: DS.hasMany('jobs')
});
