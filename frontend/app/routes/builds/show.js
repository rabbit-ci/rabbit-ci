import Ember from 'ember';
import RefresherMixin from "rabbit-ci/mixins/refresher";

export default Ember.Route.extend(RefresherMixin, {
  model(params) {
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
