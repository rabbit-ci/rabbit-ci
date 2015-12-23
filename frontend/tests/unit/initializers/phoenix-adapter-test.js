import Ember from 'ember';
import PhoenixAdapterInitializer from '../../../initializers/phoenix-adapter';
import { module, test } from 'qunit';

let application;

module('Unit | Initializer | phoenix adapter', {
  beforeEach() {
    Ember.run(function() {
      application = Ember.Application.create();
      application.deferReadiness();
    });
  }
});

// Replace this with your real tests.
test('it works', function(assert) {
  PhoenixAdapterInitializer.initialize(application);

  // you would normally confirm the results of the initializer here
  assert.ok(true);
});
