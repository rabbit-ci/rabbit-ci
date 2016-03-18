import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord("build", {
      branch: decodeURIComponent(params.branch_name),
      project: this.modelFor('projects.show').get('name'),
      build_number: params.build_number
    });
  },

  serialize(model, params) {
    return {
      owner: model.get("branch.project.owner"),
      repo_name: model.get("branch.project.repo_name"),
      branch_name: encodeURIComponent(model.get("branch.name")),
      build_number: model.get("buildNumber")
    };
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
    }
  }
});
