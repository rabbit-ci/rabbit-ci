import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  repo: DS.attr('string'),
  branches: DS.hasMany('branch'),

  owner: Ember.computed('name', function() {
    if (this.get('name')) {
      return this.get('name').split('/')[0];
    } else return undefined;
  }),
  repo_name: Ember.computed('name', function() {
    if (this.get('name')) {
      return this.get('name').split('/')[1];
    } else return undefined;
  })
});
