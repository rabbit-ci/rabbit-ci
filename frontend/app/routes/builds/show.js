import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord("build",
           {branch: params.branch_name, project: params.project_name,
            build_number: params.build_number});
  },

  afterModel(build) {
    build.get('steps').forEach((step) => {
      step.connectToChan();
    });

    build.connectToChan();
  },

  actions: {
    reloadModel() {
      this.refresh();
    },

    willTransition() {
      this.currentModel.get('steps').forEach((step) => {
        step.disconnectFromChan();
      });

      this.currentModel.disconnectFromChan();
      return true;
    }
  }
});
