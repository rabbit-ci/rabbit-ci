import Ember from 'ember';
import RefresherMixin from '../../../mixins/refresher';
import { module, test } from 'qunit';

module('Unit | Mixin | refresher');

// Replace this with your real tests.
test('it works', function(assert) {
  let RefresherObject = Ember.Object.extend(RefresherMixin);
  let subject = RefresherObject.create();
  assert.ok(subject);
});
