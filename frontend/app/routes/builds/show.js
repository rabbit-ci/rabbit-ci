import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord("build",
           {branch: params.branch_name, project: params.project_name,
            build_number: params.build_number});
  },

  afterModel(build) {
    build.get('steps').map((step, _index, _enum) => {
      step.connectToChan();
    });
  },

  actions: {
    reloadModel() {
      this.refresh();
    },

    willTransition() {
      this.currentModel.get('steps').map((step, _index, _enum) => {
        step.disconnectFromChan();
      });

      this._super();
    }
  }
});
