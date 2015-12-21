import Ember from 'ember';
import RefresherMixin from "rabbit-ci/mixins/refresher";

export default Ember.Route.extend(RefresherMixin, {
  model(params) {
    return this.store.queryRecord("branch", {branch: params.branch_name, project: params.project_name});
  },

  doRefresh() {
    this.refresh();
    this.currentModel.get('builds').reload();
    Em.run.later(this, this.doRefresh, 5000);
  }
});
