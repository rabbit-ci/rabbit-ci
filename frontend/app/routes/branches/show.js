import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord("branch", {
      branch: decodeURIComponent(params.branch_name),
      project: this.modelFor('projects.show').get('name')
    });
  },

  serialize(model, params) {
    return {
      owner: model.get("project.owner"),
      repo_name: model.get("project.repo_name"),
      branch_name: encodeURIComponent(model.get("name"))
    };
  },

  afterModel(branch) {
    Ember.addObserver(branch, 'builds', this, 'buildsChanged');
    branch.connectToChan();

    if (branch.get('builds').isFulfilled === true) {
      branch.get('builds').reload();
    }
  },

  buildsChanged() {
    this._connectBuildsToChan(this.get('currentModel.builds'));
  },

  _connectBuildsToChan(builds) {
    builds.forEach((build) => {
      build.connectToChan();
      build.get('steps').forEach((step) => {
        step.get('jobs').forEach((job) => {
          job.connectToChan();
        });
      });
    });
  }
});
