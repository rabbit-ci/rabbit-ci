import { moduleForModel, test } from 'ember-qunit';

moduleForModel('log', 'Unit | Model | log', {
  // Specify the other units that are required for this test.
  needs: ['model:job']
});

test('it exists', function(assert) {
  let model = this.subject();
  // let store = this.store();
  assert.ok(!!model);
});
