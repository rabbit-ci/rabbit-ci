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
    this.set('idMap.branches', branch.get('id'));
    this.get('phoenix').subscribe(this.get('idMap'));
    if (branch.get('builds').isFulfilled === true) {
      branch.get('builds').reload();
    }
  },

  phoenix: Ember.inject.service(),
  idMap: {branches: null, builds: [], jobs: []},

  buildsChanged() {
    this._connectBuildsToChan(this.get('currentModel.builds'));
  },

  _connectBuildsToChan(builds) {
    let oldIds = Ember.copy(this.get('idMap'));
    this.set('idMap.builds', []);
    this.set('idMap.jobs', []);

    builds.forEach((build) => {
      this.set('idMap.builds', this.get('idMap.builds').concat(build.get('id')));
      build.get('steps').forEach((step) => {
        step.get('jobs').forEach((job) => {
          this.set('idMap.jobs', this.get('idMap.jobs').concat(job.get('id')));
        });
      });
    });

    this.get('phoenix').subscribe(this.get('idMap'));
    this.get('phoenix').unsubscribe(oldIds);
  },

  deactivate() {
    this.get('phoenix').unsubscribe(this.get('idMap'));
  }
});
