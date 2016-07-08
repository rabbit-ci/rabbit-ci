import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { belongsTo } from 'ember-data/relationships';

export default Model.extend({
  stdio: attr('string'),
  order: attr('number'),
  ioType: attr('string'),
  fg: attr('string'),
  bg: attr('string'),
  style: attr('string'),
  job: belongsTo('job'),

  endsInNewline: Ember.computed('stdio', function() {
    let str = this.get('stdio');
    return str.charAt(str.length - 1) == "\n";
  })
});
