import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  project: DS.belongsTo('project'),
  builds: DS.hasMany('build'),

  buildsSorting: ['buildNumber:desc'],
  sortedBuilds: Ember.computed.sort('builds', 'buildsSorting'),

  runningBuildsCount: Ember.computed('builds.@each.status', function() {
    return this.get('builds').filterBy('status', 'running').get('length');
  }),

  queuedBuildsCount: Ember.computed('builds.@each.status', function() {
    return this.get('builds').filterBy('status', 'queued').get('length');
  })
});
