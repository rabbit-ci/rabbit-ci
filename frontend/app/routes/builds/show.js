import Ember from 'ember';
import RefresherMixin from "rabbit-ci/mixins/refresher";

export default Ember.Route.extend(RefresherMixin, {
  shouldRefresh: Ember.computed.alias('controller.shouldRefresh'),
  model(params) {
    return this.store.queryRecord("build",
           {branch: params.branch_name, project: params.project_name,
            build_number: params.build_number});
  },

  setupController(controller, model) {
    this._super(controller, model);
    controller.set("shouldRefresh", false);
  },

  actions: {
    reloadModel() {
      this.refresh();
    },

    toggleRefresh() {
      this.toggleProperty('shouldRefresh');
    }
  }
});
