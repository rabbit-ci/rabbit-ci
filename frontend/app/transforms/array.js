import Transform from 'ember-data/transform';
import Ember from 'ember';

export default Transform.extend({
  deserialize(serialized) {
    if (Ember.isArray(serialized)) {
      return Ember.A(serialized);
    } else {
      return Ember.A();
    }
  },

  serialize(deserialized) {
    if (Ember.isArray(deserialized)) {
      return Ember.A(deserialized);
    } else {
      return Ember.A();
    }
  }
});
