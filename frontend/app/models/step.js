import DS from 'ember-data';
import ansi_up from 'ansi-up';

export default DS.Model.extend({
  name: DS.attr('string'),
  status: DS.attr('string'),
  log: DS.attr('string'),
  build: DS.belongsTo('build'),
  htmlLog: Ember.computed(function() {
    return ansi_up.ansi_to_html(this.get('log'), {use_classes: true});
  }).property('log')
});
