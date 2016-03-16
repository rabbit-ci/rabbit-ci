import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  repo: DS.attr('string'),
  branches: DS.hasMany('branch'),

  owner: Ember.computed('name', function() {
    return this.get('name').split('/')[0];
  }),
  repo: Ember.computed('name', function() {
    return this.get('name').split('/')[1];
  })
});
