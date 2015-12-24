import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord("branch", {
      branch: params.branch_name,
      project: params.project_name
    });
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
    });
  },

  _disconnectBuildsFromChan(builds) {
    builds.forEach((build) => {
      build.disconnectFromChan();
    });
  },

  actions: {
    willTransition() {
      Ember.removeObserver(this, 'currentModel.builds', this, 'buildsChanged');
      if (this.get('currentModel.builds')) {
        this.get('currentModel.builds')
          .then((builds) => this._disconnectBuildsFromChan(builds));
      }

      this.currentModel.disconnectFromChan();
      return true;
    }
  }
});
