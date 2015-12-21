import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params) {
    return this.store.queryRecord("build",
           {branch: params.branch_name, project: params.project_name,
            build_number: params.build_number});
  },

  actions: {
    reloadModel() {
      this.refresh();
    }
  }
});
