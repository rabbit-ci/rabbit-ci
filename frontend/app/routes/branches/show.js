import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params) {
    return this.store.queryRecord("branch", {branch: params.branch_name, project: params.project_name});
  }
});
