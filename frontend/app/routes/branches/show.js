import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord("branch", {
      branch: params.branch_name,
      project: params.project_name
    });
  },

  afterModel(branch) {
    if (branch.get('builds').isFulfilled === true) {
      branch.get('builds').reload();
    }
  }
});
