import Ember from 'ember';
import RefresherMixin from "rabbit-ci/mixins/refresher";

export default Ember.Route.extend(RefresherMixin, {
  refreshInterval: 5000,
  model(params) {
    return this.store.queryRecord("branch", {branch: params.branch_name, project: params.project_name});
  },

  doRefresh() {
    this.refresh();
    this.currentModel.get('builds').reload();
  }
});
